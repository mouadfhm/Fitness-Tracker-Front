import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/locale_service.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localePrefKey = 'language_code';
  static const supportedLocales = [Locale('en'), Locale('fr')];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocaleFromPrefs();
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    LocaleService.languageCode = locale.languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, locale.languageCode);
  }

  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);

    _locale = supportedLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => const Locale('en'),
    );
    LocaleService.languageCode = _locale.languageCode;

    notifyListeners();
  }
}
