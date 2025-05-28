import 'package:flutter/material.dart';
import 'package:ain_frontend/models/store.dart';
import 'package:ain_frontend/models/feachReview_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../ServicesFireBase/profilService.dart';
import '../ServicesAPI/profil_Service.dart';

abstract class BaseState with ChangeNotifier {
  final Logger _logger = Logger();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Logger get logger => _logger;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

/*

// Store information state
class StoreState extends BaseState {
  final ProfilServiceApi _profilService;
  Store? _store;

  Store? get store => _store;

  StoreState({
    required ProfilServiceApi profilService,
  }) : _profilService = profilService;

  Future<void> fetchStoreData() async {
    setLoading(true);
    clearError();

    logger.d('StoreState: بدء جلب بيانات المتجر');

    try {
      await _profilService.fetchStores();

      if (_profilService.stores.isNotEmpty) {
        _store = _profilService.stores.first;
        logger.i('StoreState: تم تحميل المتجر: ${_store!.name_store}');
      } else {
        logger.w('StoreState: لا توجد متاجر متاحة');
      }
    } catch (e) {
      logger.e('StoreState: خطأ في جلب بيانات المتجر: $e');
      setError('فشل في تحميل بيانات المتجر: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchStoreDatawithid(int storeId) async {
    setLoading(true);
    clearError();

    logger.d('StoreState: بدء جلب بيانات المتجر');

    try {
      await _profilService.fetchStoreById(storeId);

      if (_profilService.stores.isNotEmpty) {
        _store = _profilService.stores.first;
        logger.i('StoreState: تم تحميل المتجر: ${_store!.name_store}');
      } else {
        logger.w('StoreState: لا توجد متاجر متاحة');
      }
    } catch (e) {
      logger.e('StoreState: خطأ في جلب بيانات المتجر: $e');
      setError('فشل في تحميل بيانات المتجر: $e');
    } finally {
      setLoading(false);
    }
  }
}

*/
class StoreState extends BaseState {
  final ProfilServiceApi _profilService;
  Store? _store;

  Store? get store => _store;

  StoreState({
    required ProfilServiceApi profilService,
  }) : _profilService = profilService;

