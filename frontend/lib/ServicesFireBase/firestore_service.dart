import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../utils/SecureStorageHelper.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  int? _currentUserId;
  String? _currentUsername; // إضافة متغير لاسم المستخدم

  int? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername; // إضافة getter لاسم المستخدم

  Future<void> loadUserData() async {
    try {
      final userId = await SecureStorageHelper.getUserId();
      final user =
          await SecureStorageHelper.getUser(); // جلب كائن المستخدم كاملاً

      _currentUserId = userId ?? 0;
      _currentUsername = user?.name ?? "مستخدم"; // تخزين اسم المستخدم
    } catch (e) {
      _logger.e('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  // دالة لتعطيل العروض المنتهية
  Future<void> checkAndDeactivateExpiredOffers() async {
    try {
      final now = DateTime.now();

      final snapshot = await _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final expiry = (data['expiryDate'] as Timestamp).toDate();

        if (expiry.isBefore(now)) {
          await _firestore
              .collection('offers')
              .doc(doc.id)
              .update({'isActive': false});

          _logger.i("✅ تم تعطيل العرض ${doc.id} لأنه منتهي");
        }
      }
    } catch (e) {
      _logger.e("❌ خطأ أثناء التحقق من العروض المنتهية: $e");
    }
  }

  // دالة جلب العروض النشطة
  Stream<QuerySnapshot> getActiveOffers({bool descending = false}) {
    _logger.i("جلب العروض النشطة");

    return _firestore
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .orderBy('expiryDate', descending: descending)
        .snapshots();
  }

  // دالة جلب العروض حسب التصفية

  Stream<QuerySnapshot> getFilteredOffers({
    bool activeOnly = true,
    bool orderByDate = false,
    bool orderByExpiry = true,
    bool descending = false,
  }) {
    _logger.i("جلب العروض المصفاة");

    // غيّر نوع المتغير إلى Query بدل CollectionReference
    Query query = _firestore.collection('offers');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (orderByDate) {
      query = query.orderBy('createdAt', descending: descending);
    } else if (orderByExpiry) {
      query = query.orderBy('expiryDate', descending: descending);
    }

    return query.snapshots();
  }

  // دالة جلب تعليقات عرض معين
  Stream<QuerySnapshot> getOfferComments(String offerId) {
    _logger.i("جلب تعليقات العرض: $offerId");
    return _firestore
        .collection('offers')
        .doc(offerId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Future<int?> getOwnerIdFromChat(String chatId) async {
  //   _logger.i("جلب ownerId لمحادثة واحدة: $chatId");
  //   final doc = await _firestore.collection('chats').doc(chatId).get();
  //   if (doc.exists) {
  //     final data = doc.data();
  //     return data?['ownerId'] as int?;
  //   }
  //   return null;
  // }

  // دالة التحقق من إعجاب المستخدم بعرض معين
  Future<bool> hasUserLikedOffer(String offerId, String userId) async {
    try {
      DocumentSnapshot likeDoc = await FirebaseFirestore.instance
          .collection('offers')
          .doc(offerId)
          .collection('likes')
          .doc(userId)
          .get();

      return likeDoc
          .exists; // إذا كانت الوثيقة موجودة، فهذا يعني أن المستخدم قد أعجب بالعرض
    } catch (e) {
      print("خطأ في التحقق من الإعجاب: $e");
      return false;
    }
  }

  Future<DocumentReference> addOffer({
    required String merchantId,
    required String storeName,
    required String description,
    required int duration,
    required List<String> images,
  }) async {
    try {
      // إنشاء معرف فريد للعرض بناءً على الوقت وبيانات المتجر
      var offerID =
          '${merchantId}_${storeName}_${DateTime.now().millisecondsSinceEpoch}';

      DocumentReference docRef = _firestore.collection('offers').doc(offerID);

      await docRef.set({
        'offerId': offerID, // تخزين offerID في البيانات لسهولة البحث
        'merchantId': merchantId,
        'storeName': storeName,
        'description': description,
        'duration': duration,
        'images': images,
        'createdAt': FieldValue.serverTimestamp(),
        'expiryDate': Timestamp.fromDate(
          DateTime.now().add(Duration(days: duration)),
        ),
        'isActive': true,
        'likes': 0,
      });

      _logger.i("✅ تم تخزين العرض بمعرف: $offerID");
      return docRef;
    } catch (e) {
      _logger.e("❌ خطأ في تخزين العرض: $e");
      throw Exception("❌ فشل حفظ العرض في Firestore");
    }
  }

  Future<void> addLikeToOffer(
      String offerId, String currentUserId, String username) async {
    try {
      DocumentReference likeRef = _firestore
          .collection('offers')
          .doc(offerId)
          .collection('likes')
          .doc(currentUserId); // كل مستخدم له إعجاب واحد فقط

      DocumentSnapshot likeSnapshot = await likeRef.get();

      if (likeSnapshot.exists) {
        throw Exception("❌ لقد أعجبت بهذا العرض بالفعل!");
      }

      await likeRef.set({
        'userId': currentUserId,
        'username': username, // إضافة اسم المستخدم
        'likedAt': FieldValue.serverTimestamp(),
      });

      // تحديث العدد العام للإعجابات
      DocumentReference offerRef = _firestore.collection('offers').doc(offerId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(offerRef);
        if (!snapshot.exists) {
          throw Exception("❌ العرض غير موجود!");
        }

        int currentLikes = snapshot['likes'] ?? 0;
        transaction.update(offerRef, {'likes': currentLikes + 1});
      });

      _logger.i("✅ تمت إضافة الإعجاب للعرض $offerId");
    } catch (e) {
      _logger.e("❌ فشل إضافة الإعجاب: $e");
      throw Exception("❌ لم يتم إضافة الإعجاب للعرض.");
    }
  }

  Future<void> addCommentToOffer(String offerId, String currentUserId,
      String comment, String username) async {
    try {
      DocumentReference commentRef = _firestore
          .collection('offers')
          .doc(offerId)
          .collection('comments')
          .doc(); // ينشئ معرف فريد للتعليق

      await commentRef.set({
        'userId': currentUserId,
        'username': username, // إضافة اسم المستخدم
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i("✅ تم إضافة تعليق للعرض $offerId");
    } catch (e) {
      _logger.e("❌ فشل إضافة التعليق: $e");
      throw Exception("❌ لم يتم إضافة التعليق للعرض.");
    }
  }
}
