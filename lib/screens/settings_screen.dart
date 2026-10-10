// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../utils/adaptive.dart';
import '../utils/friendly_error.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import 'package:fitness_tracker_app/providers/theme_provider.dart';
import 'login_screen.dart';
import '../utils/privacy_policy.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiService = ApiService();
  bool _isDeleting = false;

  /// The server's settings, or null until they arrive. Held as the raw map the
  /// API returns rather than unpacked into six fields, so a setting added on the
  /// backend needs one row here and nothing else.
  Map<String, dynamic>? _preferences;
  bool _loadingPreferences = true;
  String? _preferencesError;

  /// The toggles, in the order they are shown. Keys have to match the API's.
  static const _notificationToggles = <_NotificationToggle>[
    _NotificationToggle(
      key: 'meal_reminders',
      icon: Icons.restaurant,
      title: _mealRemindersTitle,
      subtitle: _mealRemindersSubtitle,
    ),
    _NotificationToggle(
      key: 'workout_reminders',
      icon: Icons.fitness_center,
      title: _workoutRemindersTitle,
      subtitle: _workoutRemindersSubtitle,
    ),
    _NotificationToggle(
      key: 'achievements',
      icon: Icons.emoji_events,
      title: _achievementsTitle,
      subtitle: _achievementsSubtitle,
    ),
    _NotificationToggle(
      key: 'winback',
      icon: Icons.waving_hand,
      title: _checkInsTitle,
      subtitle: _checkInsSubtitle,
    ),
    // Its own switch rather than sharing the meal or workout one. Someone who
    // turned those off said they did not want to be told to eat or to train;
    // they did not say they wanted to lose a streak without hearing about it.
    _NotificationToggle(
      key: 'streaks',
      icon: Icons.local_fire_department,
      title: _streakSavesTitle,
      subtitle: _streakSavesSubtitle,
    ),
  ];

  Future<void> _askForPermissionIfUndecided() async {
    if (await notificationPermissionUndecided()) {
      await requestNotificationPermission();
    }
  }

  /// What quiet hours are set to when switched on. Matches the backend's
  /// defaults, so a user who toggles it off and on again lands where they
  /// started rather than somewhere this screen invented.
  static const _defaultQuietFrom = '22:00';
  static const _defaultQuietTo = '08:00';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _loadingPreferences = true;
      _preferencesError = null;
    });

    try {
      final preferences = await _apiService.getNotificationPreferences();
      if (!mounted) return;
      setState(() {
        _preferences = preferences;
        _loadingPreferences = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Shown inline with a retry rather than as a snackbar. A snackbar leaves
      // the section looking like settings the user can trust, which is worse
      // than an obvious failure when what they are reading is nothing at all.
      setState(() {
        _preferencesError = e.toString();
        _loadingPreferences = false;
      });
    }
  }

  /// Applies [changes] locally at once, then saves.
  ///
  /// Optimistic because a switch that does not move until the network answers
  /// reads as a broken switch. The local value is rolled back if the save fails,
  /// so the screen never goes on showing a setting the server did not accept.
  Future<void> _savePreferences(Map<String, dynamic> changes) async {
    final previous = Map<String, dynamic>.from(_preferences!);

    setState(() {
      _preferences = {..._preferences!, ...changes};
    });

    try {
      final saved = await _apiService.updateNotificationPreferences(changes);
      if (!mounted) return;
      setState(() => _preferences = saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _preferences = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't save. ${friendlyError(e)}",
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(l10n.darkMode),
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (value) {
                themeProvider.setTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          _buildLanguageTile(context, l10n),
          const Divider(),
          _buildSectionHeader(context, l10n.notifications),
          ..._buildNotificationSection(context),
          const Divider(),
          if (privacyPolicyUrl() != null)
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.settingsPrivacyPolicy),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => openPrivacyPolicy(context),
            ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(
              l10n.deleteAccount,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(l10n.deleteAccountSubtitle),
            trailing:
                _isDeleting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : null,
            onTap: _isDeleting ? null : () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  /// Shows the language on screen now, and opens a picker with "System
  /// default" first: that is where a new install starts, and picking it again
  /// goes back to following the phone.
  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n) {
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.locale;
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(
        current == null
            ? l10n.languageSystem
            : _languageName(l10n, current),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguagePicker(context, localeProvider),
    );
  }

  /// Each language is named in itself ("Français", not "French"), so someone
  /// who landed in a language they can't read can still find their own.
  static String _languageName(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return l10n.languageFrench;
      default:
        return l10n.languageEnglish;
    }
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    LocaleProvider localeProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final systemName = _languageName(l10n, LocaleProvider.systemLocale());
    final options = <(Locale?, String, String?)>[
      (null, l10n.languageSystem, l10n.languageSystemSubtitle(systemName)),
      for (final locale in LocaleProvider.supportedLocales)
        (locale, _languageName(l10n, locale), null),
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  l10n.language,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              for (final (locale, name, subtitle) in options)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(name),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  trailing: localeProvider.locale == locale
                      ? Icon(
                          Icons.check,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    localeProvider.setLocale(locale);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  List<Widget> _buildNotificationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loadingPreferences) {
      return [
        ListTile(
          leading: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(l10n.settingsLoadingSettings),
        ),
      ];
    }

    if (_preferences == null) {
      return [
        ListTile(
          leading: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(l10n.settingsLoadSettingsFailed),
          subtitle: Text(_preferencesError ?? l10n.settingsUnknownError),
          trailing: TextButton(
            onPressed: _loadPreferences,
            child: Text(l10n.retry),
          ),
        ),
      ];
    }

    return [
      for (final toggle in _notificationToggles)
        SwitchListTile.adaptive(
          secondary: Icon(toggle.icon),
          title: Text(toggle.title(l10n)),
          subtitle: Text(toggle.subtitle(l10n)),
          // Defaults to on for a key the server has not sent, matching the
          // backend, where an absent setting means enabled.
          value: _preferences![toggle.key] as bool? ?? true,
          onChanged: (value) {
            _savePreferences({toggle.key: value});
            // Turning a reminder on is the clearest moment to ask iOS for
            // permission; without it the reminder could never arrive.
            if (value) _askForPermissionIfUndecided();
          },
        ),
      ..._buildQuietHoursTiles(context),
    ];
  }

  List<Widget> _buildQuietHoursTiles(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final from = _parseTime(_preferences!['quiet_from'] as String?);
    final to = _parseTime(_preferences!['quiet_to'] as String?);
    // The two are stored and cleared as a pair, so either one is enough to tell
    // whether the window is on.
    final enabled = from != null && to != null;

    return [
      SwitchListTile.adaptive(
        secondary: const Icon(Icons.bedtime),
        title: Text(l10n.settingsQuietHours),
        subtitle: Text(
          enabled
              ? l10n.settingsQuietHoursRange(_formatTime(from), _formatTime(to))
              : l10n.settingsQuietHoursAnyTime,
        ),
        value: enabled,
        onChanged: (value) => _savePreferences(
          value
              ? {'quiet_from': _defaultQuietFrom, 'quiet_to': _defaultQuietTo}
              // Explicit nulls, not omitted keys: omitting them would leave the
              // window exactly as it was.
              : {'quiet_from': null, 'quiet_to': null},
        ),
      ),
      if (enabled) ...[
        _buildQuietHourTile(context, l10n.settingsQuietHoursFrom, from, 'quiet_from'),
        _buildQuietHourTile(context, l10n.settingsQuietHoursTo, to, 'quiet_to'),
      ],
    ];
  }

  Widget _buildQuietHourTile(
    BuildContext context,
    String label,
    TimeOfDay current,
    String key,
  ) {
    return ListTile(
      // Indented under the switch above rather than given an icon of its own,
      // so the three read as one quiet-hours row and not as three more
      // top-level settings.
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text(label),
      trailing: Text(
        _formatTime(current),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () async {
        final picked = await showAdaptiveTimePicker(
          context: context,
          initialTime: current,
        );
        if (picked == null) return;
        await _savePreferences({key: _formatTime(picked)});
      },
    );
  }

  /// `HH:MM` (or `HH:MM:SS`) to a TimeOfDay, or null if it is neither.
  ///
  /// Null is the ordinary answer for "quiet hours are off" rather than a parse
  /// failure, which is why an unreadable value folds into the same result: both
  /// mean there is no window to show.
  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;

    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Always 24-hour and zero-padded, whatever the device's locale displays.
  /// This is what goes on the wire, and the backend validates it as `H:i` — a
  /// locale-formatted "10:00 PM" would be rejected.
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog.adaptive(
          title: Text(l10n.deleteAccount),
          content: Text(l10n.settingsDeleteAccountConfirm),
          actions: [
            AdaptiveDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            AdaptiveDialogAction(isDestructive: true,
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _apiService.deleteAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsDeleteAccountSuccess, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Couldn't delete your account. ${friendlyError(e)}", style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}

/// One row in the notifications list: which API key it drives and how it is
/// labelled. A small class rather than four parallel lists, so a new
/// notification type is one entry that cannot be added to three of the four
/// places by mistake.
class _NotificationToggle {
  const _NotificationToggle({
    required this.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String key;
  final IconData icon;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) subtitle;
}

String _mealRemindersTitle(AppLocalizations l) => l.notifMealRemindersTitle;
String _mealRemindersSubtitle(AppLocalizations l) => l.notifMealRemindersSubtitle;
String _workoutRemindersTitle(AppLocalizations l) => l.notifWorkoutRemindersTitle;
String _workoutRemindersSubtitle(AppLocalizations l) => l.notifWorkoutRemindersSubtitle;
String _achievementsTitle(AppLocalizations l) => l.notifAchievementsTitle;
String _achievementsSubtitle(AppLocalizations l) => l.notifAchievementsSubtitle;
String _checkInsTitle(AppLocalizations l) => l.notifCheckInsTitle;
String _checkInsSubtitle(AppLocalizations l) => l.notifCheckInsSubtitle;
String _streakSavesTitle(AppLocalizations l) => l.notifStreakSavesTitle;
String _streakSavesSubtitle(AppLocalizations l) => l.notifStreakSavesSubtitle;
