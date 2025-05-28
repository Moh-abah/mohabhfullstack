import 'package:ain_frontend/models/store.dart';
import 'package:ain_frontend/utils/SecureStorageHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/feachReview_model.dart';
import '../models/user.dart';

class ProfilServiceApi {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger();

  List<Store> sstores = [];
  List<FeachReview_models> storeReviewss = [];
  User? marchintID;
  List<Store> _filteredStores = [];
  List<Store> get filteredStores => _filteredStores;
  String? get error => _error;
  String? _error;

  ProfilServiceApi({required Dio dio, required FlutterSecureStorage storage})
      : _dio = dio,
        _storage = storage;

  List<Store> get stores => sstores;
  List<FeachReview_models> get storeReviews => storeReviewss;
  User? get currentUser => marchintID;

  Future<void> _loadUserData() async {
    try {
      marchintID = await SecureStorageHelper.getUser();

      debugPrint('تم تحميل بيانات المستخدم: ${marchintID?.id}');
    } catch (e) {
      _logger.e("User data loading error: $e");
    }
  }

  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'jwt_token');
    } catch (e) {
      _logger.e("Token fetch error: $e");
      return null;
    }
  }

  Future<void> fetchStoreReviews(int storeId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/reviews/stores/$storeId/reviews/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        storeReviewss = (response.data as List)
            .map((json) => FeachReview_models.fromJson(json))
            .whereType<FeachReview_models>()
            .toList();
        debugPrint('تم جلب التعليقات بنجاح');
      } else {
        _logger.e('فشل في جلب التعليقات: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e("Reviews fetch error: $e");
    }
  }

  Future<Store?> fetchStoreById(int storeId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/stores/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<Store> allStores = (response.data as List)
            .map((json) => Store.fromJson(json))
            .whereType<Store>()
            .toList();

        final matchedStores = allStores.where((s) => s.id == storeId);
        Store? store = matchedStores.isNotEmpty ? matchedStores.first : null;

        if (store != null) {
          await fetchStoreReviews(store.id);
        }

        return store;
      } else {
        _logger.e('فشل في جلب المتجر: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e("Store fetch by id error: $e");
      return null;
    }
  }

  Future<void> fetchStores() async {
    try {
      await _loadUserData(); // تأكد من تحميل بيانات المستخدم أولاً

      final token = await _getToken();
      if (token == null) throw Exception('No authentication token');

      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/stores/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        debugPrint('Response data: ${response.data}');

        final List<Store> allStores = (response.data as List)
            .map((json) => Store.fromJson(json))
            .whereType<Store>()
            .toList();

        if (marchintID?.id != null) {
          sstores = allStores
              .where((store) => store.ownerId == marchintID!.id)
              .toList();

          // جلب التعليقات للمتاجر التي تم جلبها (أو متجر واحد حسب الحاجة)
          if (sstores.isNotEmpty) {
            fetchStoreReviews(sstores[0].id); // جلب التعليقات للمتجر الأول
          }
        } else {
          sstores = [];
          _error = 'لم يتم العثور على المستخدم الحالي';
        }

        _filteredStores = stores;
        _error = null;
      } else {
        _error = 'فشل في جلب المتاجر: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب المتاجر: ${e.toString()}';
      _logger.e(e);
    }
  }
}
