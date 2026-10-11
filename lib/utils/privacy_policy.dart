import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// The privacy policy page, from PRIVACY_POLICY_URL in the .env file, or null
/// when it isn't set. The App Store requires this link inside any app that
/// creates accounts, so every place that offers it hides the link rather
/// than showing one that goes nowhere.
String? privacyPolicyUrl() {
  if (!dotenv.isInitialized) return null;
  final url = dotenv.maybeGet('PRIVACY_POLICY_URL');
  return (url == null || url.isEmpty) ? null : url;
}

Future<void> openPrivacyPolicy(BuildContext context) async {
  final url = privacyPolicyUrl();
  if (url == null) return;
  final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.privacyPolicyOpenFailed(url))),
    );
  }
}
