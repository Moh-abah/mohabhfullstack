import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UploadcareCofig {
  final String publicKey = '6b2c1ee2984bb8a268e5'; // مفتاح عام
  final String privateKey = '4c0581d577ed8305d82c'; // مفتاح خاص

  Future<String> uploadImage(Uint8List imageData) async {
    try {
      // URL الخاص برفع الصورة
      var url = Uri.parse('https://upload.uploadcare.com/base/');

      // إرسال البيانات باستخدام Multipart
      var request = http.MultipartRequest('POST', url)
        ..fields['UPLOADCARE_PUB_KEY'] = publicKey
        ..files.add(http.MultipartFile.fromBytes('file', imageData,
            filename: 'image.jpg'));

      var response = await request.send();

      if (response.statusCode == 200) {
        // استخراج رابط الصورة بعد رفعها
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['file'];
      } else {
        throw '❌ خطأ في رفع الصورة: ${response.statusCode}';
      }
    } catch (e) {
      throw '❌ خطأ أثناء رفع الصورة: $e';
    }
  }
}
