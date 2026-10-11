import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// The privacy policy page, or null when there is nowhere to send people.
/// The App Store requires this link inside any app that creates accounts, so
/// every place that offers it hides the link rather than showing one that
/// goes nowhere.
String? privacyPolicyUrl() {
  if (!dotenv.isInitialized) return null;
  return resolvePrivacyPolicyUrl(
    explicitUrl: dotenv.maybeGet('PRIVACY_POLICY_URL'),
    baseUrl: dotenv.maybeGet('BASE_URL'),
  );
}

/// PRIVACY_POLICY_URL when it is set; otherwise the backend's own /privacy
/// page, found by dropping the trailing `/api` from BASE_URL
/// (`https://host/api` serves the policy at `https://host/privacy`).
@visibleForTesting
String? resolvePrivacyPolicyUrl({String? explicitUrl, String? baseUrl}) {
  if (explicitUrl != null && explicitUrl.trim().isNotEmpty) return explicitUrl.trim();
  if (baseUrl == null || baseUrl.trim().isEmpty) return null;
  final base = Uri.tryParse(baseUrl.trim());
  if (base == null || !base.hasScheme || base.host.isEmpty) return null;
  final segments = base.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.isNotEmpty && segments.last == 'api') segments.removeLast();
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    pathSegments: [...segments, 'privacy'],
  ).toString();
}

/// [url] with `lang` set to the app's language, so the page opens in the
/// same language as the app rather than the phone's.
@visibleForTesting
Uri privacyPolicyUri(String url, String languageCode) {
  final uri = Uri.parse(url);
  return uri.replace(queryParameters: {...uri.queryParameters, 'lang': languageCode});
}

Future<void> openPrivacyPolicy(BuildContext context) async {
  final url = privacyPolicyUrl();
  if (url == null) return;
  final uri = privacyPolicyUri(url, Localizations.localeOf(context).languageCode);
  final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.privacyPolicyOpenFailed(url))),
    );
  }
}
