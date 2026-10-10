import 'package:fitness_tracker_app/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<LocaleProvider> _loaded() async {
  final provider = LocaleProvider();
  // Let the constructor's read of the saved choice finish.
  await Future<void>.delayed(Duration.zero);
  return provider;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('with nothing saved, follows the system language', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = await _loaded();

    expect(provider.locale, isNull);
    expect(provider.effectiveLocale, LocaleProvider.systemLocale());
  });

  test('a picked language is saved and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = await _loaded();
    await provider.setLocale(const Locale('fr'));

    final restored = await _loaded();
    expect(restored.locale, const Locale('fr'));
  });

  test('picking System default forgets the saved language', () async {
    SharedPreferences.setMockInitialValues({'language_code': 'fr'});
    final provider = await _loaded();
    expect(provider.locale, const Locale('fr'));

    await provider.setLocale(null);

    final restored = await _loaded();
    expect(restored.locale, isNull);
  });
}
