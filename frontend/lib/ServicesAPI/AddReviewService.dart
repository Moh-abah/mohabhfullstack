import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/feachReview_model.dart';

class Addreviewservice {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  Addreviewservice({required Dio dio, required FlutterSecureStorage storage})
      : _dio = dio,
        _storage = storage;

  Future<String?> _getToken() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> submitReview(int storeId, int rating, String comment) async {
    print('🔵 [submitReview] - بدء إرسال التقييم للمتجر ID: $storeId');
    print('⭐ التقييم: $rating');
    print('💬 التعليق: $comment');

    String? token = await _getToken();
    if (token == null) {
      print('❌ [submitReview] - فشل في جلب التوكن. لم يتم العثور عليه.');
      throw Exception('No token found.');
    }

    try {
      final response = await _dio.post(
        'https://myapptestes.onrender.com/api/reviews/store/$storeId/add-evaluation/',
        data: {
          'rating': rating,
          'comment': comment,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('📩 [submitReview] - استجابة الخادم: ${response.statusCode}');
      print('📄 [submitReview] - محتوى الاستجابة: ${response.data}');

      if (response.statusCode == 201) {
        print('✅ [submitReview] - التقييم تم إضافته بنجاح.');
      } else {
        print(
            '⚠️ [submitReview] - فشل في إضافة التقييم. رمز الحالة: ${response.statusCode}');
        print(response.data);

        if (response.data != null &&
            response.data.contains('لقد قمت بتقييم هذا المتجر مسبقًا')) {
          // عرض رسالة خطأ للمستخدم
        }

        throw Exception("Failed to add review.");
      }
    } catch (e) {
      print('❌ [submitReview] - خطأ أثناء إرسال التقييم: $e');
      throw Exception('Error sending review: $e');
    }
  }

  Future<FeachReview_models> updateReview(
      int reviewId, String comment, int rating, int storeId) async {
    try {
      String? token = await _getToken(); // جلب التوكن

      final response = await _dio.put(
        'http://myapptestes.onrender.com/api/store/$storeId/edit-evaluation/$reviewId/',
        data: json.encode({
          'comment': comment,
          'rating': rating,
        }),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return FeachReview_models.fromJson(
            response.data); // استخدم response.data بدلًا من response.body
      } else {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
