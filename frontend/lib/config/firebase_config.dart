import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<FirebaseApp> initializeFirebase() async {
    return await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBerhIPn80wKrBAwpPPd2deTkfxoo5TAHE',
        authDomain: 'ain-chat-78fb3.firebaseapp.com',
        projectId: 'ain-chat-78fb3',
        storageBucket: 'ain-chat-78fb3.firebasestorage.app',
        messagingSenderId: '424532834684',
        appId: '1:424532834684:web:55766cd7c2286b386d8cf9',
        measurementId: 'G-QM18HP2YYE', // هذا اختياري
      ),
    );
  }
}
