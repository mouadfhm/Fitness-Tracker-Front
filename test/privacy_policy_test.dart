import 'package:fitness_tracker_app/utils/privacy_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolvePrivacyPolicyUrl', () {
    test('prefers PRIVACY_POLICY_URL when it is set', () {
      expect(
        resolvePrivacyPolicyUrl(explicitUrl: 'https://example.org/policy', baseUrl: 'https://api.example.com/api'),
        'https://example.org/policy',
      );
    });

    test('falls back to /privacy on the backend, dropping the /api suffix', () {
      expect(resolvePrivacyPolicyUrl(baseUrl: 'https://example.com/api'), 'https://example.com/privacy');
      expect(resolvePrivacyPolicyUrl(baseUrl: 'https://example.com/api/'), 'https://example.com/privacy');
      expect(resolvePrivacyPolicyUrl(baseUrl: 'http://10.0.2.2:8000/api', explicitUrl: ''),
          'http://10.0.2.2:8000/privacy');
    });

    test('keeps a sub-path the backend is mounted under', () {
      expect(resolvePrivacyPolicyUrl(baseUrl: 'https://example.com/fitness/api'), 'https://example.com/fitness/privacy');
    });

    test('is null with nothing usable to build from', () {
      expect(resolvePrivacyPolicyUrl(), isNull);
      expect(resolvePrivacyPolicyUrl(baseUrl: ''), isNull);
      expect(resolvePrivacyPolicyUrl(baseUrl: 'not a url'), isNull);
    });
  });

  test('privacyPolicyUri adds the app language and keeps other parameters', () {
    expect(privacyPolicyUri('https://example.com/privacy', 'fr').toString(), 'https://example.com/privacy?lang=fr');
    expect(privacyPolicyUri('https://example.com/privacy?lang=en&x=1', 'fr').queryParameters,
        {'lang': 'fr', 'x': '1'});
  });
}
