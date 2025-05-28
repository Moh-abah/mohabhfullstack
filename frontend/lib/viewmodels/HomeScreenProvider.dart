// home_screen_provider.dart
// مزود الحالة لشاشة الصفحة الرئيسية "HomeScreen" مع تعليقات باللغة العربية

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../database_helper.dart';
import '../models/user.dart';
import 'Home_Screen_State.dart'; // يستورد حالات مختلفة مُنظمة

class HomeScreenProvider with ChangeNotifier {
  final AppDatabase _database; // قاعدة البيانات المحلية
  final Logger _logger = Logger(); // مسجل الأحداث والأخطاء

  // حالات المكونات المختلفة المستخدمة في الصفحة الرئيسية
  final ConnectivityState connectivityState;
  final UserState userState;
  final FilterState filterState;
  final OffersState offersState;
  final InteractionsState interactionsState;
  final UIState uiState;

  // خصائص مُجمعة لعرض الحالة العامة
  bool get isLoading =>
      connectivityState.isLoading ||
      userState.isLoading ||
      offersState.isLoading ||
      interactionsState.isLoading;

  bool get isLoadingMore => offersState.isLoadingMore;
  bool get hasMoreOffers => offersState.hasMoreOffers;
  bool get isOnline => connectivityState.isOnline;

  // خصائص التصفية
  bool get activeOnly => filterState.activeOnly;
  bool get orderByDate => filterState.orderByDate;
  bool get orderByExpiry => filterState.orderByExpiry;
  bool get descending => filterState.descending;

  // بيانات المستخدم
  User? get currentUser => userState.currentUser;
  bool get isMerchant => userState.isMerchant;

  // خصائص واجهة المستخدم
  int get currentIndex => uiState.currentIndex;
  Color get primaryColor => uiState.primaryColor;
  Color get accentColor => uiState.accentColor;
  Color get backgroundColor => uiState.backgroundColor;
  Color get shadowColor => uiState.backgroundColor;
  Color get textDarkColor => uiState.textDarkColor;
  Color get cardColor => uiState.cardColor;

  // العروض المخبأة ومُشغل التدفق
  List<Offer> get cachedOffers => offersState.cachedOffers;
  Stream<List<Offer>> get offersStream => offersState.offersStream;

  // مُتحكم التعليقات من حالة التفاعلات
  TextEditingController get commentController =>
      interactionsState.commentController;

  HomeScreenProvider(this._database)
      : connectivityState = ConnectivityState(),
        userState = UserState(),
        filterState = FilterState(),
        offersState = OffersState(_database),
        interactionsState = InteractionsState(_database),
        uiState = UIState() {
    // ربط المستمعين لإعلام HomeScreenProvider بأي تغيير
    connectivityState.addListener(_notifyListeners);
    userState.addListener(_notifyListeners);
    filterState.addListener(_notifyListeners);
    offersState.addListener(_notifyListeners);
    interactionsState.addListener(_notifyListeners);
    uiState.addListener(_notifyListeners);

    // تهيئة البيانات الأولية
    _init();
  }

  /// إعلام المستمعين بالتغيير
  void _notifyListeners() {
    notifyListeners();
  }

