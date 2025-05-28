// شاشة إعدادات الإشعارات
import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  _NotificationsSettingsPageState createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الإشعارات')),
      body: Center(
        child: SwitchListTile(
          title: const Text('تفعيل الإشعارات'),
          value: _isNotificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _isNotificationsEnabled = value;
            });
            // هنا يمكنك حفظ التغيير باستخدام SharedPreferences أو غيرها
          },
        ),
      ),
    );
  }
}
