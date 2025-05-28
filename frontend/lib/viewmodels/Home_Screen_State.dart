// state_management.dart
// تنظيم وإدارة الحالات للتطبيق مع التعليقات باللغة العربية

// استيراد الحزم والمكتبات الضرورية
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../utils/internet_checker.dart';
import '../database_helper.dart';
import '../servicesbDatabase/ActionService.dart';
import '../servicesbDatabase/OfflineStorageOffeerService.dart';
import '../ServicesFireBase/firestore_service.dart';
import '../models/user.dart';
import '../utils/SecureStorageHelper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BaseState: فئة أساسية توفر التعامل مع التحميل والأخطاء لجميع الحالات
// ─────────────────────────────────────────────────────────────────────────────
abstract class BaseState with ChangeNotifier {
  final Logger _logger = Logger(); // مثيل لتسجيل الرسائل والأخطاء
  bool _isLoading = false; // مؤشر حالة التحميل
  String? _error; // رسالة الخطأ عند وجودها

  bool get isLoading => _isLoading;
  String? get error => _error;
  Logger get logger => _logger;

  /// ضبط حالة التحميل وإعلام المستمعين بالتغيير
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// تعيين رسالة خطأ وإعلام المستمعين
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// مسح رسالة الخطأ الحالية إذا وجدت
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ConnectivityState: فئة لمراقبة حالة الاتصال بالإنترنت (متصل/غير متصل)
// ─────────────────────────────────────────────────────────────────────────────
class ConnectivityState extends BaseState {
  final InternetChecker _internetChecker = InternetChecker();
  StreamSubscription? _connectivitySubscription; // اشتراك لمتابعة التغيرات
  bool _isOnline = true; // حالة الاتصال الحالية

  bool get isOnline => _isOnline;

  ConnectivityState() {
    _initConnectivity(); // تهيئة التحقق من الاتصال عند الإنشاء
  }