  /// التحقق من العروض المنتهية وإبطال تفعيلها
  Future<void> checkAndDeactivateExpiredOffers() async {
    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final expiry = (data['expiryDate'] as Timestamp).toDate();
        if (expiry.isBefore(now)) {
          await FirebaseFirestore.instance
              .collection('offers')
              .doc(doc.id)
              .update({'isActive': false});
          _logger.i('✅ تم تعطيل العرض ${doc.id} لأنه منتهي');
        }
      }
    } catch (e) {
      _logger.e('❌ خطأ أثناء التحقق من العروض المنتهية: $e');
    }
  }

  /// التهيئة الأولية: تحميل البيانات ومزامنة الحالة
  Future<void> _init() async {
    _logger.i('بدء تهيئة HomeScreenProvider');
    try {
      // تحميل بيانات المستخدم
      await userState.loadUserData();
      // إبطال العروض المنتهية
      await checkAndDeactivateExpiredOffers();
      // تحميل العروض المبدئية
      await offersState.loadInitialOffers(
        activeOnly: filterState.activeOnly,
        orderByDate: filterState.orderByDate,
        orderByExpiry: filterState.orderByExpiry,
        descending: filterState.descending,
      );
      // عند العودة للاتصال، مزامنة الإجراءات دون اتصال
      connectivityState.addListener(() {
        if (connectivityState.isOnline) {
          interactionsState.syncOfflineActions();
        }
      });
    } catch (e) {
      _logger.e('خطأ في تهيئة الموفر: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // أساليب التنقل وتحديث الفلاتر
  // ──────────────────────────────────────────────────────────────────────────

  /// تغيير التبويب الحالي
  void setCurrentIndex(int index) {
    uiState.setCurrentIndex(index);
  }

  /// تحديث خيارات التصفية وإعادة تحميل العروض
  void updateFilter({
    bool? activeOnly,
    bool? orderByDate,
    bool? orderByExpiry,
    bool? descending,
  }) {
    filterState.updateFilter(
      activeOnly: activeOnly,
      orderByDate: orderByDate,
      orderByExpiry: orderByExpiry,
      descending: descending,
    );
    refreshOffers();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // أساليب إدارة العروض
  // ──────────────────────────────────────────────────────────────────────────

  /// جلب العروض من Firestore مع التصفية
  Stream<QuerySnapshot> getFilteredOffers() {
    return offersState.getFilteredOffers(
      activeOnly: filterState.activeOnly,
      orderByDate: filterState.orderByDate,
      orderByExpiry: filterState.orderByExpiry,
      descending: filterState.descending,
    );
  }

  /// تحميل المزيد من العروض
  Future<void> loadMoreOffers() async {
    await offersState.loadMoreOffers(
      activeOnly: filterState.activeOnly,
      orderByDate: filterState.orderByDate,
      orderByExpiry: filterState.orderByExpiry,
      descending: filterState.descending,
    );
  }

  /// تحديث العروض الحالية وفق الفلاتر
  Future<void> refreshOffers() async {
    await offersState.refreshOffers(
      activeOnly: filterState.activeOnly,
      orderByDate: filterState.orderByDate,
      orderByExpiry: filterState.orderByExpiry,
      descending: filterState.descending,
    );
  }

  /// تعليم عرض كمشاهد وتحميل المزيد إذا متصل
  Future<void> markOfferAsViewed(String offerId) async {
    await offersState.markOfferAsViewed(offerId);
    if (connectivityState.isOnline) {
      loadMoreOffers();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // روابط التفاعلات: التعليقات والإعجابات
  // ──────────────────────────────────────────────────────────────────────────

  /// دفق التعليقات الحي عند الاتصال
  Stream<QuerySnapshot>? getOfferComments(String offerId) {
    return interactionsState.getOfferComments(
        offerId, connectivityState.isOnline);
  }

  /// جلب التعليقات المخزنة دون اتصال
  Future<List<OfferComment>> getOfflineComments(String offerId) {
    return interactionsState.getOfflineComments(offerId);
  }

  /// التحقق إذا يمكن عرض التعليقات الحية
  bool canShowOnlineComments(String offerId) {
    return connectivityState.isOnline;
  }

  /// التحقق من حالة الإعجاب بالعرض
  bool isOfferLiked(String offerId) {
    return offersState.isOfferLiked(offerId);
  }

  /// معالجة إعجاب المستخدم بالعرض
  Future<void> likeOffer(String offerId, BuildContext context) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await interactionsState.likeOffer(
      offerId,
      currentUser!.id.toString(),
      currentUser!.name,
      connectivityState.isOnline,
      offersState.updateLikedStatus,
      context,
    );
  }

  /// إضافة تعليق من المستخدم
  Future<void> addComment(String offerId, BuildContext context) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await interactionsState.addComment(
      offerId,
      currentUser!.id.toString(),
      currentUser!.name,
      connectivityState.isOnline,
      context,
    );
  }

  /// جلب معرف التاجر لعروض معينة
  Future<String?> getMerchantIdForOffer(String offerId) async {
    return offersState.getMerchantIdForOffer(offerId);
  }

  @override
  void dispose() {
    // إزالة المستمعين وتحرير الموارد
    connectivityState.removeListener(_notifyListeners);
    userState.removeListener(_notifyListeners);
    filterState.removeListener(_notifyListeners);
    offersState.removeListener(_notifyListeners);
    interactionsState.removeListener(_notifyListeners);
    uiState.removeListener(_notifyListeners);

    connectivityState.dispose();
    userState.dispose();
    filterState.dispose();
    offersState.dispose();
    interactionsState.dispose();
    uiState.dispose();
    super.dispose();
  }
}
