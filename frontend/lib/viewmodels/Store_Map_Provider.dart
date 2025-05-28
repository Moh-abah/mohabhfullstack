import 'dart:async';

import 'package:ain_frontend/utils/SecureStorageHelper.dart';
import 'package:ain_frontend/viewmodels/Profile_Store_Provider.dart';
import 'package:ain_frontend/views/screens/Dialog/AddReviewDialog.dart';
import 'package:ain_frontend/views/widgets/ShimmerEffect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show
        BitmapDescriptor,
        CameraPosition,
        CameraUpdate,
        GoogleMapController,
        InfoWindow,
        LatLng,
        Marker,
        MarkerId;
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ain_frontend/models/store.dart';
import 'package:ain_frontend/models/feachReview_model.dart';
import 'package:provider/provider.dart';
import '../views/screens/ChatsMesseg.dart';

class MapState with ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  CameraPosition? _lastCameraPosition;
  final LatLng defaultLocation = const LatLng(24.7136, 46.6753);
  final Logger _logger = Logger();
  GoogleMapController? get mapController => _mapController;
  LatLng? get userLocation => _userLocation;
  LatLng get effectiveLocation => _userLocation ?? defaultLocation;
  CameraPosition? get lastCameraPosition => _lastCameraPosition;

  set mapController(GoogleMapController? controller) {
    if (_mapController != controller) {
      _mapController?.dispose();
      _mapController = controller;
      notifyListeners();
    }
  }

  void setUserLocation(LatLng location) {
    _userLocation = location;
    notifyListeners();
  }

  void setLastCameraPosition(CameraPosition position) {
    _lastCameraPosition = position;
    // لا داعي لاستدعاء notifyListeners() هنا لأن هذا لا يؤثر على واجهة المستخدم
  }

  Future<void> saveCurrentCameraPosition() async {
    if (_lastCameraPosition != null) {
      _logger.d('📍 تم حفظ موقع الكاميرا: $_lastCameraPosition');
    } else {
      _logger.w('⚠️ لم يتم تحريك الكاميرا بعد، لا يوجد موقع محفوظ');
    }
  }

  void restoreLastCameraPosition() {
    if (_mapController != null && _lastCameraPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(_lastCameraPosition!),
      );
    }
  }

  // void zoomIn() {
  //   _mapController?.animateCamera(CameraUpdate.zoomIn());
  // }

  // void zoomOut() {
  //   _mapController?.animateCamera(CameraUpdate.zoomOut());
  // }

  void moveToUserLocation() {
    if (_userLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
      );
    }
  }

  void moveToLocation(LatLng location, {double zoom = 15}) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, zoom),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class StoresState with ChangeNotifier {
  final Logger _logger = Logger();
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String? _error;
  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  Store? _selectedSearchStore;
  int? _selectedStoreId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Store> get stores => _stores;
  List<Store> get filteredStores => _filteredStores;
  Store? get selectedSearchStore => _selectedSearchStore;
  int? get selectedStoreId => _selectedStoreId;

  void setSelectedStoreId(int? id) {
    if (_selectedStoreId != id) {
      _selectedStoreId = id;
      notifyListeners();
    }
  }

  Future<String?> _getToken() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        _logger.e('Error: No token found in storage.');
        return null;
      }
      return token;
    } catch (e) {
      _logger.e('Error fetching token: $e');
      return null;
    }
  }

  Future<void> fetchStores() async {
    if (!_isLoading && _stores.isNotEmpty) {
      // إذا كانت المتاجر محملة بالفعل، لا داعي لإعادة التحميل
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? token = await _getToken();
      if (token == null) {
        _error = 'لم يتم العثور على رمز المصادقة';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _logger.d('Token retrieved successfully');

      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/stores/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          _stores = (response.data as List)
              .map((json) {
                try {
                  return Store.fromJson(json);
                } catch (e) {
                  _logger.e('Error parsing store: $e');
                  return null;
                }
              })
              .where((store) => store != null)
              .cast<Store>()
              .toList();

          // تصفية المتاجر التي لها إحداثيات صالحة فقط
          _stores = _stores.where((store) {
            try {
              double lat = double.parse(store.latitude.toString());
              double lng = double.parse(store.longitude.toString());
              return lat != 0 && lng != 0;
            } catch (e) {
              _logger.w('متجر بإحداثيات غير صالحة: ${store.name_store}');
              return false;
            }
          }).toList();

          _filteredStores = _stores;
          _error = null;
          _logger.i('تم تحميل ${_stores.length} متجر بنجاح');
        } else {
          _error = 'تنسيق استجابة غير متوقع: ${response.data.runtimeType}';
          _logger.e('Unexpected response format: ${response.data.runtimeType}');
        }
      } else {
        _error = 'فشل في جلب المتاجر: ${response.statusCode}';
        _logger.e('Failed to fetch stores: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'فشل في جلب المتاجر: $e';
      _logger.e('Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreRating(int storeId) async {
    try {
      String? token = await _getToken();
      if (token == null) {
        _error = 'لم يتم العثور على رمز المصادقة';
        notifyListeners();
        return;
      }

      _logger.d('جاري تحديث بيانات المتجر...');

      // إضافة تأخير قصير للتأكد من أن البيانات تم تحديثها في الخادم
      await Future.delayed(Duration(milliseconds: 500));

      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/stores/$storeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // طباعة البيانات المستلمة للتحقق
        _logger.d('البيانات المستلمة: ${response.data}');

        // تحديث بيانات المتجر في القائمة
        final updatedStore = Store.fromJson(response.data);

        // طباعة قيم التقييم للتحقق
        _logger.d('عدد التقييمات الجديد: ${updatedStore.ratingCount}');
        _logger.d('متوسط التقييم الجديد: ${updatedStore.ratingAverage}');

        // تحديث المتجر في قائمة المتاجر
        final storeIndex = _stores.indexWhere((store) => store.id == storeId);
        if (storeIndex != -1) {
          _stores[storeIndex] = updatedStore;

          // تحديث المتجر في قائمة المتاجر المفلترة أيضًا
          final filteredIndex =
              _filteredStores.indexWhere((store) => store.id == storeId);
          if (filteredIndex != -1) {
            _filteredStores[filteredIndex] = updatedStore;
          }

          // تحديث المتجر المحدد إذا كان هو نفسه
          if (_selectedStoreId == storeId) {
            setSelectedStoreId(storeId); // هذا سيؤدي إلى تحديث الواجهة
          }

          _logger.i('تم تحديث بيانات المتجر بنجاح');
        } else {
          _logger.w('المتجر غير موجود في القائمة');
        }

        // إخطار المستمعين بالتغييرات
        notifyListeners();
      } else {
        _error = 'فشل في تحديث بيانات المتجر: ${response.statusCode}';
        _logger.e('Failed to update store: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'خطأ في تحديث بيانات المتجر: $e';
      _logger.e('Error updating store: $e');
    }
  }

  void searchStores(String query) {
    if (query.isEmpty) {
      _filteredStores = _stores;
      _selectedSearchStore = null;
    } else {
      _filteredStores = _stores
          .where((store) =>
              //chage the search with catogreas
              store.subcategory.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (_filteredStores.isNotEmpty) {
        _selectedSearchStore = _filteredStores.first;
      } else {
        _selectedSearchStore = null;
      }
    }

    _logger.i('تم العثور على ${_filteredStores.length} متجر للبحث: "$query"');
    notifyListeners();
  }

  void clearSearch() {
    _filteredStores = _stores;
    _selectedSearchStore = null;
    notifyListeners();
  }

  Set<Marker> buildMarkers(
      BuildContext context, MapState mapState, Function(Store) onTap) {
    Set<Marker> markers = {};

    // إضافة علامة موقع المستخدم
    if (mapState.userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: mapState.userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'موقعك الحالي'),
        ),
      );
    }

    // تحسين أداء إنشاء الماركرز باستخدام مخزن مؤقت
    for (var store in _filteredStores) {
      try {
        double lat = double.parse(store.latitude.toString());
        double lng = double.parse(store.longitude.toString());

        // إنشاء ماركر مع تلميح وتحسين الأداء
        markers.add(
          Marker(
            markerId: MarkerId('store_${store.id}'),
            position: LatLng(lat, lng),
            onTap: () {
              // تعيين المتجر المحدد قبل استدعاء onTap لتحسين الأداء
              setSelectedStoreId(store.id);
              onTap(store);
            },
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: store.name_store,
              snippet: store.subcategory,
            ),
            // تحسين الأداء عن طريق تقليل إعادة الرسم
            consumeTapEvents: true,
            flat: true,
            zIndex: _selectedStoreId == store.id ? 2 : 1,
          ),
        );
      } catch (e) {
        _logger.e('خطأ في إضافة علامة للمتجر "${store.name_store}": $e');
      }
    }

    return markers;
  }
}

