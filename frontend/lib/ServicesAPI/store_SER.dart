import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreService {
  final Dio _dio = Dio();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // استبدل بعنوان API الخاص بك

  // دالة لجلب التوكن
  Future<String?> _getToken() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      return token;
    } catch (e) {
      return null;
    }
  }

  // جلب بيانات المتجر باستخدام الـ userId
  Future<String?> fetchStoreByUserId(int storeId) async {
    String? token = await _getToken();
    if (token == null) {
      throw Exception('No token found.');
    }

    try {
      final response = await _dio.get(
        'https://myapptestes.onrender.com/api/stores/stordata/$storeId/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        // تحقق من نوع البيانات المسترجعة
        if (response.data is Map<String, dynamic>) {
          // إذا كانت الاستجابة عبارة عن Map، قم باستخراج الاسم
          var storeName = response.data['name_store'];
          return storeName;
        } else if (response.data is List) {
          // إذا كانت الاستجابة عبارة عن List، قم بتحليل أول عنصر في القائمة
          var firstStore =
              response.data[0]; // على افتراض أن المتجر هو أول عنصر في القائمة
          var storeName = firstStore['name_store'];
          return storeName;
        } else {
          throw Exception('الاستجابة ليست من نوع Map أو List');
        }
      } else {
        throw Exception('فشل في جلب بيانات المتجر');
      }
    } catch (e) {
      throw Exception('Error fetching store data: $e');
    }
  }
}
