import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/SecureStorageHelper.dart';

class finalLoginService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // تسجيل الدخول
  Future<Map<String, dynamic>?> login(
      String usernameOrPhone, String password) async {
    final url =
        Uri.parse('https://myapptestes.onrender.com/api/users/fflogin/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'login_field': usernameOrPhone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Response Data: $responseData");

        // التحقق من وجود كائن user والحقول المطلوبة داخله
        if (responseData.containsKey('id') &&
            responseData.containsKey('user') &&
            responseData['user'].containsKey('username') &&
            responseData['user'].containsKey('name') &&
            responseData['user'].containsKey('phone') &&
            responseData['user'].containsKey('user_type')) {
          // استخراج البيانات بشكل صحيح
          final user = User(
            id: responseData['id'],
            username: responseData['user']['username'],
            name: responseData['user']['name'],
            phone: responseData['user']['phone'],
            password: password, // استخدم كلمة السر المدخلة من المستخدم
            userType: responseData['user']['user_type'],
          );

          print("✅ تم حفظ بيانات المستخدم بنجاح");
          print("ID: ${user.id}");
          print("Username: ${user.username}");
          print("Name: ${user.name}");
          print("Phone: ${user.phone}");
          print("User Type: ${user.userType}");

          await SecureStorageHelper.saveUser(user);

          await storage.write(key: 'jwt_token', value: responseData['access']);
          await storage.write(
              key: 'refresh_token', value: responseData['refresh']);

          return {
            'access': responseData['access'],
            'refresh': responseData['refresh'],
            'user': responseData['user'],
          };
        } else {
          print("⚠️ الاستجابة لم تحتوي على الحقول المطلوبة");
          return {'error': 'البيانات الواردة غير صحيحة'};
        }
      } else {
        print("❌ فشل تسجيل الدخول: ${response.body}");
        return {'error': 'بيانات تسجيل الدخول غير صحيحة'};
      }
    } catch (error) {
      print("❌ حدث خطأ أثناء تسجيل الدخول: $error");
      return {'error': 'حدث خطأ غير متوقع. حاول مجددًا لاحقًا'};
    }
  }
}
