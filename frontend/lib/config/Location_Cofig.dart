import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Location_Coig {
  Future<Position> getCurrentLocation() async {
    // التحقق إذا كانت خدمة الموقع مفعلّة
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمات الموقع غير مفعلة');
    }

    // طلب إذن الوصول إلى الموقع
    final permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        // محاولة الحصول على الموقع
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(
              seconds: 30), // تحديد الحد الزمني للحصول على الموقع
        );
      } catch (e) {
        throw Exception('فشل في الحصول على الموقع');
      }
    } else if (permission.isPermanentlyDenied) {
      // في حالة تم رفض الإذن بشكل دائم
      openAppSettings(); // يمكن فتح إعدادات التطبيق لتغيير الأذونات
      throw Exception(
          'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق');
    } else {
      throw Exception('تم رفض إذن الموقع');
    }
  }
}
