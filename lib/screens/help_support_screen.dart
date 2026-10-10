import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/privacy_policy.dart';

/// Short answers to the questions beginners actually ask, plus a way to
/// email support when SUPPORT_EMAIL is set in the .env file.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How do I log what I ate?',
      'On the Today tab, tap "Add" next to the meal (Breakfast, Lunch, Dinner '
          'or Snacks). Search for the food, enter how many grams you ate and tap '
          '"Add". You can also scan a barcode on the Foods tab.',
    ),
    (
      "I don't weigh my food. What should I enter?",
      'A rough guess is fine. A slice of bread is about 30 g, an apple about '
          '150 g, a cup of cooked rice about 160 g and a chicken breast about '
          '170 g. Use the quick buttons (50, 100, 150, 200 g) as a starting point.',
    ),
    (
      'What does "kcal left" mean?',
      'It is how many more calories you can eat today and still stay on track '
          'for your goal. If you go over, the number turns red. One day over is '
          'fine; what matters is most days.',
    ),
    (
      'What are protein, carbs and fat?',
      'They are the three nutrients that give food its calories. Protein helps '
          'build and repair muscle, carbs are your main energy source, and fat '
          'supports your body in many ways. Focus on calories first, then on '
          'getting enough protein.',
    ),
    (
      'How is my daily calorie goal worked out?',
      'From your age, weight, height, gender and how active you are, we '
          'estimate how many calories you burn on a normal day. Then we take '
          'away 500 to lose weight, add 300 to build muscle, or keep it the same. '
          'Exercise you log is added on top for that day.',
    ),
    (
      'How do I log exercise?',
      'Go to the Workouts tab. In Simple mode, find the activity (walking, '
          'cycling, …), tap it, choose how many minutes and tap "I did this".',
    ),
    (
      'What is Advanced mode?',
      'Advanced mode is for planning gym workouts week by week. If you are new, '
          'choose a ready-made plan: Full Body is 3 days a week and we fill in '
          'the exercises for you.',
    ),
    (
      'How do I change my weight or goal?',
      'Go to the Me tab and tap the edit button at the top. To track your '
          'weight over time, use "Weight log" on the same tab.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final supportEmail = dotenv.isInitialized ? dotenv.maybeGet('SUPPORT_EMAIL') : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Common questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          ..._faqs.map(
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
                      'Calorie goals, calories burned and BMI in this app are '
                      'estimates to guide you, not medical advice. If you have '
                      'a health condition, are pregnant, or plan a big change '
                      'in diet or exercise, check with a doctor first.',
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
                title: const Text('Privacy Policy'),
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
                title: const Text('Still stuck? Email us'),
                subtitle: Text(supportEmail),
                onTap: () async {
                  final uri = Uri(scheme: 'mailto', path: supportEmail, query: 'subject=Fitness Tracker help');
                  if (!await launchUrl(uri) && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No email app found. You can write to $supportEmail.')),
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
