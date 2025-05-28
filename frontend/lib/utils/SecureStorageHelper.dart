import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class SecureStorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<FlutterSecureStorage> getInstance() async {
    return _storage;
  }

  // تخزين كائن المستخدم في Secure Storage
  static Future<void> saveUser(User user) async {
    await _storage.write(key: 'id', value: user.id.toString());
    await _storage.write(key: 'username', value: user.username);
    await _storage.write(key: 'name', value: user.name);
    await _storage.write(key: 'phone', value: user.phone);
    await _storage.write(key: 'password', value: user.password);
    await _storage.write(key: 'userType', value: user.userType);
  }

  // استرجاع كائن المستخدم من Secure Storage
  static Future<User?> getUser() async {
    String? idString = await _storage.read(key: 'id');
    String? username = await _storage.read(key: 'username');
    String? name = await _storage.read(key: 'name');
    String? phone = await _storage.read(key: 'phone');
    String? password = await _storage.read(key: 'password');
    String? userType = await _storage.read(key: 'userType');

    // تأكد من أن القيم الأساسية موجودة
    if (idString != null && username != null && password != null) {
      int id = int.parse(idString);
      return User(
        id: id,
        username: utf8.decode(username.codeUnits),
        name: name != null ? utf8.decode(name.codeUnits) : '',
        phone: phone != null ? utf8.decode(phone.codeUnits) : '',
        password: utf8.decode(password.codeUnits),
        userType: userType != null ? utf8.decode(userType.codeUnits) : '',
      );
    }

    return null; // إذا كانت البيانات الأساسية غير موجودة
  }

  // تحديث بيانات كائن المستخدم
  Future<void> updateUser(User user) async {
    await _storage.write(key: 'id', value: user.id.toString());
    await _storage.write(key: 'username', value: user.username);
    await _storage.write(key: 'name', value: user.name);
    await _storage.write(key: 'phone', value: user.phone);
    await _storage.write(key: 'password', value: user.password);
    await _storage.write(key: 'userType', value: user.userType);
  }

  // حذف بيانات المستخدم
  Future<void> removeUser() async {
    await _storage.delete(key: 'id');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'name');
    await _storage.delete(key: 'phone');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'userType');
  }

  // تحقق إذا كان المستخدم موجود
  Future<bool> isUserLoggedIn() async {
    return await _storage.containsKey(key: 'id');
  }

  // حذف جميع البيانات المخزنة
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // استرجاع معرّف المستخدم من Secure Storage
  static Future<int?> getUserId() async {
    String? idString = await _storage.read(key: 'id');
    if (idString != null) {
      return int.parse(idString); // تحويل الـ ID من String إلى int
    }
    return null; // إذا كانت البيانات غير موجودة
  }
}