  Future<void> fetchStoreData() async {
    setLoading(true);
    clearError();

    logger.d('StoreState: بدء جلب بيانات المتجر');

    try {
      await _profilService.fetchStores();

      if (_profilService.stores.isNotEmpty) {
        _store = _profilService.stores.first;
        logger.i('StoreState: تم تحميل المتجر: ${_store!.name_store}');
      } else {
        logger.w('StoreState: لا توجد متاجر متاحة');
      }
    } catch (e) {
      logger.e('StoreState: خطأ في جلب بيانات المتجر: $e');
      setError('فشل في تحميل بيانات المتجر: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchStoreDatawithid(int storeId) async {
    setLoading(true);
    clearError();

    logger.d('StoreState: بدء جلب بيانات المتجر');

    try {
      await _profilService.fetchStoreById(storeId);

      if (_profilService.stores.isNotEmpty) {
        _store = _profilService.stores.first;
        logger.i('StoreState: تم تحميل المتجر: ${_store!.name_store}');
      } else {
        logger.w('StoreState: لا توجد متاجر متاحة');
      }
    } catch (e) {
      logger.e('StoreState: خطأ في جلب بيانات المتجر: $e');
      setError('فشل في تحميل بيانات المتجر: $e');
    } finally {
      setLoading(false);
    }
  }
}

// Reviews state
// تعديل فئة ReviewsState في ملف Profile_Store_Provider.dart
class ReviewsState extends BaseState {
  final ProfilServiceApi _profilService;

  // كاش لكل تقييمات متجر حسب الـ storeId
  final Map<int, List<FeachReview_models>> _reviewsCache = {};

  int? _currentStoreId;
  List<FeachReview_models> get reviews =>
      _currentStoreId != null ? (_reviewsCache[_currentStoreId!] ?? []) : [];

  ReviewsState({
    required ProfilServiceApi profilService,
  }) : _profilService = profilService;

  Future<void> fetchStoreReviews(int storeId) async {
    // تعيين المتجر الحالي
    _currentStoreId = storeId;

    // بدء التحميل
    setLoading(true);
    clearError();
    notifyListeners();

    logger.d('ReviewsState: بدء جلب تقييمات المتجر $storeId');

    try {
      // جلب التقييمات من السيرفر دائمًا لضمان تحديث البيانات
      await _profilService.fetchStoreReviews(storeId);

      // تحديث الكاش بالبيانات الجديدة
      _reviewsCache[storeId] = _profilService.storeReviews;

      logger.i(
          'ReviewsState: تم تحميل ${_profilService.storeReviews.length} تقييم من السيرفر');
    } catch (e) {
      logger.e('ReviewsState: خطأ في جلب التقييمات: $e');
      setError('فشل في تحميل التقييمات: $e');
    } finally {
      setLoading(false);
      notifyListeners(); // إخطار المستمعين بالتغييرات
    }
  }

  // دالة لمسح كاش متجر معين (تستخدم عند الحاجة لإعادة تحميل البيانات)
  void clearStoreCache(int storeId) {
    if (_reviewsCache.containsKey(storeId)) {
      _reviewsCache.remove(storeId);
      logger.i('ReviewsState: تم مسح كاش التقييمات للمتجر $storeId');

      if (_currentStoreId == storeId) {
        notifyListeners();
      }
    }
  }

  // دالة لمسح جميع الكاش
  void clearAllCache() {
    _reviewsCache.clear();
    logger.i('ReviewsState: تم مسح جميع كاش التقييمات');
    notifyListeners();
  }
}

// Offers state
class OffersState extends BaseState {
  final profilServiceFirebase _firestoreService;
  int _activeOffers = 0;
  int _totalLikes = 0;

  int get activeOffers => _activeOffers;
  int get totalLikes => _totalLikes;

  OffersState({
    required profilServiceFirebase firestoreService,
  }) : _firestoreService = firestoreService;

  Future<void> fetchMerchantStats(String merchantId) async {
    setLoading(true);
    clearError();

    logger.d('OffersState: بدء جلب إحصائيات التاجر $merchantId');

    try {
      final stats = await _firestoreService.getMerchantOfferStats(merchantId);
      _activeOffers = stats['activeOffers'];
      _totalLikes = stats['totalLikes'];
      logger.i('OffersState: تم تحميل الإحصائيات: $stats');
    } catch (e) {
      logger.e('OffersState: خطأ في جلب الإحصائيات: $e');
      setError('فشل في تحميل إحصائيات العروض: $e');
    } finally {
      setLoading(false);
    }
  }

  Stream<QuerySnapshot> getActiveOffers(String merchantId) {
    return _firestoreService.getMerchantFilteredOffers(
      merchantId: merchantId,
      activeOnly: true,
      orderByExpiry: true,
      descending: false,
    );
  }

  Stream<QuerySnapshot> getInactiveOffers(String merchantId) {
    return _firestoreService.getMerchantFilteredOffers(
      merchantId: merchantId,
      activeOnly: false,
      orderByExpiry: true,
      descending: true,
    );
  }

  Stream<QuerySnapshot> getOfferComments(String offerId) {
    return _firestoreService.getOfferComments(offerId);
  }
}

// User state
class UserState extends BaseState {
  final profilServiceFirebase _firestoreService;
  String? _currentUserId;
  String? _currentUsername;

  String? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername;

  UserState({
    required profilServiceFirebase firestoreService,
  }) : _firestoreService = firestoreService;

  Future<void> loadUserData() async {
    setLoading(true);
    clearError();

    logger.d('UserState: بدء تحميل بيانات المستخدم');

    try {
      await _firestoreService.loadUserData();
      _currentUserId = _firestoreService.currentUserId?.toString();
      _currentUsername = _firestoreService.currentUsername;
      logger.i('UserState: تم تحميل بيانات المستخدم: $_currentUsername');
    } catch (e) {
      logger.e('UserState: خطأ في تحميل بيانات المستخدم: $e');
      setError('فشل في تحميل بيانات المستخدم: $e');
    } finally {
      setLoading(false);
    }
  }

  // Future<void> addComment(String offerId, String comment) async {
  //   if (_currentUserId == null || _currentUsername == null) {
  //     setError('يجب تسجيل الدخول لإضافة تعليق');
  //     return;
  //   }

  //   setLoading(true);
  //   clearError();

  //   try {
  //     await _firestoreService.addCommentToOffer(
  //       offerId,
  //       _currentUserId!,
  //       _currentUsername!,
  //       comment,
  //     );
  //     logger.i('UserState: تم إضافة التعليق بنجاح');
  //   } catch (e) {
  //     logger.e('UserState: خطأ في إضافة التعليق: $e');
  //     setError('فشل في إضافة التعليق: $e');
  //   } finally {
  //     setLoading(false);
  //   }
  // }
}

// UI state
class UIState extends BaseNotifier {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  // App colors
  final Color primaryColor = const Color(0xFF3F51B5);
  final Color accentColor = const Color(0xFFFF4081);
  final Color textPrimaryColor = const Color(0xFF212121);
  final Color textSecondaryColor = const Color(0xFF757575);
  final Color backgroundColor = Colors.white;
  final Color cardColor = Colors.white;

  void setCurrentTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }
}

// Simple notifier without loading/error states
class BaseNotifier with ChangeNotifier {
  final Logger _logger = Logger();
  Logger get logger => _logger;
}

// Main provider that combines all states
class ProfileStoreProvider with ChangeNotifier {
  final int merchantId;
  final int? storeId; // اختياري
  final StoreState storeState;
  final ReviewsState reviewsState;
  final OffersState offersState;
  final UserState userState;
  final UIState uiState;

