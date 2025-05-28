import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = const FlutterSecureStorage();

  // حفظ التوكن
  static Future<void> saveToken(String key, String token) async {
    await _storage.write(key: key, value: token);
  }

  // قراءة التوكن
  static Future<String?> readToken(String key) async {
    return await _storage.read(key: key);
  }

  // حذف التوكن
  static Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }
}
