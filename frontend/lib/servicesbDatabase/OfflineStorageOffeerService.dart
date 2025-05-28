import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../utils/internet_checker.dart';

class OfflineStorageService {
  final AppDatabase _database;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final InternetChecker _internetChecker = InternetChecker();
  final Logger _logger = Logger();

  // حجم الدفعة الافتراضي
  final int _batchSize = 5;

  // آخر مستند للصفحات
  DocumentSnapshot? _lastDocument;

  OfflineStorageService(this._database);

  // التحقق من حالة الاتصال
  Future<bool> isOnline() async {
    return await _internetChecker.hasInternet;
  }

  // الحصول على تدفق حالة الاتصال
  Stream<bool> get connectivityStream => _internetChecker.onStatusChange;

  // تحميل الدفعة الأولى من العروض
  Future<List<Offer>> loadInitialOffers({
    bool activeOnly = true,
    bool orderByDate = false,
    bool orderByExpiry = true,
    bool descending = false,
  }) async {
    _logger.i("تحميل العروض الأولية");

    try {
      bool online = await isOnline();

      if (online) {
        // متصل: جلب من Firestore وتخزين محلياً
        return await _fetchAndCacheOffers(
          activeOnly: activeOnly,
          orderByDate: orderByDate,
          orderByExpiry: orderByExpiry,
          descending: descending,
        );
      } else {
        // غير متصل: تحميل من قاعدة البيانات المحلية
        return await _loadOffersFromDatabase(
          activeOnly: activeOnly,
          orderByDate: orderByDate,
          orderByExpiry: orderByExpiry,
          descending: descending,
        );
      }
    } catch (e) {
      _logger.e("خطأ في تحميل العروض الأولية: $e");
      // الرجوع إلى قاعدة البيانات المحلية في حالة الخطأ
      try {
        return await _loadOffersFromDatabase(
          activeOnly: activeOnly,
          orderByDate: orderByDate,
          orderByExpiry: orderByExpiry,
          descending: descending,
        );
      } catch (innerError) {
        _logger.e("خطأ في تحميل العروض من قاعدة البيانات المحلية: $innerError");
        // إرجاع قائمة فارغة في حالة فشل كل المحاولات
        return [];
      }
    }
  }

  // تحميل المزيد من العروض
  Future<List<Offer>> loadMoreOffers({
    bool activeOnly = true,
    bool orderByDate = false,
    bool orderByExpiry = true,
    bool descending = false,
  }) async {
    _logger.i("تحميل المزيد من العروض");

    try {
      bool online = await isOnline();

      // الحصول على عدد العروض التي تمت مشاهدتها
      int viewedCount = await _database.getViewedOffersCount();

      if (online && viewedCount % _batchSize == 0) {
        // متصل والمستخدم شاهد دفعة كاملة: جلب المزيد
        return await _fetchAndCacheOffers(
          activeOnly: activeOnly,
          orderByDate: orderByDate,
          orderByExpiry: orderByExpiry,
          descending: descending,
        );
      } else if (!online) {
        // غير متصل: محاولة تحميل الدفعة التالية من قاعدة البيانات المحلية
        return await _loadOffersFromDatabase(
          offset: viewedCount,
          activeOnly: activeOnly,
          orderByDate: orderByDate,
          orderByExpiry: orderByExpiry,
          descending: descending,
        );
      } else {
        // المستخدم لم يشاهد كل العروض الحالية بعد
        return [];
      }
    } catch (e) {
      _logger.e("خطأ في تحميل المزيد من العروض: $e");
      return [];
    }
  }

  // تحديد عرض كمشاهد
  Future<void> markOfferAsViewed(String offerId) async {
    _logger.i("تحديد العرض كمشاهد: $offerId");
    try {
      await _database.markOfferAsViewed(offerId);

      // التحقق مما إذا كنا بحاجة إلى تحميل المزيد من العروض مسبقاً
      int viewedCount = await _database.getViewedOffersCount();
      if (viewedCount % _batchSize == 0) {
        bool online = await isOnline();
        if (online) {
          _logger.i("تحميل الدفعة التالية مسبقاً بعد مشاهدة $_batchSize عروض");
          await _fetchAndCacheOffers(preloadOnly: true);
        }
      }
    } catch (e) {
      _logger.e("خطأ في تحديد العرض كمشاهد: $e");
    }
  }

