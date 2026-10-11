import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firebase_service.dart';
import '../../l10n/app_localizations.dart';

/// Explains reminders before iOS shows its one-time notification prompt.
///
/// Apple's guidelines say to ask for notifications in context, once the
/// person can see why. This card is that context; it only appears on iOS
/// while the prompt has never been answered, and "Not now" hides it for good.
class NotificationPromptCard extends StatefulWidget {
  const NotificationPromptCard({super.key});

  static const dismissedKey = 'notification_prompt_dismissed';

  @override
  State<NotificationPromptCard> createState() => _NotificationPromptCardState();
}

class _NotificationPromptCardState extends State<NotificationPromptCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (!await notificationPermissionUndecided()) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(NotificationPromptCard.dismissedKey) ?? false) return;
    if (mounted) setState(() => _visible = true);
  }

  Future<void> _turnOn() async {
    setState(() => _visible = false);
    await requestNotificationPermission();
  }

  Future<void> _notNow() async {
    setState(() => _visible = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(NotificationPromptCard.dismissedKey, true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.notificationPromptTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationPromptBody,
              style: TextStyle(fontSize: 15, height: 1.4, color: colorScheme.onSecondaryContainer),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _notNow, child: Text(l10n.notificationPromptNotNow)),
                FilledButton(onPressed: _turnOn, child: Text(l10n.notificationPromptTurnOn)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
