import 'package:flutter/material.dart';
import 'package:ain_frontend/utils/SecureStorageHelper.dart';
import 'package:ain_frontend/viewmodels/state_bottom.dart';

class UserTypeViewModel extends ChangeNotifier {
  final BottomNavManager _navManager = BottomNavManager();
  String _userType = 'customer'; // القيمة الافتراضية

  UserTypeViewModel() {
    // الاستماع لتغييرات نوع المستخدم من مدير الحالة
    _navManager.addUserTypeListener(_handleUserTypeChange);
    // تهيئة نوع المستخدم عند إنشاء النموذج
    _initUserType();
  }

  String get userType => _userType;

  // تهيئة نوع المستخدم من التخزين المحلي
  Future<void> _initUserType() async {
    try {
      final user = await SecureStorageHelper.getUser();
      if (user != null) {
        setUserType(user.userType);
      }
    } catch (e) {
      print("❌ خطأ في تهيئة نوع المستخدم: $e");
    }
  }

  // تعيين نوع المستخدم وتحديث مدير الحالة
  void setUserType(String type) {
    if (_userType != type) {
      _userType = type;
      _navManager.setUserType(type);
      notifyListeners();
    }
  }

  // معالجة تغييرات نوع المستخدم من مدير الحالة
  void _handleUserTypeChange(String type) {
    if (_userType != type) {
      _userType = type;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _navManager.removeUserTypeListener(_handleUserTypeChange);
    super.dispose();
  }
}
