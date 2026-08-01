// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'package:fitness_tracker_app/providers/theme_provider.dart';
import 'login_screen.dart';

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

  /// The four toggles, in the order they are shown. Keys have to match the API's.
  static const _notificationToggles = <_NotificationToggle>[
    _NotificationToggle(
      key: 'meal_reminders',
      icon: Icons.restaurant,
      title: 'Meal reminders',
      subtitle: 'A nudge when you have not logged a meal',
    ),
    _NotificationToggle(
      key: 'workout_reminders',
      icon: Icons.fitness_center,
      title: 'Workout reminders',
      subtitle: 'A nudge when you have not trained',
    ),
    _NotificationToggle(
      key: 'achievements',
      icon: Icons.emoji_events,
      title: 'Achievements',
      subtitle: 'When you unlock a badge',
    ),
    _NotificationToggle(
      key: 'winback',
      icon: Icons.waving_hand,
      title: 'Check-ins',
      subtitle: 'If you have been away for a while',
    ),
  ];

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
            'Could not save: $e',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                themeProvider.setTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Notifications'),
          ..._buildNotificationSection(context),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text(
              'Permanently delete your account and all data',
            ),
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
    if (_loadingPreferences) {
      return const [
        ListTile(
          leading: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Loading your settings…'),
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
          title: const Text('Could not load your settings'),
          subtitle: Text(_preferencesError ?? 'Unknown error'),
          trailing: TextButton(
            onPressed: _loadPreferences,
            child: const Text('Retry'),
          ),
        ),
      ];
    }

    return [
      for (final toggle in _notificationToggles)
        SwitchListTile(
          secondary: Icon(toggle.icon),
          title: Text(toggle.title),
          subtitle: Text(toggle.subtitle),
          // Defaults to on for a key the server has not sent, matching the
          // backend, where an absent setting means enabled.
          value: _preferences![toggle.key] as bool? ?? true,
          onChanged: (value) => _savePreferences({toggle.key: value}),
        ),
      ..._buildQuietHoursTiles(context),
    ];
  }

  List<Widget> _buildQuietHoursTiles(BuildContext context) {
    final from = _parseTime(_preferences!['quiet_from'] as String?);
    final to = _parseTime(_preferences!['quiet_to'] as String?);
    // The two are stored and cleared as a pair, so either one is enough to tell
    // whether the window is on.
    final enabled = from != null && to != null;

    return [
      SwitchListTile(
        secondary: const Icon(Icons.bedtime),
        title: const Text('Quiet hours'),
        subtitle: Text(
          enabled
              ? 'No notifications between ${_formatTime(from)} and ${_formatTime(to)}'
              : 'Notifications can arrive at any hour',
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
        _buildQuietHourTile(context, 'From', from, 'quiet_from'),
        _buildQuietHourTile(context, 'To', to, 'quiet_to'),
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
        final picked = await showTimePicker(
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
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
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
          content: Text('Account deleted successfully', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
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
          content: Text('Failed to delete account: $e', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
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
  final String title;
  final String subtitle;
}