  /// التحقق المبدئي من الاتصال وإعداد المستمع للتغيرات
  Future<void> _initConnectivity() async {
    try {
      _isOnline = await _internetChecker.hasInternet; // فحص أولي للاتصال
      notifyListeners();

      // الاستماع للتغيرات في حالة الاتصال
      _connectivitySubscription =
          _internetChecker.onStatusChange.listen((isConnected) {
        if (_isOnline != isConnected) {
          _isOnline = isConnected;
          notifyListeners();
        }
      });
    } catch (e) {
      logger.e('خطأ أثناء تهيئة حالة الاتصال: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel(); // إلغاء الاشتراك عند التخلص
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserState: فئة لتحميل بيانات المستخدم من التخزين الآمن
// ─────────────────────────────────────────────────────────────────────────────
class UserState extends BaseState {
  User? _currentUser; // بيانات المستخدم المحملة

  User? get currentUser => _currentUser;
  bool get isMerchant =>
      _currentUser?.userType == 'merchant'; // التحقق من نوع المستخدم

  /// تحميل بيانات المستخدم وتعيين حالة التحميل/الأخطاء
  Future<void> loadUserData() async {
    setLoading(true);
    clearError();
    try {
      _currentUser = await SecureStorageHelper.getUser();
      logger.i('تم تحميل بيانات المستخدم: ${_currentUser?.name}');
    } catch (e) {
      logger.e('خطأ في تحميل بيانات المستخدم: $e');
      setError('فشل تحميل بيانات المستخدم: $e');
    } finally {
      setLoading(false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterState: فئة لإدارة خيارات التصفية والترتيب للعروض
// ─────────────────────────────────────────────────────────────────────────────
class FilterState extends BaseState {
  bool _activeOnly = true; // تصفية العروض النشطة فقط
  bool _orderByDate = false; // الترتيب حسب التاريخ
  bool _orderByExpiry = true; // الترتيب حسب تاريخ الانتهاء
  bool _descending = false; // الترتيب نزوليًا

  bool get activeOnly => _activeOnly;
  bool get orderByDate => _orderByDate;
  bool get orderByExpiry => _orderByExpiry;
  bool get descending => _descending;

  /// تحديث خيارات التصفية إذا تغيرت
  void updateFilter({
    bool? activeOnly,
    bool? orderByDate,
    bool? orderByExpiry,
    bool? descending,
  }) {
    bool hasChanged = false;

    if (activeOnly != null && _activeOnly != activeOnly) {
      _activeOnly = activeOnly;
      hasChanged = true;
    }
    if (orderByDate != null && _orderByDate != orderByDate) {
      _orderByDate = orderByDate;
      hasChanged = true;
    }
    if (orderByExpiry != null && _orderByExpiry != orderByExpiry) {
      _orderByExpiry = orderByExpiry;
      hasChanged = true;
    }
    if (descending != null && _descending != descending) {
      _descending = descending;
      hasChanged = true;
    }

    if (hasChanged) notifyListeners(); // إعلام بالتغييرات
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OffersState: فئة لإدارة قائمة العروض مع التخزين المحلي والتحديثات
// ─────────────────────────────────────────────────────────────────────────────
class OffersState extends BaseState {
  final FirestoreService _firestoreService = FirestoreService();
  final AppDatabase _database;
  late final OfflineStorageService _offlineStorageService;

  List<Offer> _cachedOffers = []; // العروض المحفوظة محليًا
  bool _isLoadingMore = false; // مؤشر تحميل المزيد
  bool _hasMoreOffers = true; // هل توجد عروض إضافية؟

  // بث التحديثات للعروض للمستمعين
  final StreamController<List<Offer>> _offersStreamController =
      StreamController<List<Offer>>.broadcast();

  final Set<String> _likedOfferIds = {}; // تتبع العروض المعجوبة محليًا

  OffersState(this._database) {
    _offlineStorageService = OfflineStorageService(_database);
  }

  List<Offer> get cachedOffers => _cachedOffers;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreOffers => _hasMoreOffers;
  Stream<List<Offer>> get offersStream => _offersStreamController.stream;
  bool isOfferLiked(String offerId) => _likedOfferIds.contains(offerId);

  /// تحميل الصفحة الأولى من العروض من التخزين المحلي
  Future<void> loadInitialOffers({
    required bool activeOnly,
    required bool orderByDate,
    required bool orderByExpiry,
    required bool descending,
  }) async {
    setLoading(true);
    clearError();
    try {
      _cachedOffers = await _offlineStorageService.loadInitialOffers(
        activeOnly: activeOnly,
        orderByDate: orderByDate,
        orderByExpiry: orderByExpiry,
        descending: descending,
      );
      _offersStreamController.add(_cachedOffers);
      _hasMoreOffers = true;
      logger.i('تم تحميل ${_cachedOffers.length} عرضًا مبدئيًا');
    } catch (e) {
      logger.e('خطأ في تحميل العروض المبدئية: $e');
      setError('فشل تحميل العروض: $e');
      _offersStreamController.add([]);
    } finally {
      setLoading(false);
    }
  }

  /// تحميل المزيد من العروض (ترقيم الصفحات)
  Future<void> loadMoreOffers({
    required bool activeOnly,
    required bool orderByDate,
    required bool orderByExpiry,
    required bool descending,
  }) async {
    if (_isLoadingMore || !_hasMoreOffers) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final moreOffers = await _offlineStorageService.loadMoreOffers(
        activeOnly: activeOnly,
        orderByDate: orderByDate,
        orderByExpiry: orderByExpiry,
        descending: descending,
      );
      if (moreOffers.isEmpty) {
        _hasMoreOffers = false;
      } else {
        _cachedOffers.addAll(moreOffers);
        _offersStreamController.add(_cachedOffers);
      }
      logger.i('تم تحميل ${moreOffers.length} عرضًا إضافيًا');
    } catch (e) {
      logger.e('خطأ في تحميل المزيد من العروض: $e');
      setError('فشل تحميل المزيد: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// تعليم العرض كمشاهد محليًا
  Future<void> markOfferAsViewed(String offerId) async {
    try {
      await _offlineStorageService.markOfferAsViewed(offerId);
      logger.i('تم تعليم العرض كمشاهد: $offerId');
    } catch (e) {
      logger.e('خطأ في تعليم العرض كمشاهد: $e');
    }
  }

  /// الحصول على العروض المصفاة من Firestore بشكل مباشر
  Stream<QuerySnapshot> getFilteredOffers({
    required bool activeOnly,
    required bool orderByDate,
    required bool orderByExpiry,
    required bool descending,
  }) {
    return _firestoreService.getFilteredOffers(
      activeOnly: activeOnly,
      orderByDate: orderByDate,
      orderByExpiry: orderByExpiry,
      descending: descending,
    );
  }

  /// تحديث العروض: مسح العروض المعلمة كمشاهد وإعادة التحميل
  Future<void> refreshOffers({
    required bool activeOnly,
    required bool orderByDate,
    required bool orderByExpiry,
    required bool descending,
  }) async {
    setLoading(true);
    try {
      await _offlineStorageService.resetViewedOffers();
      _cachedOffers.clear();
      await loadInitialOffers(
        activeOnly: activeOnly,
        orderByDate: orderByDate,
        orderByExpiry: orderByExpiry,
        descending: descending,
      );
      logger.i('تم تحديث قائمة العروض');
    } catch (e) {
      logger.e('خطأ في تحديث العروض: $e');
      setError('فشل تحديث العروض: $e');
    } finally {
      setLoading(false);
    }
  }

  /// تحديث حالة الإعجاب بالعرض في الواجهة فورًا
  void updateLikedStatus(String offerId, bool isLiked) {
    if (isLiked)
      _likedOfferIds.add(offerId);
    else
      _likedOfferIds.remove(offerId);
    notifyListeners();
  }

  /// جلب معرف التاجر لعروض معينة من Firestore
  Future<String?> getMerchantIdForOffer(String offerId) async {
    logger.i('جلب معرف التاجر للعرض: $offerId');
    try {
      final doc = await FirebaseFirestore.instance
          .collection('offers')
          .where('offerId', isEqualTo: offerId)
          .get();
      if (doc.docs.isNotEmpty) {
        return doc.docs.first.data()['merchantId'] as String?;
      }
      return null;
    } catch (e) {
      logger.e('خطأ في جلب معرف التاجر: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _offersStreamController.close(); // إغلاق البث عند التخلص
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InteractionsState: إدارة الإعجابات والتعليقات مع دعم العمل دون اتصال
// ─────────────────────────────────────────────────────────────────────────────
class InteractionsState extends BaseState {
  final FirestoreService firestoreService = FirestoreService();
  final AppDatabase _database;
  late final OfflineActionService _offlineActionService;

  final TextEditingController commentController = TextEditingController();

  InteractionsState(this._database) {
    _offlineActionService = OfflineActionService(_database, firestoreService);
  }

  /// تدفق التعليقات الحيّ عند الاتصال
  Stream<QuerySnapshot>? getOfferComments(String offerId, bool isOnline) {
    if (isOnline) return firestoreService.getOfferComments(offerId);
    return null;
  }

  /// جلب التعليقات المخزنة محليًا
  Future<List<OfferComment>> getOfflineComments(String offerId) {
    return _offlineActionService.getOfflineComments(offerId);
  }

  /// التحقق مما إذا كان المستخدم قد أبدى إعجاباً بالعرض
  Future<bool> hasUserLikedOffer(
      String offerId, String userId, bool isOnline) async {
    if (isOnline)
      return await firestoreService.hasUserLikedOffer(offerId, userId);
    return false;
  }

  /// إضافة إعجاب للعرض مع دعم العمل دون اتصال وواجهة تقديم فورية
  Future<void> likeOffer(
      String offerId,
      String userId,
      String userName,
      bool isOnline,
      Function(String, bool) updateLikedStatus,
      BuildContext context) async {
    try {
      updateLikedStatus(offerId, true); // تحديث الواجهة دون انتظار النتيجة
      if (isOnline) {
        await firestoreService.addLikeToOffer(offerId, userId, userName);
      } else {
        await _offlineActionService.queueLikeAction(offerId, userId, userName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('سيتم مزامنة الإعجاب عند عودة الاتصال بالإنترنت'),
              backgroundColor: Colors.orange),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الإعجاب بالعرض بنجاح!')),
      );
    } catch (e) {
      updateLikedStatus(offerId, false); // التراجع عند الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  /// إضافة تعليق مع دعم العمل دون اتصال
  Future<void> addComment(String offerId, String userId, String userName,
      bool isOnline, BuildContext context) async {
    try {
      final comment = commentController.text;
      if (comment.trim().isEmpty) throw Exception('لا يمكن إضافة تعليق فارغ');
      if (isOnline) {
        await firestoreService.addCommentToOffer(
            offerId, userId, comment, userName);
      } else {
        await _offlineActionService.queueCommentAction(
            offerId, userId, userName, comment);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('سيتم مزامنة التعليق عند عودة الاتصال بالإنترنت'),
              backgroundColor: Colors.orange),
        );
      }
      commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إضافة التعليق بنجاح!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  /// مزامنة الإجراءات التي تمت دون اتصال عند العودة للإنترنت
  Future<void> syncOfflineActions() async {
    logger.i('يتم الآن مزامنة الإجراءات دون اتصال');
    try {
      await _offlineActionService.syncOfflineActions();
    } catch (e) {
      logger.e('خطأ في مزامنة الإجراءات: $e');
    }
  }

  @override
  void dispose() {
    commentController.dispose(); // تحرير المتحكم عند التخلص
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UIState: إدارة مؤشر التنقل والألوان في الواجهة
// ─────────────────────────────────────────────────────────────────────────────
class UIState extends BaseState {
  int _currentIndex = 0; // المؤشر الحالي للشاشة أو التبويب
  int get currentIndex => _currentIndex;

  // تعريف ألوان التطبيق الأساسية
  final Color primaryColor = const Color.fromARGB(255, 10, 117, 163);
  final Color accentColor = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFF8F5F1);
  final Color textDarkColor = const Color(0xFF2D2D2D);
  final Color cardColor = Colors.white;

  /// تحديث قيمة المؤشر الحالية وإعلام المستمعين
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
