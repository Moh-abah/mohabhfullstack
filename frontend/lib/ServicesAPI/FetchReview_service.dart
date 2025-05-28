import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/feachReview_model.dart';

class fetchReviewService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // الحصول على التوكن من التخزين

  Future<String?> _getToken() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        print('Error: No token found in storage.');
        return null;
      }

      print('Retrieved Token: $token'); // طباعة التوكن للتحقق
      return token;
    } catch (e) {
      print('Error fetching token: $e');
      return null;
    }
  }

  // دالة جلب المراجعات للمتجر
  Future<void> fetchStoreReviews(int storeId) async {
    try {
      // جلب التوكن
      String? token = await _getToken();
      if (token == null) {
        throw 'No token found. Please log in.';
      }

      // إرسال طلب GET لجلب المراجعات
      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/reviews/stores/$storeId/reviews/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // التحقق من حالة الاستجابة
      if (response.statusCode == 200) {
        List<dynamic> reviewsJson = response.data;
        var fetchedReviews = reviewsJson
            .map((reviewJson) => FeachReview_models.fromJson(reviewJson))
            .toList();
        // عرض المراجعات المستلمة
        print('مراجعات المتجر: $fetchedReviews');
      } else {
        print('فشل في جلب المراجعات: ${response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ في جلب المراجعات: $e');
    }
  }
}
