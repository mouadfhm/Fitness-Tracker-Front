import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/privacy_policy.dart';
import '../l10n/app_localizations.dart';

/// Short answers to the questions beginners actually ask, plus a way to
/// email support when SUPPORT_EMAIL is set in the .env file.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static List<(String, String)> _faqs(AppLocalizations l10n) => [
        (l10n.helpFaqLogFoodQ, l10n.helpFaqLogFoodA),
        (l10n.helpFaqNoScaleQ, l10n.helpFaqNoScaleA),
        (l10n.helpFaqKcalLeftQ, l10n.helpFaqKcalLeftA),
        (l10n.helpFaqMacrosQ, l10n.helpFaqMacrosA),
        (l10n.helpFaqCalorieGoalQ, l10n.helpFaqCalorieGoalA),
        (l10n.helpFaqLogExerciseQ, l10n.helpFaqLogExerciseA),
        (l10n.helpFaqAdvancedModeQ, l10n.helpFaqAdvancedModeA),
        (l10n.helpFaqChangeGoalQ, l10n.helpFaqChangeGoalA),
      ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final supportEmail = dotenv.isInitialized ? dotenv.maybeGet('SUPPORT_EMAIL') : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileHelp, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            l10n.helpCommonQuestions,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          ..._faqs(l10n).map(
            (faq) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                shape: const Border(),
                title: Text(faq.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(faq.$2, style: TextStyle(fontSize: 15, height: 1.4, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App Store guideline 1.4.1: health numbers in the app are
          // estimates, and people should be told so.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.helpDisclaimer,
                      style: TextStyle(fontSize: 15, height: 1.4, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (privacyPolicyUrl() != null) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.settingsPrivacyPolicy),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => openPrivacyPolicy(context),
              ),
            ),
          ],
          if (supportEmail != null && supportEmail.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(l10n.helpEmailUs),
                subtitle: Text(supportEmail),
                onTap: () async {
                  final uri = Uri(scheme: 'mailto', path: supportEmail, query: 'subject=Fitness Tracker help');
                  if (!await launchUrl(uri) && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.helpNoEmailApp(supportEmail))),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
