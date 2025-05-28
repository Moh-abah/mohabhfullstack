import 'package:ain_frontend/viewmodels/state_bottom.dart';
import 'package:ain_frontend/views/screens/MainScreen.dart';
import 'package:ain_frontend/views/screens/Welcom_Screen/1start.dart';
import 'package:flutter/material.dart';
import '../ServicesAPI/LoginService.dart';
import '../ServicesAPI/user_type_service.dart';

class FinalLoginViewModel extends ChangeNotifier {
  final finalLoginService _authService = finalLoginService();
  final UserTypeService _userTypeService = UserTypeService();
  final BottomNavManager _navManager = BottomNavManager();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // دالة تسجيل الدخول
  Future<void> login(
      BuildContext context, String usernameOrPhone, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // استدعاء خدمة تسجيل الدخول
      final response = await _authService.login(usernameOrPhone, password);

      // التحقق من نجاح تسجيل الدخول
      if (response != null && !response.containsKey('error')) {
        // الحصول على نوع المستخدم من الاستجابة
        final userType = response['user']['user_type'] as String;

        print("✅ تم تسجيل الدخول بنجاح كمستخدم نوعه: $userType");

        // تحديث نوع المستخدم في مدير الحالة
        _navManager.setUserType(userType);
        await _userTypeService.updateUserTypeAfterAuth(userType);

        // إعادة تعيين مؤشر التنقل
        _navManager.navigateTo(0);

        // توجيه المستخدم إلى الشاشة المناسبة
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // عرض رسالة الخطأ من الاستجابة
        _errorMessage =
            response?['error'] ?? 'فشل في تسجيل الدخول. تحقق من البيانات.';
        print("❌ فشل تسجيل الدخول: $_errorMessage");
      }
    } catch (e) {
      print("❌ خطأ أثناء تسجيل الدخول: $e");
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      print("🔴 [Logout] - بدأ تسجيل الخروج...");

      // مسح بيانات المستخدم المخزنة
      await _authService.storage.deleteAll();

      // إعادة تعيين مدير الحالة
      _navManager.reset();
      _navManager.setUserType(
          'customer'); // إعادة تعيين نوع المستخدم إلى القيمة الافتراضية

      print("✅ [Logout] - تم مسح بيانات الدخول.");

      // الانتقال إلى شاشة تسجيل الدخول
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => start1()),
        (Route<dynamic> route) => false,
      );

      print("🚀 [Logout] - تم توجيه المستخدم لشاشة تسجيل الدخول.");
    } catch (e) {
      print("❌ [Logout] - حدث خطأ أثناء تسجيل الخروج: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