  // جلب العروض من Firestore وتخزينها محلياً
  Future<List<Offer>> _fetchAndCacheOffers({
    bool preloadOnly = false,
    bool activeOnly = true,
    bool orderByDate = false,
    bool orderByExpiry = true,
    bool descending = false,
  }) async {
    _logger.i("جلب العروض من Firestore");

    try {
      // إنشاء الاستعلام
      firestore.Query query = _firestore.collection('offers');
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (orderByDate) {
        query = query.orderBy('createdAt', descending: descending);
      } else if (orderByExpiry) {
        query = query.orderBy('expiryDate', descending: descending);
      }

      query = query.limit(_batchSize);

      // إذا كان لدينا آخر مستند، نبدأ بعده للصفحات
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // تنفيذ الاستعلام
      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _logger.i("لا توجد المزيد من العروض للجلب");
        return [];
      }

      // تحديث آخر مستند للصفحات
      _lastDocument = snapshot.docs.last;

      // تحويل إلى عروض وتخزينها
      List<Offer> offers = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // تحويل Timestamp إلى DateTime
        DateTime? createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        DateTime? expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();

        // تحويل قائمة الصور إلى سلسلة JSON للتخزين
        List<String> images =
            (data['images'] as List<dynamic>?)?.cast<String>() ?? [];
        String imagesJson = jsonEncode(images);

        // إنشاء كائن العرض
        Offer offer = Offer(
          id: data['offerId'] ?? doc.id,
          merchantId: data['merchantId'] ?? '',
          storeName: data['storeName'] ?? '',
          description: data['description'] ?? '',
          duration: data['duration'] ?? 0,
          images: imagesJson,
          createdAt: createdAt,
          expiryDate: expiryDate,
          isActive: data['isActive'] ?? true,
          likes: data['likes'] ?? 0,
          viewed: false,
        );

        // حفظ في قاعدة البيانات
        try {
          await _database.insertOffer(offer);
        } catch (e) {
          _logger.e("خطأ في حفظ العرض في قاعدة البيانات: $e");
          // استمر في المعالجة حتى مع وجود خطأ
        }

        offers.add(offer);
      }

      _logger.i("تم تخزين ${offers.length} عروض في قاعدة البيانات المحلية");

      // إذا كان التحميل المسبق فقط، لا نعيد العروض
      if (preloadOnly) {
        return [];
      }

      return offers;
    } catch (e) {
      _logger.e("خطأ في جلب وتخزين العروض: $e");
      throw e;
    }
  }

  // تحميل العروض من قاعدة البيانات المحلية
  Future<List<Offer>> _loadOffersFromDatabase({
    int offset = 0,
    bool activeOnly = true,
    bool orderByDate = false,
    bool orderByExpiry = true,
    bool descending = false,
  }) async {
    _logger.i("تحميل العروض من قاعدة البيانات المحلية، تخطي $offset");

    try {
      // الحصول على العروض بالصفحات من قاعدة البيانات
      List<Offer> paginatedOffers = await _database.getPaginatedOffers(
        offset: offset,
        limit: _batchSize,
        activeOnly: activeOnly,
        orderByDate: orderByDate,
        orderByExpiry: orderByExpiry,
        descending: descending,
      );

      _logger.i(
          "تم تحميل ${paginatedOffers.length} عروض من قاعدة البيانات المحلية");
      return paginatedOffers;
    } catch (e) {
      _logger.e("خطأ في تحميل العروض من قاعدة البيانات: $e");
      return [];
    }
  }

  // إعادة تعيين تتبع العروض المشاهدة
  Future<void> resetViewedOffers() async {
    _logger.i("إعادة تعيين العروض المشاهدة");
    try {
      // تحديث جميع العروض لتكون غير مشاهدة
      await _database.customUpdate(
        'UPDATE offers SET viewed = 0',
      );
      // إعادة تعيين آخر مستند للصفحات
      _lastDocument = null;
    } catch (e) {
      _logger.e("خطأ في إعادة تعيين العروض المشاهدة: $e");
    }
  }
}
