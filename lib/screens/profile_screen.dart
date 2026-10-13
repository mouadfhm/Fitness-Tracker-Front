// lib/screens/profile_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/adaptive.dart';
import 'package:provider/provider.dart';
import 'package:fitness_tracker_app/providers/profile_provider.dart';
import 'package:fitness_tracker_app/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'onboarding_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'achievements_screen.dart';
import '../utils/labels.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  void _goToProfileEdit(Map<String, dynamic> profileData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          initialData: profileData,
          isEditing: true,
        ),
      ),
    );
  }

  void _goToProgressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgressScreen()),
    );
  }

  void _goToAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _goToHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  }

  Future<void> _selectProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (!mounted) return;
        // Update profile picture through provider
        Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).updateProfilePicture(image.path);
      }
    } catch (e) {
      // Show error dialog if image picking fails
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog.adaptive(
              title: Text(l10n.errorLabel),
              content: Text(l10n.profileImagePickFailed),
              actions: [
                AdaptiveDialogAction(isDefault: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.ok),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog.adaptive(
          title: Text(l10n.profileLogoutTitle),
          content: Text(l10n.profileLogoutConfirm),
          actions: <Widget>[
            AdaptiveDialogAction(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            AdaptiveDialogAction(isDestructive: true,
              child: Text(l10n.profileLogOut, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navMe,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _goToSettings,
            icon: Icon(Icons.settings, color: colorScheme.onSurface),
            tooltip: l10n.settingsTitle,
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              // Only show edit button when profile data exists.
              return IconButton(
                onPressed: provider.profileData != null
                    ? () => _goToProfileEdit(provider.profileData!)
                    : null,
                icon: Icon(Icons.edit, color: colorScheme.onSurface),
                tooltip: l10n.profileEditTooltip,
              );
            },
          ),
        ],
      ),
      body: _buildProfileContent(),
          );
  }

  Widget _buildProfileContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator(
            color: colorScheme.primary,
          ));
        } else if (provider.profileData != null) {
          final profileData = provider.profileData!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Avatar with edit option
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: _selectProfileImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileData['custom_profile_pic'] != null
                              ? FileImage(
                                  File(profileData['custom_profile_pic']),
                                )
                              : AssetImage(
                                  profileData['gender'] == "male"
                                      ? profileData['weight'] > 100
                                          ? 'lib/assets/gorilla.png'
                                          : 'lib/assets/dog.png'
                                      : profileData['weight'] != null && profileData['weight'] > 80
                                          ? 'lib/assets/penguin.png'
                                          : 'lib/assets/rabbit.png',
                                ) as ImageProvider,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                        onPressed: _selectProfileImage,
                        tooltip: l10n.profileChangePhotoTooltip,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile Name
                Text(
                  profileData['name'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  profileData['email'],
                  style: TextStyle(
                    fontSize: 16, 
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                // Profile Information Cards
                Card(
                  child: Column(
                    children: [
                      _buildBirthdayTile(l10n, profileData),
                      _buildProfileTile(
                        Icons.monitor_weight,
                        l10n.profileWeight,
                        l10n.profileKgValue('${profileData['weight']}'),
                      ),
                      _buildProfileTile(
                        Icons.height,
                        l10n.profileHeight,
                        l10n.profileCmValue('${profileData['height']}'),
                      ),
                      _buildProfileTile(
                        Icons.directions_walk,
                        l10n.profileHowActive,
                        activityLabel(profileData['activity_level']?.toString()),
                      ),
                      _buildProfileTile(
                        Icons.emoji_events,
                        l10n.profileYourGoal,
                        goalLabel(profileData['fitness_goal']?.toString()),
                      ),
                      _buildProfileTile(
                        profileData['gender'] == "male"
                            ? Icons.male
                            : Icons.female,
                        l10n.profileGender,
                        genderLabel(profileData['gender']?.toString()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _goToProfileEdit(profileData),
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.profileEditDetails),
                  ),
                ),
                const SizedBox(height: 12),
                // Quick Action Buttons
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildQuickActionButton(
                      Icons.show_chart,
                      l10n.profileWeightLog,
                      _goToProgressScreen,
                    ),
                    _buildQuickActionButton(
                      Icons.emoji_events,
                      l10n.profileAchievements,
                      _goToAchievements,
                    ),
                    _buildQuickActionButton(
                      Icons.settings,
                      l10n.settingsTitle,
                      _goToSettings,
                    ),
                    _buildQuickActionButton(
                      Icons.help_outline,
                      l10n.profileHelp,
                      _goToHelpSupport,
                    ),
                    _buildQuickActionButton(
                      Icons.logout,
                      l10n.profileLogOut,
                      _showLogoutConfirmation,
                      isLogout: true,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    provider.errorMessage,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<ProfileProvider>(
                      context,
                      listen: false,
                    ).fetchProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: Text(l10n.profileTryAgain),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Helper UI Builders
  /// Birthday and age, or just the age for accounts that have no birthday yet.
  Widget _buildBirthdayTile(AppLocalizations l10n, Map<String, dynamic> profileData) {
    final age = l10n.profileYearsValue('${profileData['age']}');
    final birthDate = DateTime.tryParse(profileData['birth_date']?.toString() ?? '');
    if (birthDate == null) return _buildProfileTile(Icons.cake, l10n.profileAge, age);
    final date = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(birthDate);
    return _buildProfileTile(Icons.cake, l10n.profileBirthDate, '$date · $age');
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color bgColor = isLogout
        ? colorScheme.errorContainer
        : colorScheme.primary.withValues(alpha: 0.1);
    final Color iconTextColor = isLogout ? colorScheme.error : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconTextColor, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: iconTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}