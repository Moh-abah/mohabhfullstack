import 'package:ain_frontend/views/screens/settingfolder/AppVersionScreen.dart';
import 'package:ain_frontend/views/screens/settingfolder/ContactSupportScreen.dart';
import 'package:ain_frontend/views/screens/settingfolder/HelpCenterScreen.dart';
import 'package:ain_frontend/views/screens/settingfolder/PrivacyPolicyScreen.dart';
import 'package:ain_frontend/views/screens/settingfolder/ProfileScreen.dart';
import 'package:ain_frontend/views/screens/settingfolder/TermsOfUseScreen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/Login_VM.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //final bool _isDarkMode = false;
  //int _currentIndex = 0; // الحالة المبدئية للوضع الليلي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // الملف الشخصي
          _buildSectionTitle('الملف الشخصي'),
          _buildListTile('الملف الشخصي', Icons.person, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }),
          /*

          _buildListTile('إشعارات الرسائل', Icons.notifications, () {}),
          _buildListTile('تغيير كلمة المرور', Icons.security, () {
            Navigator.pushNamed(context, '/change_password');
          }),
          _buildListTile('حذف الحساب', Icons.delete, () {
            Navigator.pushNamed(context, '/delete_account');
          }),
          */

          // المفضلة
          /*
          _buildSectionTitle('المفضلة'),
          _buildListTile('قائمة المتاجر المفضلة', Icons.favorite, () {
            Navigator.pushNamed(context, '/favorite_stores');
          }),

          */

          // الخصوصية والأمان

          /*

          // التطبيق
          _buildSectionTitle('المظهر & اللغه'),
          _buildListTile('اللغة', Icons.language, () {
            showLanguageDialog(context);
          }),

          // الوضع الليلي مع تبديل الحالة

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('الوضع الليلي'),
              ),
              Transform.scale(
                scale: 1.5, // حجم الزر
                child: Switch(
                  value: themeProvider.isDarkMode, // حالة الوضع الليلي
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value); // تغيير حالة الوضع الليلي
                  },
                  activeColor: Colors.blue, // اللون عندما يكون الزر مفعل
                  inactiveThumbColor:
                      Colors.grey, // لون المؤشر عندما يكون غير مفعل
                  inactiveTrackColor:
                      Colors.grey[300], // لون المسار عندما يكون الزر غير مفعل
                ),
              ),
            ],
          ),

          */

          // الدعم
          _buildSectionTitle('الدعم & المعلومات'),
          _buildListTile('مركز المساعدة', Icons.help, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpCenterScreen()),
            );
          }),
          _buildListTile('التواصل مع الدعم الفني', Icons.contact_support, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactSupportScreen()),
            );
          }),

// حول التطبيق
          _buildSectionTitle('حول التطبيق'),
          _buildListTile('سياسة الخصوصية', Icons.privacy_tip, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
            );
          }),
          _buildListTile('شروط الاستخدام', Icons.rule, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TermsOfUseScreen()),
            );
          }),
          _buildListTile('إصدار التطبيق', Icons.info, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppVersionScreen()),
            );
          }),

          _buildSectionTitle('تسجيل الخروج'),
          _buildListTile(
            'تسجيل الخروج',
            Icons.logout,
            () {
              final authProvider =
                  Provider.of<FinalLoginViewModel>(context, listen: false);
              authProvider.logout(context);
            },
          ),
        ],
      ),
    );
  }

  // Widget لإنشاء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget لإنشاء عنصر في القائمة مع إجراء
  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => SettingsScreen(),
      '/edit_name': (context) => PlaceholderScreen('تعديل الاسم'),
      '/edit_phone': (context) => PlaceholderScreen('تعديل رقم الهاتف'),
      '/change_password': (context) => PlaceholderScreen('تغيير كلمة المرور'),
      '/favorite_stores': (context) =>
          PlaceholderScreen('قائمة المتاجر المفضلة'),
      '/delete_account': (context) => PlaceholderScreen('حذف الحساب'),
      '/help_center': (context) => PlaceholderScreen('مركز المساعدة'),
      '/contact_support': (context) =>
          PlaceholderScreen('التواصل مع الدعم الفني'),
      '/privacy_policy': (context) => PlaceholderScreen('سياسة الخصوصية'),
      '/terms_of_use': (context) => PlaceholderScreen('شروط الاستخدام'),
      '/app_version': (context) => PlaceholderScreen('إصدار التطبيق'),
      '/login': (context) => PlaceholderScreen('تسجيل الدخول'),
    },
  ));
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'شاشة $title',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
