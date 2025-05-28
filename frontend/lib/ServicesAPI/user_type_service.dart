import 'package:ain_frontend/utils/SecureStorageHelper.dart';
import 'package:ain_frontend/viewmodels/state_bottom.dart';

class UserTypeService {
  // نمط Singleton للوصول العالمي
  static final UserTypeService _instance = UserTypeService._internal();
  factory UserTypeService() => _instance;
  UserTypeService._internal();

  final BottomNavManager _navManager = BottomNavManager();

  // التحقق من نوع المستخدم وتحديث مدير الحالة
  Future<String> checkAndUpdateUserType() async {
    try {
      // استرجاع المستخدم من التخزين الآمن
      final user = await SecureStorageHelper.getUser();

      if (user != null) {
        final userType = user.userType;

        // تحديث نوع المستخدم في مدير الحالة
        _navManager.setUserType(userType);

        print("✅ تم التحقق من نوع المستخدم: $userType");
        return userType;
      } else {
        // محاولة استرجاع نوع المستخدم مباشرة من التخزين
        final userType = await _getUserTypeFromStorage();
        if (userType != null) {
          _navManager.setUserType(userType);
          return userType;
        }

        print("⚠️ لم يتم العثور على بيانات المستخدم");
        return 'customer'; // القيمة الافتراضية
      }
    } catch (e) {
      print("❌ خطأ أثناء التحقق من نوع المستخدم: $e");
      return 'customer'; // القيمة الافتراضية في حالة الخطأ
    }
  }

  // استرجاع نوع المستخدم مباشرة من التخزين
  Future<String?> _getUserTypeFromStorage() async {
    try {
      final storage = await SecureStorageHelper.getInstance();
      return await storage.read(key: 'userType');
    } catch (e) {
      print("❌ خطأ في استرجاع نوع المستخدم من التخزين: $e");
      return null;
    }
  }

  // تحديث نوع المستخدم بعد تسجيل الدخول أو التسجيل
  Future<void> updateUserTypeAfterAuth(String userType) async {
    try {
      // تحديث نوع المستخدم في مدير الحالة
      _navManager.setUserType(userType);

      // تحديث نوع المستخدم في التخزين المحلي
      final storage = await SecureStorageHelper.getInstance();
      await storage.write(key: 'userType', value: userType);

      print("✅ تم تحديث نوع المستخدم بعد المصادقة: $userType");
    } catch (e) {
      print("❌ خطأ في تحديث نوع المستخدم بعد المصادقة: $e");
    }
  }

  // الحصول على نوع المستخدم الحالي
  String getCurrentUserType() {
    return _navManager.userType;
  }
}
