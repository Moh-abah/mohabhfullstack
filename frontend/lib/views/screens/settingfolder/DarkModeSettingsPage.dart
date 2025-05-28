// شاشة إعدادات الوضع الليلي
import 'package:flutter/material.dart';

class DarkModeSettingsPage extends StatefulWidget {
  const DarkModeSettingsPage({super.key});

  @override
  _DarkModeSettingsPageState createState() => _DarkModeSettingsPageState();
}

class _DarkModeSettingsPageState extends State<DarkModeSettingsPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الوضع الليلي')),
      body: Center(
        child: SwitchListTile(
          title: const Text('تفعيل الوضع الليلي'),
          value: _isDarkMode,
          onChanged: (bool value) {
            setState(() {
              _isDarkMode = value;
            });
            // هنا يمكنك حفظ التغيير باستخدام SharedPreferences أو غيرها
          },
        ),
      ),
    );
  }
}
