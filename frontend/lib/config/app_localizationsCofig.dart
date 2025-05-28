import 'package:flutter/material.dart';

class AppLocalizationsCofig {
  final Locale locale;

  AppLocalizationsCofig(this.locale);

  static const LocalizationsDelegate<AppLocalizationsCofig> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizationsCofig of(BuildContext context) {
    return Localizations.of<AppLocalizationsCofig>(
        context, AppLocalizationsCofig)!;
  }

  // النصوص القابلة للترجمة
  String get appTitle {
    switch (locale.languageCode) {
      case 'ar':
        return 'تطبيق المتجر ';
      case 'en':
        return 'store app';
      default:
        return 'store app';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizationsCofig> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizationsCofig> load(Locale locale) async {
    return AppLocalizationsCofig(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
