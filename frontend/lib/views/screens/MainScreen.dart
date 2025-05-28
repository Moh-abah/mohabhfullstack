import 'package:ain_frontend/views/screens/Welcom_Screen/1start.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ain_frontend/utils/SecureStorageHelper.dart';
import 'package:ain_frontend/views/screens/ChatHomeList.dart';
import 'package:ain_frontend/views/screens/HomeScreen.dart';
import 'package:ain_frontend/views/screens/profilestore.dart';
import 'package:ain_frontend/views/screens/settingfolder/settings_screen.dart';
import 'package:ain_frontend/views/screens/StorMaps.dart';
import 'package:ain_frontend/views/widgets/custom_bottom_nav_bar.dart';
import 'package:ain_frontend/viewmodels/UserTypeViewModel.dart';
import 'package:ain_frontend/viewmodels/state_bottom.dart';
import 'package:ain_frontend/ServicesAPI/user_type_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final BottomNavManager _navManager = BottomNavManager();
  final UserTypeService _userTypeService = UserTypeService();

  int? _userId;
  bool _isInitialized = false;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();

    // إضافة مستمع للتغييرات في التنقل
    _navManager.addListener(_handleNavChange);

    // إضافة مستمع للتغييرات في نوع المستخدم
    _navManager.addUserTypeListener(_handleUserTypeChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تهيئة الشاشات عند تغيير التبعيات (مثل تغيير نوع المستخدم من Provider)
    if (_isInitialized && _userId != null) {
      _updateScreensBasedOnUserType();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navManager.removeListener(_handleNavChange);
    _navManager.removeUserTypeListener(_handleUserTypeChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // إعادة التحقق من نوع المستخدم عند استئناف التطبيق
      _userTypeService.checkAndUpdateUserType();
    }
  }

  void _handleNavChange(int index) {
    if (mounted) {
      setState(() {
        // تحديث واجهة المستخدم عند تغيير التنقل
      });
    }
  }

  void _handleUserTypeChange(String userType) {
    if (mounted) {
      // إعادة تهيئة الشاشات عند تغيير نوع المستخدم
      _updateScreensBasedOnUserType();
    }
  }

  // تحديث دالة _initializeApp في ملف MainScreen.dart

  Future<void> _initializeApp() async {
    try {
      // استرجاع معرف المستخدم
      _userId = await SecureStorageHelper.getUserId();

      if (_userId == null) {
        print("⚠️ لم يتم العثور على معرف المستخدم");

        // محاولة إعادة توجيه المستخدم إلى شاشة تسجيل الدخول
        Future.delayed(Duration.zero, () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => start1()),
              (Route<dynamic> route) => false,
            );
          }
        });

        return;
      }

      // التحقق من نوع المستخدم
      await _userTypeService.checkAndUpdateUserType();

      // تهيئة الشاشات
      _updateScreensBasedOnUserType();
    } catch (e) {
      print("❌ خطأ في تهيئة التطبيق: $e");
    }
  }

  void _updateScreensBasedOnUserType() {
    if (_userId == null) return;

    final userType =
        Provider.of<UserTypeViewModel>(context, listen: false).userType;

    setState(() {
      if (userType == 'merchant') {
        _screens = [
          Profilestore(marchintID: _userId!),
          Stormaps(),
          ChatHomeListScreen(userId: _userId!),
          SettingsScreen(),
        ];
      } else {
        _screens = [
          HomeScreen(),
          Stormaps(),
          ChatHomeListScreen(userId: _userId!),
          SettingsScreen(),
        ];
      }

      _isInitialized = true;
    });

    print("✅ تم تحديث الشاشات بناءً على نوع المستخدم: $userType");
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF2A5C8D),
              ),
              SizedBox(height: 20),
              Text(
                "جاري تحميل البيانات...",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _navManager.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navManager.currentIndex,
        onTap: (index) {
          _navManager.navigateTo(index);
        },
      ),
    );
  }
}
