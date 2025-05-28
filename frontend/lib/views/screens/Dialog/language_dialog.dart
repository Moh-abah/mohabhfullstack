import 'package:ain_frontend/viewmodels/Locale_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showLanguageDialog(BuildContext context) {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // لجعل Dialog بحجم محتواه
          children: [
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                localeProvider
                    .setLocale(const Locale('ar')); // تعيين اللغة العربية
                Navigator.pop(context); // إغلاق الـ Dialog
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                localeProvider
                    .setLocale(const Locale('en')); // تعيين اللغة الإنجليزية
                Navigator.pop(context); // إغلاق الـ Dialog
              },
            ),
          ],
        ),
      );
    },
  );
}
