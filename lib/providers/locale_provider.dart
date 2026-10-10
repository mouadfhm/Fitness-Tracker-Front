import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/locale_service.dart';

/// The app's language. Null [locale] means "follow the phone": `MaterialApp`
/// then picks the system language when it is one we support, and English
/// otherwise. That is the starting point until the user picks a language in
/// Settings, and they can go back to it from there.
class LocaleProvider with ChangeNotifier {
  static const String _localePrefKey = 'language_code';
  static const supportedLocales = [Locale('en'), Locale('fr')];

  Locale? _locale;

  Locale? get locale => _locale;

  /// The language actually on screen, whether picked or taken from the phone.
  Locale get effectiveLocale => _locale ?? systemLocale();

  LocaleProvider() {
    LocaleService.languageCode = effectiveLocale.languageCode;
    _loadLocaleFromPrefs();
  }

  /// The phone's preferred language if we support it, else English.
  static Locale systemLocale() {
    for (final preferred in PlatformDispatcher.instance.locales) {
      for (final supported in supportedLocales) {
        if (supported.languageCode == preferred.languageCode) return supported;
      }
    }
    return supportedLocales.first;
  }

  /// Pass null to follow the phone's language again.
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    LocaleService.languageCode = effectiveLocale.languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localePrefKey);
    } else {
      await prefs.setString(_localePrefKey, locale.languageCode);
    }
  }

  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localePrefKey);

    _locale = supportedLocales.where((l) => l.languageCode == code).firstOrNull;
    LocaleService.languageCode = effectiveLocale.languageCode;

    notifyListeners();
  }
}