  // Expose colors from UIState
  Color get primaryColor => uiState.primaryColor;
  Color get accentColor => uiState.accentColor;
  Color get textPrimaryColor => uiState.textPrimaryColor;
  Color get textSecondaryColor => uiState.textSecondaryColor;
  Color get backgroundColor => uiState.backgroundColor;
  Color get cardColor => uiState.cardColor;

  // Expose data from states
  Store? get store => storeState.store;
  List<FeachReview_models> get reviews => reviewsState.reviews;
  int get activeOffers => offersState.activeOffers;
  int get totalLikes => offersState.totalLikes;
  String? get currentUserId => userState.currentUserId;
  String? get currentUsername => userState.currentUsername;
  int get currentTabIndex => uiState.currentTabIndex;

  // Loading states
  bool get isLoading =>
      storeState.isLoading ||
      reviewsState.isLoading ||
      offersState.isLoading ||
      userState.isLoading;

  // Error states
  String? get error {
    if (storeState.error != null) return storeState.error;
    if (reviewsState.error != null) return reviewsState.error;
    if (offersState.error != null) return offersState.error;
    if (userState.error != null) return userState.error;
    return null;
  }

  ProfileStoreProvider({
    required this.merchantId,
    this.storeId,
    required Dio dio,
    required FlutterSecureStorage storage,
  })  : storeState = StoreState(
          profilService: ProfilServiceApi(dio: dio, storage: storage),
        ),
        reviewsState = ReviewsState(
          profilService: ProfilServiceApi(dio: dio, storage: storage),
        ),
        offersState = OffersState(
          firestoreService: profilServiceFirebase(),
        ),
        userState = UserState(
          firestoreService: profilServiceFirebase(),
        ),
        uiState = UIState() {
    // Listen to changes in child states
    storeState.addListener(_notifyListeners);
    reviewsState.addListener(_notifyListeners);
    offersState.addListener(_notifyListeners);
    userState.addListener(_notifyListeners);
    uiState.addListener(_notifyListeners);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  // Initialize all data
  Future<void> initialize() async {
    await Future.wait([
      //storeState.fetchStoreDatawithid(storeId!),
      userState.loadUserData(),
      storeState.fetchStoreData(),
      offersState.fetchMerchantStats(merchantId.toString()),
    ]);

    // After store data is loaded, fetch reviews
    if (storeState.store != null) {
      await reviewsState.fetchStoreReviews(storeState.store!.id);
    }
  }

  // Set current tab
  void setCurrentTabIndex(int index) {
    uiState.setCurrentTabIndex(index);
  }

  // Refresh reviews
  Future<void> refreshReviews() async {
    if (storeState.store != null) {
      await reviewsState.fetchStoreReviews(storeState.store!.id);
    }
  }

  // Add comment
  // Future<void> addComment(String offerId, String comment) async {
  //   await userState.addComment(offerId, comment);
  // }

  // Get streams
  Stream<QuerySnapshot> getActiveOffers() {
    return offersState.getActiveOffers(merchantId.toString());
  }

  Stream<QuerySnapshot> getInactiveOffers() {
    return offersState.getInactiveOffers(merchantId.toString());
  }

  Stream<QuerySnapshot> getOfferComments(String offerId) {
    return offersState.getOfferComments(offerId);
  }

  @override
  void dispose() {
    // Remove listeners
    storeState.removeListener(_notifyListeners);
    reviewsState.removeListener(_notifyListeners);
    offersState.removeListener(_notifyListeners);
    userState.removeListener(_notifyListeners);
    uiState.removeListener(_notifyListeners);

    // Dispose states
    storeState.dispose();
    reviewsState.dispose();
    offersState.dispose();
    userState.dispose();
    uiState.dispose();

    super.dispose();
  }
}