/*

class ReviewsState with ChangeNotifier {
  final Logger _logger = Logger();
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  //final fetchReviewService _reviewService = fetchReviewService();

  bool _isLoading = false;
  String? _error;
  List<FeachReview_models> _storeReviews = [];
  int? _currentStoreId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeachReview_models> get storeReviews => _storeReviews;
  int? get currentStoreId => _currentStoreId;

  Future<String?> _getToken() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        _logger.e('Error: No token found in storage.');
        return null;
      }
      return token;
    } catch (e) {
      _logger.e('Error fetching token: $e');
      return null;
    }
  }

  Future<void> fetchStoreReviews(int storeId) async {
    // إذا كانت المراجعات محملة بالفعل لنفس المتجر، لا داعي لإعادة التحميل
    if (_currentStoreId == storeId && _storeReviews.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? token = await _getToken();
      if (token == null) {
        _error = 'لم يتم العثور على رمز المصادقة';
        _isLoading = false;
        notifyListeners();
        return;
      }
      /*
      final String token = await tok().getToken;
      if (token == null) {
        _error = 'لم يتم العثور على رمز المصادقة';
        _isLoading = false;
        notifyListeners();
        return;
      }

      */

      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/reviews/stores/$storeId/reviews/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> reviewsJson = response.data;
        _storeReviews = reviewsJson
            .map((reviewJson) => FeachReview_models.fromJson(reviewJson))
            .toList();
        _currentStoreId = storeId;
        _logger.i('تم تحميل ${_storeReviews.length} تقييم للمتجر $storeId');
      } else {
        _error = 'فشل في جلب التقييمات: ${response.statusCode}';
        _logger.e('Failed to fetch reviews: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'خطأ في جلب التقييمات: $e';
      _logger.e('Error fetching reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearReviews() {
    _storeReviews = [];
    _currentStoreId = null;
    notifyListeners();
  }
}

*/

class UIState with ChangeNotifier {
  final Color primaryColor = const Color(0xFF3F51B5);
  final Color accentColor = const Color(0xFFFF4081);
  final Color textPrimaryColor = const Color(0xFF212121);
  final Color textSecondaryColor = const Color(0xFF757575);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  bool _isMapView = false;
  bool _isSearching = false;
  String _searchQuery = '';

  bool get isMapView => _isMapView;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  void toggleMapView() {
    _isMapView = !_isMapView;
    notifyListeners();
  }

  void setSearching(bool value) {
    if (_isSearching != value) {
      _isSearching = value;
      if (!value) {
        _searchQuery = '';
      }
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      notifyListeners();
    }
  }

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // void showSuccessSnackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           const Icon(Icons.check_circle_outline, color: Colors.white),
  //           const SizedBox(width: 8),
  //           Text(message),
  //         ],
  //       ),
  //       backgroundColor: Colors.green.shade600,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //     ),
  //   );
  // }
}

class StoreListProvider with ChangeNotifier {
  final Logger _logger = Logger();
  final MapState mapState = MapState();
  final StoresState storesState = StoresState();
  final ReviewsState reviewsState;
  final UIState uiState = UIState();

  String _currentUserName = 'مستخدم';
  String get currentUserName => _currentUserName;

  bool _sortByDistance = true;
  bool _sortByRating = false;
  final ratingUpdateController = StreamController<int>.broadcast();
  Stream<int> get ratingUpdateStream => ratingUpdateController.stream;
  // الألوان والثوابت - تفويض إلى UIState
  Color get primaryColor => uiState.primaryColor;
  Color get accentColor => uiState.accentColor;
  Color get textPrimaryColor => uiState.textPrimaryColor;
  Color get textSecondaryColor => uiState.textSecondaryColor;
  Color get backgroundColor => uiState.backgroundColor;
  Color get cardColor => uiState.cardColor;
  bool get sortByDistance => _sortByDistance;
  bool get sortByRating => _sortByRating;

  // تفويض الخصائص الأساسية
  GoogleMapController? get mapController => mapState.mapController;
  set mapController(GoogleMapController? controller) =>
      mapState.mapController = controller;

  bool get isLoading => storesState.isLoading;
  String? get error => storesState.error;
  List<Store> get stores => storesState.stores;
  List<Store> get filteredStores => storesState.filteredStores;
  List<FeachReview_models> get storeReviews => reviewsState.reviews;
  LatLng? get userLocation => mapState.userLocation;
  LatLng get defaultLocation => mapState.defaultLocation;
  bool get isMapView => uiState.isMapView;
  Store? get selectedSearchStore => storesState.selectedSearchStore;
  int? get getSelectedStoreId => storesState.selectedStoreId;
  CameraPosition? get lastCameraPosition => mapState.lastCameraPosition;

  StoreListProvider({required this.reviewsState}) {
    // استمع للتغييرات في الحالات الفرعية
    mapState.addListener(_notifyListeners);
    storesState.addListener(_notifyListeners);
    //reviewsState.addListener(_notifyListeners);
    uiState.addListener(_notifyListeners);
  }

  void setSortByDistance() {
    _sortByDistance = true;
    _sortByRating = false;
    notifyListeners();
  }

  void setSortByRating() {
    _sortByDistance = false;
    _sortByRating = true;
    notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  @override
  void dispose() {
    // إلغاء الاستماع للتغييرات
    mapState.removeListener(_notifyListeners);
    storesState.removeListener(_notifyListeners);
    reviewsState.removeListener(_notifyListeners);
    uiState.removeListener(_notifyListeners);

    // التخلص من الموارد
    mapState.dispose();
    ratingUpdateController.close();
    super.dispose();
  }

  Future<void> initializeLocationAndStores() async {
    try {
      await _getUserLocation();
      await storesState.fetchStores();
    } catch (e) {
      _logger.e('Initialization error: $e');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('تم رفض إذن الموقع');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('تم رفض إذن الموقع بشكل دائم');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      mapState.setUserLocation(LatLng(position.latitude, position.longitude));
      _logger.i('تم الحصول على موقع المستخدم: ${mapState.userLocation}');
    } catch (e) {
      _logger.e('خطأ في الحصول على موقع المستخدم: $e');
      // استخدام الموقع الافتراضي في حالة الفشل
      mapState.setUserLocation(mapState.defaultLocation);
    }
  }

  // تفويض الوظائف إلى الحالات الفرعية
  void toggleView() => uiState.toggleMapView();
  //void zoomIn() => mapState.zoomIn();
  //void zoomOut() => mapState.zoomOut();
  void moveToUserLocation() => mapState.moveToUserLocation();
  void moveToStore(Store store) {
    try {
      double lat = double.parse(store.latitude.toString());
      double lng = double.parse(store.longitude.toString());
      mapState.moveToLocation(LatLng(lat, lng));
      _logger.i('تم الانتقال إلى المتجر: ${store.name_store}');
    } catch (e) {
      _logger.e('خطأ في الانتقال إلى المتجر: $e');
    }
  }

  Future<void> saveCurrentCameraPosition() async {
    await mapState.saveCurrentCameraPosition();
  }

  void restoreLastCameraPosition() {
    mapState.restoreLastCameraPosition();
  }

  Future<void> retryLoading() async {
    await storesState.fetchStores();
  }

  void searchStores(String query) {
    storesState.searchStores(query);
    uiState.setSearchQuery(query);

    if (storesState.selectedSearchStore != null) {
      moveToStore(storesState.selectedSearchStore!);
    }
  }

  void onSearch(String query) {
    searchStores(query);
  }

  void clearSearch() {
    storesState.clearSearch();
    uiState.setSearchQuery('');
  }

  // double calculateDistance(Store store) {
  //   return storesState.calculateDistance(store, mapState.userLocation);
  // }

  // Set<Marker> getStoreMarkers(BuildContext context) {
  //   return storesState.buildMarkers(
  //       context, mapState, (store) => onStoreTapped(context, store));
  // }

  Set<Marker> buildMarkers(StoreListProvider provider, BuildContext context) {
    return storesState.buildMarkers(
        context, mapState, (store) => onStoreTapped(context, store));
  }

  Future<void> _loadStoreDataInBackground(int storeId) async {
    try {
      // تحميل البيانات بشكل متوازي
      await Future.wait([
        storesState.updateStoreRating(storeId),
        reviewsState.fetchStoreReviews(storeId),
      ]);

      // إخطار المستمعين بتحديث البيانات
      ratingUpdateController.add(storeId);
      notifyListeners();
    } catch (e) {
      _logger.e('خطأ في تحميل بيانات المتجر: $e');
    }
  }

  // وظائف التفاعل مع المتاجر
  Future<void> onStoreTapped(BuildContext context, Store store) async {
    try {
      // تعيين المتجر المحدد فوراً
      storesState.setSelectedStoreId(store.id);

      // تحريك الخريطة إلى المتجر
      double lat = double.parse(store.latitude.toString());
      double lng = double.parse(store.longitude.toString());
      mapState.moveToLocation(LatLng(lat, lng), zoom: 16);

      // حفظ موقع الكاميرا الحالي
      await saveCurrentCameraPosition();

      // عرض تفاصيل المتجر فوراً مع تحميل البيانات في الخلفية
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            // بدء تحميل البيانات في الخلفية
            _loadStoreDataInBackground(store.id);

            return buildStoreDetails(
              store,
              scrollController,
              context,
            );
          },
        ),
      ).then((_) {
        // استعادة موقع الكاميرا بعد إغلاق التفاصيل
        restoreLastCameraPosition();
      });
    } catch (e) {
      _logger.e('حدث خطأ عند فتح تفاصيل المتجر: $e');
    }
  }

  Future<void> firecreateChatwithoutrepetition(
    BuildContext context,
    int customerId,
    int ownerId,
    int storeId,
    String stoream,
    String currentUserName,
  ) async {
    try {
      // 1. البحث عن محادثة موجودة
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('customerId', isEqualTo: customerId)
          .where('ownerId', isEqualTo: ownerId)
          .where('storeId', isEqualTo: storeId)
          .limit(1)
          .get();

      String chatId;

      if (querySnapshot.docs.isNotEmpty) {
        // 2. في حالة وجود محادثة سابقة
        chatId = querySnapshot.docs.first.id;
        _logger.i('محادثة موجودة، سيتم النقل إليها');
      } else {
        // 3. لا توجد محادثة، إنشاء محادثة جديدة
        chatId =
            '${customerId}_111111111111111111111111${ownerId}_${DateTime.now().millisecondsSinceEpoch}';

        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'customerId': customerId,
          'ownerId': ownerId,
          'storeId': storeId,
          'storeame': stoream,
          'senderName': currentUserName,
          'status': 'active',
          'start_time': FieldValue.serverTimestamp(),
        });

        _logger.i('تم إنشاء محادثة جديدة');
      }

      final user = await SecureStorageHelper.getUser();
      _currentUserName = user?.name ?? 'مستخدم';

      storesState.setSelectedStoreId(storeId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsMesseg(chatId: chatId),
        ),
      );
    } catch (e) {
      _logger.e('فشل في إنشاء أو جلب المحادثة: $e');
      uiState.showErrorSnackBar(context, 'حدث خطأ ما!');
    }
  }

  // بناء واجهة المستخدم
  Widget buildStoreDetails(
      Store store, ScrollController scrollController, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildPullIndicator(),
            _buildStoreImageSection(store),
            const SizedBox(height: 24),
            _buildStoreInfoSection(store),
            const SizedBox(height: 24),
            _buildReviewsSection(context),
            const SizedBox(height: 24),
            buildActionButtons(store, context),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons(Store store, BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final customerId = await SecureStorageHelper.getUserId();
            if (customerId != null) {
              await firecreateChatwithoutrepetition(context, customerId,
                  store.ownerId, store.id, store.name_store, _currentUserName);
            } else {
              uiState.showErrorSnackBar(context, 'يجب تسجيل الدخول أولاً!');
            }
          },
          icon: const Icon(Icons.message_outlined),
          label: const Text('إرسال رسالة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AddReviewDialog(storeId: store.id);
              },
            );

            // إذا تمت إضافة التقييم بنجاح (result == true)
            if (result == true) {
              // تحديث واجهة المستخدم
              await reviewsState.fetchStoreReviews(store.id);
              await storesState.updateStoreRating(store.id);

              ratingUpdateController.add(store.id);

              // إعادة بناء الواجهة لعرض التحديثات
              notifyListeners();
            }
          },
          icon: Icon(Icons.rate_review_outlined, color: accentColor),
          label: Text('إضافة تقييم', style: TextStyle(color: accentColor)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: accentColor),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Consumer<ReviewsState>(
      builder: (context, state, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Icon(Icons.rate_review, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'التقييمات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: state.isLoading
                  ? _buildShimmerLoader()
                  : state.reviews.isEmpty
                      ? _buildNoReviewsMessage()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: state.reviews.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildReviewItem(state.reviews[index]);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 100, color: Colors.grey[400]),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 150, color: Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNoReviewsMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, color: textSecondaryColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'لا يوجد تقييمات بعد',
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'كن أول من يضيف تقييمًا!',
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(FeachReview_models review) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    review.customerName.isNotEmpty
                        ? review.customerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: index < review.rating
                                ? Colors.amber
                                : Colors.grey,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  review.createdAt,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                color: textSecondaryColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPullIndicator() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildStoreImageSection(Store store) {
    return Hero(
      tag: 'store-image-${store.id}',
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: store.images.isNotEmpty
              ? Image(
                  image: NetworkImageWithRetry(
                      'https://ucarecdn.com/${store.images}/-/preview/'),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: backgroundColor,
                    child: Icon(
                      Icons.store,
                      size: 80,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                )
              : Container(
                  color: backgroundColor,
                  child: Icon(
                    Icons.store,
                    size: 80,
                    color: primaryColor.withOpacity(0.5),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStoreHeader(Store store) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            store.name_store,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        _buildRatingBadge(store),
      ],
    );
  }

  Widget _buildStoreInfoSection(Store store) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoreHeader(store),
          const SizedBox(height: 20),
          _buildInfoRow(
              Icons.person_outline, 'المسؤول', store.owner_name, primaryColor),

          // استخدام StreamBuilder فقط لصف التقييمات
          StreamBuilder<int>(
            stream: ratingUpdateStream,
            builder: (context, snapshot) {
              // إذا كان هناك تحديث جاري للمتجر الحالي
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.data == store.id) {
                // عرض تأثير Shimmer أثناء التحديث
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return _buildShimmerEffect(
                      _buildInfoRow(Icons.star_outline, 'التقييمات',
                          '${store.ratingCount} تقييم', Colors.amber.shade700),
                    );
                  },
                );
              }
              // إذا كان هناك تحديث للمتجر الحالي
              if (snapshot.hasData && snapshot.data == store.id) {
                // البحث عن المتجر المحدث في القائمة
                final updatedStore = storesState.stores.firstWhere(
                  (s) => s.id == store.id,
                  orElse: () => store,
                );

                return _buildInfoRow(Icons.star_outline, 'التقييمات',
                    '${updatedStore.ratingCount} تقييم', Colors.amber.shade700);
              }

              // استخدام البيانات الحالية
              return _buildInfoRow(Icons.star_outline, 'التقييمات',
                  '${store.ratingCount} تقييم', Colors.amber.shade700);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(Widget child) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: child,
    );
  }

  Widget _buildRatingBadge(Store store) {
    return StreamBuilder<int>(
      stream: ratingUpdateStream,
      builder: (context, snapshot) {
        // إذا كان هناك تحديث جاري للمتجر الحالي
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.data == store.id) {
          // عرض تأثير Shimmer أثناء التحديث
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return _buildShimmerEffect(_buildRatingBadge(store));
            },
          );
        }
        // إذا كان هناك تحديث للمتجر الحالي
        if (snapshot.hasData && snapshot.data == store.id) {
          // البحث عن المتجر المحدث في القائمة
          final updatedStore = storesState.stores.firstWhere(
            (s) => s.id == store.id,
            orElse: () => store,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 18, color: Colors.amber.shade700),
                const SizedBox(width: 4),
                Text(
                  '${updatedStore.ratingAverage}',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // استخدام البيانات الحالية
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 18, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(
                '${store.ratingAverage}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// استخراج محتوى الشارة إلى دالة منفصلة لتجنب تكرار الكود
  Widget _buildRatingBadgeContent(Store store) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 4),
          Text(
            '${store.ratingAverage ?? 'جديد'}',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
