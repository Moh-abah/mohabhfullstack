import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetChecker {
  /// يتحقق من وجود اتصال بالإنترنت ويعيد [true] إذا كان متاحًا و [false] إذا لم يكن كذلك.
  Future<bool> get hasInternet async {
    return await InternetConnectionChecker.createInstance().hasConnection;
  }

  /// تدفق (Stream) يرسل حالة الاتصال بالإنترنت:
  /// يقوم بتحويل حالة الاتصال إلى [true] إذا كان متصلًا و [false] إذا لم يكن.
  Stream<bool> get onStatusChange =>
      InternetConnectionChecker.createInstance().onStatusChange.map(
            (status) => status == InternetConnectionStatus.connected,
          );
}
