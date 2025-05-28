import 'package:ain_frontend/ServicesAPI/profil_Service.dart';
import 'package:ain_frontend/database_helper.dart';

import 'package:ain_frontend/viewmodels/add_offer_provider.dart';
import 'package:ain_frontend/viewmodels/Profile_Store_Provider.dart';
import 'package:ain_frontend/views/screens/MainScreen.dart';

import 'viewmodels/HomeScreenProvider.dart';
import 'package:ain_frontend/viewmodels/Store_Map_Provider.dart';
import 'package:ain_frontend/views/screens/Welcom_Screen/1start.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ain_frontend/viewmodels/Locale_Provider.dart';
import 'package:ain_frontend/viewmodels/Theme_Provider.dart';
import 'package:flutter/material.dart';
import 'package:ain_frontend/ServicesAPI/AddReviewService.dart';
import 'package:ain_frontend/viewmodels/Login_VM.dart';

import 'package:logger/logger.dart';
import 'package:ain_frontend/views/screens/create_store_screen.dart';
import 'package:ain_frontend/views/screens/StorMaps.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'config/app_localizationsCofig.dart';
import 'utils/SecureStorageHelper.dart';
import 'viewmodels/ChatProvider.dart';
import 'viewmodels/ReviewViewModel.dart';
import 'viewmodels/UserTypeViewModel.dart';
import 'viewmodels/Message_Provider.dart';
import 'views/screens/Login_screan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/screens/Register_screen.dart';

String languge = 'EN';
bool darkMode = false;
final db = AppDatabase();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعداد الكائن Logger
  final Logger logger = Logger();

  logger.i("بدء تهيئة Firebase...");

  int? currentUserId;

  try {
    await Firebase.initializeApp();

    logger.i("Firebase تم تهيئتها بنجاح.");
    print("Firebase تم تهيئتها بنجاح.");
  } catch (e) {
    logger.e("خطأ في تهيئة Firebase: $e");
    print("خطأ في تهيئة Firebase: $e");
  }

  final database = AppDatabase();
  final userId = await SecureStorageHelper.getUserId();

  if (userId == null) {
    logger.w("userId غير متوفر في SecureStorage.");
    // تجاوز العملية بدون إيقاف التنفيذ
  } else {
    currentUserId = userId;
    logger.i("تم الحصول على userId: $userId");
  }

  logger.i("تم الحصول على userId: $userId");

  // تهيئة Dio و FlutterSecureStorage
  final Dio dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // تهيئة Firebase والتطبيق
  runApp(
    MultiProvider(
      providers: [
        // توفير قاعدة البيانات للتطبيق

        ChangeNotifierProvider(create: (context) {
          logger.i("إنشاء FinalLoginViewModel");
          return FinalLoginViewModel();
        }),
        ChangeNotifierProvider(
            create: (context) => ReviewViewModel(
                  reviewService: Addreviewservice(dio: dio, storage: storage),
                )),
        ChangeNotifierProvider(create: (_) {
          logger.i("إنشاء ThemeProvider");
          return ThemeProvider();
        }),

        //ChangeNotifierProvider(create: (_) => ChatConfigProvider()),
        Provider(create: (_) => Dio()), // إنشاء Dio
        Provider(
            create: (_) =>
                FlutterSecureStorage()), // إنشاء FlutterSecureStorage

        // الآن إنشاء ProfilServiceApi مع التبعيات المطلوبة
        Provider(
          create: (context) => ProfilServiceApi(
            dio: context.read<Dio>(),
            storage: context.read<FlutterSecureStorage>(),
          ),
        ),

        // إنشاء ReviewsState باستخدام ProfilServiceApi
        ChangeNotifierProvider(
          create: (context) => ReviewsState(
            profilService: context.read<ProfilServiceApi>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StoreState(
            profilService: context.read<ProfilServiceApi>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StoreListProvider(
            reviewsState: context.read<ReviewsState>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => MapState()),

        ChangeNotifierProvider(create: (_) {
          logger.i("إنشاء LocaleProvider");
          return LocaleProvider();
        }),
        //ChangeNotifierProvider(create: (_) => FinalLoginViewModel()),
        ChangeNotifierProvider(create: (_) => UserTypeViewModel()),

        // إضافة ChatProvider فقط إذا كانت قيمة userId غير null
        if (userId != null)
          ChangeNotifierProvider.value(value: ChatProvider(userId: userId)),

        ChangeNotifierProvider(create: (_) {
          logger.i("إنشاء MessageProvider");
          return MessageProvider();
        }),
        Provider<AppDatabase>.value(value: database),
        // توفير مزود الشاشة الرئيسية

        ChangeNotifierProvider(create: (_) => HomeScreenProvider(database)),

        ChangeNotifierProvider(create: (_) => AddOfferProvider()),
        if (userId != null)
          ChangeNotifierProvider(
              create: (_) => ProfileStoreProvider(
                    merchantId: userId,
                    dio: dio, // تمرير Dio هنا
                    storage: storage, // تمرير FlutterSecureStorage هنا
                  )),

        ChangeNotifierProvider(create: (_) => AddOfferProvider()),
      ],
      child: MyApp(logger: logger),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Logger logger;

  const MyApp({super.key, required this.logger});

  @override
  Widget build(BuildContext context) {
    logger.i("بناء MyApp...");
    print("بناء MyApp...");
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'Store App',
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      locale: localeProvider.locale, // تعيين اللغة الحالية
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // الإنجليزية
      ],
      localizationsDelegates: const [
        AppLocalizationsCofig.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // تعيين SplashScreen كـ home
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        logger.i("onGenerateRoute: ${settings.name}");
        print("onGenerateRoute: ${settings.name}");
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => FinalLoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen());
          case '/create-store':
            return MaterialPageRoute(builder: (_) => CreateStoreScreen());
          case '/store':
            return MaterialPageRoute(builder: (_) => Stormaps());
          default:
            return MaterialPageRoute(builder: (_) => FinalLoginScreen());
        }
      },
    );
  }
}

// تأكد من أن هذه الشاشة موجودة في المسار الصحيح

final storage = const FlutterSecureStorage();

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  // إعداد الكائن Logger
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ صورة الشعار (اللوجو)
          Center(
            child: ClipOval(
              child: SizedBox(
                width: 250, // تحديد العرض المطلوب
                height: 250, // تحديد الطول المطلوب
                child: Image.asset(
                  "assets/logo.png", // تغيير المسار للصورة الخاصة بك
                  fit: BoxFit.cover, // جعل الصورة تملأ المساحة بشكل مناسب
                ),
              ),
            ),
          ),

          // ✅ `FutureBuilder` للانتقال إلى الشاشة المناسبة
          FutureBuilder<bool>(
            future: _checkUserStatus(), // دالة للتحقق من حالة المستخدم
            builder: (context, snapshot) {
              logger.i("بدأ التحقق من حالة المستخدم...");

              if (snapshot.connectionState == ConnectionState.waiting) {
                logger.i("انتظار: التحقق من حالة المستخدم...");
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                logger.e(
                    "حدث خطأ أثناء التحقق من حالة المستخدم: ${snapshot.error}");
                return Center(child: Text("حدث خطأ: ${snapshot.error}"));
              }

              // ✅ حالة تسجيل الدخول
              final isUserLoggedIn = snapshot.data ?? false;
              logger.i("حالة تسجيل الدخول: $isUserLoggedIn");

              // ✅ تأخير الانتقال إلى الشاشة المناسبة
              Future.delayed(Duration(seconds: 4), () {
                // ✅ التوجيه إلى الشاشة المناسبة بعد تأخير
                if (isUserLoggedIn) {
                  logger.i("المستخدم مسجل دخول. التوجيه إلى شاشة المتاجر.");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen()),
                  );
                } else {
                  logger.i(
                      "المستخدم غير مسجل دخول. التوجيه إلى شاشة تسجيل الدخول.");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => start1()),
                  );
                }
              });

              // ✅ عرض `CircularProgressIndicator` أثناء التحميل
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  // دالة للتحقق من حالة التوكنات في SecureStorage
  Future<bool> _checkUserStatus() async {
    try {
      logger.i("قراءة التوكن من SecureStorage...");
      final token = await storage.read(key: 'jwt_token'); // قراءة التوكن
      logger.i("تم قراءة التوكن: $token");
      return token?.isNotEmpty ?? false; // إذا كان التوكن موجودًا وغير فارغ
    } catch (e) {
      logger.e("خطأ أثناء التحقق من التوكن: $e");
      return false;
    }
  }
}
