import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness Tracker'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follows your phone ({language})'**
  String languageSystemSubtitle(String language);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navFoods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get navFoods;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all data'**
  String get deleteAccountSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get confirmLogoutMessage;

  /// No description provided for @notifMealRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal reminders'**
  String get notifMealRemindersTitle;

  /// No description provided for @notifMealRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A nudge when you have not logged a meal'**
  String get notifMealRemindersSubtitle;

  /// No description provided for @notifWorkoutRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get notifWorkoutRemindersTitle;

  /// No description provided for @notifWorkoutRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A nudge when you have not trained'**
  String get notifWorkoutRemindersSubtitle;

  /// No description provided for @notifAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get notifAchievementsTitle;

  /// No description provided for @notifAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you unlock a badge'**
  String get notifAchievementsSubtitle;

  /// No description provided for @notifCheckInsTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-ins'**
  String get notifCheckInsTitle;

  /// No description provided for @notifCheckInsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you have been away for a while'**
  String get notifCheckInsSubtitle;

  /// No description provided for @notifStreakSavesTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak saves'**
  String get notifStreakSavesTitle;

  /// No description provided for @notifStreakSavesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'In the evening, if your streak is about to break'**
  String get notifStreakSavesSubtitle;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String settingsSaveFailed(String error);

  /// No description provided for @settingsLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading your settings…'**
  String get settingsLoadingSettings;

  /// No description provided for @settingsLoadSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your settings'**
  String get settingsLoadSettingsFailed;

  /// No description provided for @settingsUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get settingsUnknownError;

  /// No description provided for @settingsQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get settingsQuietHours;

  /// No description provided for @settingsQuietHoursRange.
  ///
  /// In en, this message translates to:
  /// **'No notifications between {from} and {to}'**
  String settingsQuietHoursRange(String from, String to);

  /// No description provided for @settingsQuietHoursAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Notifications can arrive at any hour'**
  String get settingsQuietHoursAnyTime;

  /// No description provided for @settingsQuietHoursFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get settingsQuietHoursFrom;

  /// No description provided for @settingsQuietHoursTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get settingsQuietHoursTo;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get settingsDeleteAccountSuccess;

  /// No description provided for @settingsDeleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String settingsDeleteAccountFailed(String error);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginHeading.
  ///
  /// In en, this message translates to:
  /// **'Hello Again!'**
  String get loginHeading;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your fitness journey'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerHeading.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get registerHeading;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get registerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get fullNameRequired;

  /// No description provided for @fullNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get fullNameTooShort;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get registerPasswordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @onboardingFailedSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile. Please try again.'**
  String get onboardingFailedSave;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Your body stats'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'We use these to calculate your daily calorie needs'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAgeLabel;

  /// No description provided for @onboardingAgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 25'**
  String get onboardingAgeHint;

  /// No description provided for @onboardingWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get onboardingWeightLabel;

  /// No description provided for @onboardingWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 70'**
  String get onboardingWeightHint;

  /// No description provided for @onboardingHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get onboardingHeightLabel;

  /// No description provided for @onboardingHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 175'**
  String get onboardingHeightHint;

  /// No description provided for @onboardingInvalidStats.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid age, weight, and height'**
  String get onboardingInvalidStats;

  /// No description provided for @onboardingBmiEnterStats.
  ///
  /// In en, this message translates to:
  /// **'Enter your stats'**
  String get onboardingBmiEnterStats;

  /// No description provided for @onboardingBmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get onboardingBmiUnderweight;

  /// No description provided for @onboardingBmiHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Range'**
  String get onboardingBmiHealthy;

  /// No description provided for @onboardingBmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get onboardingBmiOverweight;

  /// No description provided for @onboardingBmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get onboardingBmiObese;

  /// No description provided for @onboardingBmiLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get onboardingBmiLabel;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender?'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Affects your metabolic rate calculation'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingBmrCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated Daily Calories at Rest'**
  String get onboardingBmrCardTitle;

  /// No description provided for @onboardingBmrCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic Rate'**
  String get onboardingBmrCardSubtitle;

  /// No description provided for @onboardingGenderMaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingGenderMaleLabel;

  /// No description provided for @onboardingGenderMaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Higher BMR on average'**
  String get onboardingGenderMaleDesc;

  /// No description provided for @onboardingGenderFemaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingGenderFemaleLabel;

  /// No description provided for @onboardingGenderFemaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Lower BMR on average'**
  String get onboardingGenderFemaleDesc;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick what describes a typical week for you'**
  String get onboardingStep3Subtitle;

  /// No description provided for @onboardingTdeeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Energy Expenditure'**
  String get onboardingTdeeCardTitle;

  /// No description provided for @onboardingTdeeMultiplier.
  ///
  /// In en, this message translates to:
  /// **'×{value} activity multiplier'**
  String onboardingTdeeMultiplier(String value);

  /// No description provided for @onboardingActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get onboardingActivitySedentary;

  /// No description provided for @onboardingActivitySedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Desk job, little to no exercise'**
  String get onboardingActivitySedentaryDesc;

  /// No description provided for @onboardingActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get onboardingActivityLight;

  /// No description provided for @onboardingActivityLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light exercise 1–3 days/week'**
  String get onboardingActivityLightDesc;

  /// No description provided for @onboardingActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get onboardingActivityModerate;

  /// No description provided for @onboardingActivityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 3–5 days/week'**
  String get onboardingActivityModerateDesc;

  /// No description provided for @onboardingActivityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get onboardingActivityActive;

  /// No description provided for @onboardingActivityActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise 6–7 days/week'**
  String get onboardingActivityActiveDesc;

  /// No description provided for @onboardingActivityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get onboardingActivityVeryActive;

  /// No description provided for @onboardingActivityVeryActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical job or 2× daily training'**
  String get onboardingActivityVeryActiveDesc;

  /// No description provided for @onboardingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'What\'s your goal?'**
  String get onboardingStep4Title;

  /// No description provided for @onboardingStep4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll adjust your daily target accordingly'**
  String get onboardingStep4Subtitle;

  /// No description provided for @onboardingTargetCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Calorie Target'**
  String get onboardingTargetCardTitle;

  /// No description provided for @onboardingTargetFromTdee.
  ///
  /// In en, this message translates to:
  /// **'{offset} kcal from your TDEE'**
  String onboardingTargetFromTdee(String offset);

  /// No description provided for @onboardingGoalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get onboardingGoalLoseWeight;

  /// No description provided for @onboardingGoalLoseWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'500 kcal daily deficit'**
  String get onboardingGoalLoseWeightDesc;

  /// No description provided for @onboardingGoalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get onboardingGoalBuildMuscle;

  /// No description provided for @onboardingGoalBuildMuscleDesc.
  ///
  /// In en, this message translates to:
  /// **'+300 kcal daily surplus'**
  String get onboardingGoalBuildMuscleDesc;

  /// No description provided for @onboardingGoalStayFit.
  ///
  /// In en, this message translates to:
  /// **'Stay Fit'**
  String get onboardingGoalStayFit;

  /// No description provided for @onboardingGoalStayFitDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain current weight'**
  String get onboardingGoalStayFitDesc;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get onboardingLetsGo;

  /// No description provided for @appTextFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String appTextFieldRequired(String field);

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed: {error}'**
  String logoutFailed(String error);

  /// No description provided for @homeNoMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get homeNoMealsLogged;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get homeYesterday;

  /// No description provided for @homeMacroCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get homeMacroCalories;

  /// No description provided for @homeMacroProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get homeMacroProtein;

  /// No description provided for @homeMacroFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get homeMacroFat;

  /// No description provided for @homeMacroCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get homeMacroCarbs;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Tracker'**
  String get homeTitle;

  /// No description provided for @homeDailyMacroGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily Macro Goals'**
  String get homeDailyMacroGoals;

  /// No description provided for @homeYourMeals.
  ///
  /// In en, this message translates to:
  /// **'Your Meals'**
  String get homeYourMeals;

  /// No description provided for @profileImagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image. Please try again.'**
  String get profileImagePickFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTooltip;

  /// No description provided for @profileFreeMember.
  ///
  /// In en, this message translates to:
  /// **'Free Member'**
  String get profileFreeMember;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileYearsValue.
  ///
  /// In en, this message translates to:
  /// **'{value} years'**
  String profileYearsValue(String value);

  /// No description provided for @profileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profileWeight;

  /// No description provided for @profileKgValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String profileKgValue(String value);

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileHeight;

  /// No description provided for @profileCmValue.
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String profileCmValue(String value);

  /// No description provided for @profileActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get profileActivityLevel;

  /// No description provided for @profileFitnessGoal.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get profileFitnessGoal;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get profileProgress;

  /// No description provided for @profileAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievements;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// No description provided for @profileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version: {version}'**
  String profileAppVersion(String version);

  /// No description provided for @profileErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String profileErrorMessage(String error);

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @helpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get helpContactSupport;

  /// No description provided for @helpContactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help from our team'**
  String get helpContactSupportSubtitle;

  /// No description provided for @helpFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get helpFaqs;

  /// No description provided for @helpFaqsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqsSubtitle;

  /// No description provided for @helpVideoTutorials.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorials'**
  String get helpVideoTutorials;

  /// No description provided for @helpVideoTutorialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use the app'**
  String get helpVideoTutorialsSubtitle;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKED'**
  String get achievementUnlocked;

  /// No description provided for @achievementLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get achievementLocked;

  /// No description provided for @achievementDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get achievementDescriptionLabel;

  /// No description provided for @achievementRequirementsLabel.
  ///
  /// In en, this message translates to:
  /// **'REQUIREMENTS'**
  String get achievementRequirementsLabel;

  /// No description provided for @achievementTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get achievementTargetLabel;

  /// No description provided for @achievementCompletionDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'COMPLETION DETAILS'**
  String get achievementCompletionDetailsLabel;

  /// No description provided for @achievementCompletedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed On'**
  String get achievementCompletedOnLabel;

  /// No description provided for @achievementLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading achievements: {error}'**
  String achievementLoadError(String error);

  /// No description provided for @achievementNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No achievements found'**
  String get achievementNoneFound;

  /// No description provided for @achievementCompleteToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Complete to unlock: {description}'**
  String achievementCompleteToUnlock(String description);

  /// No description provided for @achievementCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get achievementCompletedBadge;

  /// No description provided for @foodsNoBarcodeScanned.
  ///
  /// In en, this message translates to:
  /// **'No barcode scanned.'**
  String get foodsNoBarcodeScanned;

  /// No description provided for @foodsNotFoundForBarcode.
  ///
  /// In en, this message translates to:
  /// **'Food not found for barcode: {barcode}'**
  String foodsNotFoundForBarcode(String barcode);

  /// No description provided for @foodsScanError.
  ///
  /// In en, this message translates to:
  /// **'Error scanning barcode: {error}'**
  String foodsScanError(String error);

  /// No description provided for @foodsSortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort Foods By'**
  String get foodsSortByTitle;

  /// No description provided for @sortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// No description provided for @foodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foodsTitle;

  /// No description provided for @foodsSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort foods'**
  String get foodsSortTooltip;

  /// No description provided for @foodsSortingBy.
  ///
  /// In en, this message translates to:
  /// **'Sorting by: {sortTitle}'**
  String foodsSortingBy(String sortTitle);

  /// No description provided for @foodsCaloriesInline.
  ///
  /// In en, this message translates to:
  /// **'Calories: {value}'**
  String foodsCaloriesInline(String value);

  /// No description provided for @foodsCaloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories: {value} kcal'**
  String foodsCaloriesKcal(String value);

  /// No description provided for @foodsProteinGrams.
  ///
  /// In en, this message translates to:
  /// **'Protein: {value}g'**
  String foodsProteinGrams(String value);

  /// No description provided for @foodsCarbsGrams.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {value}g'**
  String foodsCarbsGrams(String value);

  /// No description provided for @foodsFatGrams.
  ///
  /// In en, this message translates to:
  /// **'Fat: {value}g'**
  String foodsFatGrams(String value);

  /// No description provided for @foodsProteinShort.
  ///
  /// In en, this message translates to:
  /// **'P: {value}g'**
  String foodsProteinShort(String value);

  /// No description provided for @foodsCarbsShort.
  ///
  /// In en, this message translates to:
  /// **'C: {value}g'**
  String foodsCarbsShort(String value);

  /// No description provided for @foodsFatShort.
  ///
  /// In en, this message translates to:
  /// **'F: {value}g'**
  String foodsFatShort(String value);

  /// No description provided for @foodsNoFoodsFound.
  ///
  /// In en, this message translates to:
  /// **'No foods found.'**
  String get foodsNoFoodsFound;

  /// No description provided for @foodsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Foods...'**
  String get foodsSearchHint;

  /// No description provided for @foodScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Food Barcode'**
  String get foodScanTitle;

  /// No description provided for @foodScanButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get foodScanButton;

  /// No description provided for @foodScanCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories: {value} kcal'**
  String foodScanCalories(String value);

  /// No description provided for @foodScanProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein: {value} g'**
  String foodScanProtein(String value);

  /// No description provided for @foodScanCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {value} g'**
  String foodScanCarbs(String value);

  /// No description provided for @foodScanFats.
  ///
  /// In en, this message translates to:
  /// **'Fats: {value} g'**
  String foodScanFats(String value);

  /// No description provided for @foodScanAddToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get foodScanAddToMeal;

  /// No description provided for @foodDetailsEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get foodDetailsEnterQuantity;

  /// No description provided for @foodDetailsEnterMealTime.
  ///
  /// In en, this message translates to:
  /// **'Please enter a meal time'**
  String get foodDetailsEnterMealTime;

  /// No description provided for @foodDetailsSelectMealTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a meal time'**
  String get foodDetailsSelectMealTime;

  /// No description provided for @foodDetailsEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get foodDetailsEnterValidQuantity;

  /// No description provided for @foodDetailsMealStoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal stored successfully!'**
  String get foodDetailsMealStoredSuccess;

  /// No description provided for @foodDetailsErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String foodDetailsErrorPrefix(String error);

  /// No description provided for @foodDetailsRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get foodDetailsRemovedFromFavorites;

  /// No description provided for @foodDetailsAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get foodDetailsAddedToFavorites;

  /// No description provided for @foodDetailsErrorUpdatingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Error updating favorites: {error}'**
  String foodDetailsErrorUpdatingFavorites(String error);

  /// No description provided for @foodDetailsRemoveFromFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get foodDetailsRemoveFromFavoritesTooltip;

  /// No description provided for @foodDetailsAddToFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get foodDetailsAddToFavoritesTooltip;

  /// No description provided for @foodDetailsNutritionFacts.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get foodDetailsNutritionFacts;

  /// No description provided for @foodDetailsFatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get foodDetailsFatsLabel;

  /// No description provided for @foodDetailsAddToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get foodDetailsAddToMealPlan;

  /// No description provided for @foodDetailsSelectMealTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select Meal Time'**
  String get foodDetailsSelectMealTimeHint;

  /// No description provided for @foodDetailsCustomMealTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Custom Meal Time'**
  String get foodDetailsCustomMealTimeHint;

  /// No description provided for @foodDetailsCustomMealTimeExamples.
  ///
  /// In en, this message translates to:
  /// **'Examples: Mid-morning, Late-night, Second Breakfast, etc.'**
  String get foodDetailsCustomMealTimeExamples;

  /// No description provided for @foodDetailsQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'Quantity (grams)'**
  String get foodDetailsQuantityHint;

  /// No description provided for @mealDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'{mealTime} Details'**
  String mealDetailTitle(String mealTime);

  /// No description provided for @mealDetailNoFoods.
  ///
  /// In en, this message translates to:
  /// **'No foods in this meal'**
  String get mealDetailNoFoods;

  /// No description provided for @mealDetailRemoveFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Food'**
  String get mealDetailRemoveFoodTitle;

  /// No description provided for @mealDetailRemoveFoodConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from this meal?'**
  String mealDetailRemoveFoodConfirm(String name);

  /// No description provided for @mealDetailRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mealDetailRemoveAction;

  /// No description provided for @mealDetailQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get mealDetailQuantityLabel;

  /// No description provided for @newFoodAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add food. Please try again.'**
  String get newFoodAddFailed;

  /// No description provided for @newFoodInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get newFoodInvalidNumber;

  /// No description provided for @newFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Food'**
  String get newFoodTitle;

  /// No description provided for @newFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get newFoodNameLabel;

  /// No description provided for @newFoodNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get newFoodNameHint;

  /// No description provided for @newFoodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter food name'**
  String get newFoodNameRequired;

  /// No description provided for @newFoodCarbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get newFoodCarbohydrates;

  /// No description provided for @newFoodAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get newFoodAddButton;

  /// No description provided for @updateProfileSuccessDefault.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get updateProfileSuccessDefault;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed. Please try again.'**
  String get updateProfileFailed;

  /// No description provided for @updateProfileAgeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get updateProfileAgeRequired;

  /// No description provided for @updateProfileAgeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get updateProfileAgeInvalid;

  /// No description provided for @updateProfileWeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get updateProfileWeightRequired;

  /// No description provided for @updateProfileWeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get updateProfileWeightInvalid;

  /// No description provided for @updateProfileHeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter height'**
  String get updateProfileHeightRequired;

  /// No description provided for @updateProfileHeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height'**
  String get updateProfileHeightInvalid;

  /// No description provided for @updateProfileGenderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get updateProfileGenderRequired;

  /// No description provided for @updateProfileActivityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an activity level'**
  String get updateProfileActivityRequired;

  /// No description provided for @updateProfileGoalRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a fitness goal'**
  String get updateProfileGoalRequired;

  /// No description provided for @updateProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileTitle;

  /// No description provided for @progressFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get progressFillAllFields;

  /// No description provided for @progressInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight value'**
  String get progressInvalidWeight;

  /// No description provided for @progressAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Progress added successfully!'**
  String get progressAddedSuccess;

  /// No description provided for @progressAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding progress: {error}'**
  String progressAddError(String error);

  /// No description provided for @progressNoDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No progress data available'**
  String get progressNoDataAvailable;

  /// No description provided for @progressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}\nWeight: {weight} kg'**
  String progressTooltip(String date, String weight);

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracker'**
  String get progressTitle;

  /// No description provided for @progressAddEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Progress Entry'**
  String get progressAddEntryTitle;

  /// No description provided for @progressDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get progressDateLabel;

  /// No description provided for @progressAddYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Add Your Progress'**
  String get progressAddYourProgress;

  /// No description provided for @progressChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Chart'**
  String get progressChartTitle;

  /// No description provided for @workoutModeSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get workoutModeSimple;

  /// No description provided for @workoutModeAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get workoutModeAdvanced;

  /// No description provided for @workoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutTitle;

  /// No description provided for @workoutDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get workoutDifficultyEasy;

  /// No description provided for @workoutDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get workoutDifficultyMedium;

  /// No description provided for @workoutDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get workoutDifficultyHard;

  /// No description provided for @workoutSearchExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Search Exercises...'**
  String get workoutSearchExercisesHint;

  /// No description provided for @workoutLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading workouts...'**
  String get workoutLoading;

  /// No description provided for @workoutFoundCount.
  ///
  /// In en, this message translates to:
  /// **'Found {count} workouts'**
  String workoutFoundCount(int count);

  /// No description provided for @workoutAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get workoutAllCategories;

  /// No description provided for @workoutLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading workouts'**
  String get workoutLoadError;

  /// No description provided for @workoutTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get workoutTryAgain;

  /// No description provided for @workoutNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'No workouts available'**
  String get workoutNoneAvailable;

  /// No description provided for @workoutNoneMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No workouts match your search'**
  String get workoutNoneMatchSearch;

  /// No description provided for @workoutClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get workoutClearFilters;

  /// No description provided for @workoutNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No Description'**
  String get workoutNoDescription;

  /// No description provided for @workoutCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get workoutCategoryOther;

  /// No description provided for @workoutDetailsUnknownWorkout.
  ///
  /// In en, this message translates to:
  /// **'Unknown Workout'**
  String get workoutDetailsUnknownWorkout;

  /// No description provided for @workoutDetailsEnterDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter a duration'**
  String get workoutDetailsEnterDuration;

  /// No description provided for @workoutDetailsEnterValidDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid duration'**
  String get workoutDetailsEnterValidDuration;

  /// No description provided for @workoutDetailsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout added successfully!'**
  String get workoutDetailsAddedSuccess;

  /// No description provided for @workoutDetailsNoName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get workoutDetailsNoName;

  /// No description provided for @workoutDetailsUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get workoutDetailsUncategorized;

  /// No description provided for @workoutDetailsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About This Workout'**
  String get workoutDetailsAboutTitle;

  /// No description provided for @workoutDetailsIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get workoutDetailsIntensity;

  /// No description provided for @workoutDetailsCaloriesPerHour.
  ///
  /// In en, this message translates to:
  /// **'{value}/hr'**
  String workoutDetailsCaloriesPerHour(String value);

  /// No description provided for @workoutDetailsScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Workout'**
  String get workoutDetailsScheduleTitle;

  /// No description provided for @workoutDetailsDurationHint.
  ///
  /// In en, this message translates to:
  /// **'Duration in minutes'**
  String get workoutDetailsDurationHint;

  /// No description provided for @workoutDetailsAddToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to My Plan'**
  String get workoutDetailsAddToPlan;

  /// No description provided for @workoutListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load workouts: {error}'**
  String workoutListLoadFailed(String error);

  /// No description provided for @workoutListImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import workout program: {error}'**
  String workoutListImportFailed(String error);

  /// No description provided for @workoutListSingleImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout \"{name}\" imported successfully'**
  String workoutListSingleImportedSuccess(String name);

  /// No description provided for @workoutListCycleImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout cycle imported successfully'**
  String get workoutListCycleImportedSuccess;

  /// No description provided for @workoutListDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout deleted successfully'**
  String get workoutListDeletedSuccess;

  /// No description provided for @workoutListDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete workout: {error}'**
  String workoutListDeleteFailed(String error);

  /// No description provided for @workoutListTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Management'**
  String get workoutListTitle;

  /// No description provided for @workoutListImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import workout program'**
  String get workoutListImportTooltip;

  /// No description provided for @workoutListRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh workouts'**
  String get workoutListRefreshTooltip;

  /// No description provided for @workoutListUnnamedWorkout.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Workout'**
  String get workoutListUnnamedWorkout;

  /// No description provided for @workoutListNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get workoutListNoDescription;

  /// No description provided for @workoutListDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get workoutListDeleteTooltip;

  /// No description provided for @workoutListNoWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No Workouts Yet'**
  String get workoutListNoWorkoutsYet;

  /// No description provided for @workoutListCreateFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout to get started'**
  String get workoutListCreateFirstWorkout;

  /// No description provided for @workoutListCreateNewWorkout.
  ///
  /// In en, this message translates to:
  /// **'Create New Workout'**
  String get workoutListCreateNewWorkout;

  /// No description provided for @workoutListErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Workouts'**
  String get workoutListErrorLoading;

  /// No description provided for @workoutListUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get workoutListUnknownError;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @workoutCalendarNoExportPlan.
  ///
  /// In en, this message translates to:
  /// **'No workout plan to export'**
  String get workoutCalendarNoExportPlan;

  /// No description provided for @workoutCalendarExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout cycle exported successfully'**
  String get workoutCalendarExportedSuccess;

  /// No description provided for @workoutCalendarExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export workout cycle: {error}'**
  String workoutCalendarExportFailed(String error);

  /// No description provided for @workoutCalendarImportedCycleDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Imported Cycle'**
  String get workoutCalendarImportedCycleDefaultName;

  /// No description provided for @workoutCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get workoutCalendarTitle;

  /// No description provided for @workoutCalendarOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Workout program options'**
  String get workoutCalendarOptionsTooltip;

  /// No description provided for @workoutCalendarSavedCycles.
  ///
  /// In en, this message translates to:
  /// **'Saved workout cycles'**
  String get workoutCalendarSavedCycles;

  /// No description provided for @workoutCalendarExportCycle.
  ///
  /// In en, this message translates to:
  /// **'Export workout cycle'**
  String get workoutCalendarExportCycle;

  /// No description provided for @workoutCalendarNoPlanAvailable.
  ///
  /// In en, this message translates to:
  /// **'No workout plan available'**
  String get workoutCalendarNoPlanAvailable;

  /// No description provided for @workoutCalendarNoPlanForWeek.
  ///
  /// In en, this message translates to:
  /// **'No workout plan for week {week}'**
  String workoutCalendarNoPlanForWeek(int week);

  /// No description provided for @workoutCalendarWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String workoutCalendarWeekLabel(int week);

  /// No description provided for @workoutCalendarNoWorkoutsForDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts for {day}'**
  String workoutCalendarNoWorkoutsForDay(String day);

  /// No description provided for @workoutCalendarAddWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Add Workout'**
  String get workoutCalendarAddWorkoutButton;

  /// No description provided for @workoutCalendarWorkoutsForDay.
  ///
  /// In en, this message translates to:
  /// **'Workouts for {day}'**
  String workoutCalendarWorkoutsForDay(String day);

  /// No description provided for @workoutCalendarAddMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add more workouts'**
  String get workoutCalendarAddMoreTooltip;

  /// No description provided for @workoutCalendarSearchWorkoutsHint.
  ///
  /// In en, this message translates to:
  /// **'Search workouts...'**
  String get workoutCalendarSearchWorkoutsHint;

  /// No description provided for @workoutCalendarAvailableWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Available Workouts'**
  String get workoutCalendarAvailableWorkouts;

  /// No description provided for @workoutCalendarNoMatchingWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No matching workouts found'**
  String get workoutCalendarNoMatchingWorkouts;

  /// No description provided for @workoutCalendarCreateFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout'**
  String get workoutCalendarCreateFirstWorkout;

  /// No description provided for @workoutCalendarAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add workout: {error}'**
  String workoutCalendarAddFailed(String error);

  /// No description provided for @workoutCalendarDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get workoutCalendarDetailsButton;

  /// No description provided for @workoutCalendarRemoveExerciseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get workoutCalendarRemoveExerciseTooltip;

  /// No description provided for @workoutCalendarMalformedEntry.
  ///
  /// In en, this message translates to:
  /// **'This workout entry couldn\'t be loaded.'**
  String get workoutCalendarMalformedEntry;

  /// No description provided for @workoutCalendarRemoveEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove entry'**
  String get workoutCalendarRemoveEntryTooltip;

  /// No description provided for @workoutCalendarPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get workoutCalendarPreviousWeek;

  /// No description provided for @workoutCalendarNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get workoutCalendarNextWeek;

  /// No description provided for @workoutCalendarCreateWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Workout Plan'**
  String get workoutCalendarCreateWorkoutPlan;

  /// No description provided for @workoutCalendarReuseSavedCycle.
  ///
  /// In en, this message translates to:
  /// **'Reuse a Saved Cycle'**
  String get workoutCalendarReuseSavedCycle;

  /// No description provided for @importDialogWorkoutsToCreate.
  ///
  /// In en, this message translates to:
  /// **'The following workouts will be created:'**
  String get importDialogWorkoutsToCreate;

  /// No description provided for @importDialogUnmatchedExercises.
  ///
  /// In en, this message translates to:
  /// **'These exercises weren\'t found and will be skipped:'**
  String get importDialogUnmatchedExercises;

  /// No description provided for @importDialogImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importDialogImportButton;

  /// No description provided for @newWorkoutLoadExercisesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercises: {error}'**
  String newWorkoutLoadExercisesFailed(String error);

  /// No description provided for @newWorkoutNeedExercise.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one exercise to your workout'**
  String get newWorkoutNeedExercise;

  /// No description provided for @newWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Workout'**
  String get newWorkoutTitle;

  /// No description provided for @newWorkoutRefreshExercisesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh exercise list'**
  String get newWorkoutRefreshExercisesTooltip;

  /// No description provided for @newWorkoutDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get newWorkoutDetailsTitle;

  /// No description provided for @newWorkoutNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get newWorkoutNameLabel;

  /// No description provided for @newWorkoutNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Upper Body Strength'**
  String get newWorkoutNameHint;

  /// No description provided for @newWorkoutNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a workout name'**
  String get newWorkoutNameRequired;

  /// No description provided for @newWorkoutDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get newWorkoutDescriptionLabel;

  /// No description provided for @newWorkoutDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Focus of this workout, target muscle groups, etc.'**
  String get newWorkoutDescriptionHint;

  /// No description provided for @newWorkoutDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get newWorkoutDescriptionRequired;

  /// No description provided for @newWorkoutExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get newWorkoutExercisesTitle;

  /// No description provided for @newWorkoutAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get newWorkoutAddExercise;

  /// No description provided for @newWorkoutExercisesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercises and configure sets, reps, and rest periods'**
  String get newWorkoutExercisesSubtitle;

  /// No description provided for @newWorkoutNoExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet'**
  String get newWorkoutNoExercisesYet;

  /// No description provided for @newWorkoutAddExercisesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add exercises to create your custom workout'**
  String get newWorkoutAddExercisesPrompt;

  /// No description provided for @newWorkoutSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get newWorkoutSetsLabel;

  /// No description provided for @newWorkoutRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get newWorkoutRepsLabel;

  /// No description provided for @newWorkoutRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest (sec)'**
  String get newWorkoutRestLabel;

  /// No description provided for @newWorkoutSelectExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Exercises'**
  String get newWorkoutSelectExercisesTitle;

  /// No description provided for @newWorkoutSearchExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get newWorkoutSearchExercisesHint;

  /// No description provided for @newWorkoutNoExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get newWorkoutNoExercisesFound;

  /// No description provided for @newWorkoutSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Workout'**
  String get newWorkoutSaveButton;

  /// No description provided for @newWorkoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving your workout...'**
  String get newWorkoutSaving;

  /// No description provided for @newWorkoutErrorCreating.
  ///
  /// In en, this message translates to:
  /// **'Error Creating Workout'**
  String get newWorkoutErrorCreating;

  /// No description provided for @workoutDetailScreenExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout exported successfully'**
  String get workoutDetailScreenExportedSuccess;

  /// No description provided for @workoutDetailScreenExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export workout: {error}'**
  String workoutDetailScreenExportFailed(String error);

  /// No description provided for @workoutDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get workoutDetailScreenTitle;

  /// No description provided for @workoutDetailScreenErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String workoutDetailScreenErrorPrefix(String error);

  /// No description provided for @workoutDetailScreenNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No workout details available'**
  String get workoutDetailScreenNoDetails;

  /// No description provided for @workoutDetailScreenRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get workoutDetailScreenRefresh;

  /// No description provided for @workoutDetailScreenExportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export workout'**
  String get workoutDetailScreenExportTooltip;

  /// No description provided for @workoutDetailScreenNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get workoutDetailScreenNoDescription;

  /// No description provided for @workoutDetailScreenExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Exercises'**
  String workoutDetailScreenExercisesCount(int count);

  /// No description provided for @workoutDetailScreenMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String workoutDetailScreenMinutes(int minutes);

  /// No description provided for @workoutDetailScreenSetsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String workoutDetailScreenSetsCount(int count);

  /// No description provided for @workoutDetailScreenRepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String workoutDetailScreenRepsCount(int count);

  /// No description provided for @workoutDetailScreenRestSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s rest'**
  String workoutDetailScreenRestSeconds(int seconds);

  /// No description provided for @workoutDetailScreenDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get workoutDetailScreenDescriptionLabel;

  /// No description provided for @workoutDetailScreenEquipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment: {value}'**
  String workoutDetailScreenEquipmentLabel(String value);

  /// No description provided for @workoutDetailScreenLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level: {value}'**
  String workoutDetailScreenLevelLabel(String value);

  /// No description provided for @exerciseSelectionPleaseSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select an exercise'**
  String get exerciseSelectionPleaseSelect;

  /// No description provided for @exerciseSelectionInvalidValues.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values for sets, reps, and rest'**
  String get exerciseSelectionInvalidValues;

  /// No description provided for @exerciseSelectionInvalidDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid duration or leave it empty'**
  String get exerciseSelectionInvalidDuration;

  /// No description provided for @exerciseSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get exerciseSelectionTitle;

  /// No description provided for @exerciseSelectionFilterByBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Filter by Body Part:'**
  String get exerciseSelectionFilterByBodyPart;

  /// No description provided for @exerciseSelectionDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (sec)'**
  String get exerciseSelectionDurationLabel;

  /// No description provided for @exerciseSelectionOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get exerciseSelectionOptionalHint;

  /// No description provided for @exerciseSelectionAddToWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add to Workout'**
  String get exerciseSelectionAddToWorkout;

  /// No description provided for @editWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Workout'**
  String get editWorkoutTitle;

  /// No description provided for @editWorkoutAddExercisesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add exercises to update your custom workout'**
  String get editWorkoutAddExercisesPrompt;

  /// No description provided for @editWorkoutUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Workout'**
  String get editWorkoutUpdateButton;

  /// No description provided for @editWorkoutUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating your workout...'**
  String get editWorkoutUpdating;

  /// No description provided for @editWorkoutErrorUpdating.
  ///
  /// In en, this message translates to:
  /// **'Error Updating Workout'**
  String get editWorkoutErrorUpdating;

  /// No description provided for @savedCyclesScheduled.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" scheduled'**
  String savedCyclesScheduled(String name);

  /// No description provided for @savedCyclesDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get savedCyclesDefaultName;

  /// No description provided for @savedCyclesReuseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reuse cycle: {error}'**
  String savedCyclesReuseFailed(String error);

  /// No description provided for @savedCyclesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Saved Cycle'**
  String get savedCyclesDeleteTitle;

  /// No description provided for @savedCyclesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String savedCyclesDeleteConfirm(String name);

  /// No description provided for @savedCyclesThisCycle.
  ///
  /// In en, this message translates to:
  /// **'this cycle'**
  String get savedCyclesThisCycle;

  /// No description provided for @savedCyclesDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete cycle: {error}'**
  String savedCyclesDeleteFailed(String error);

  /// No description provided for @savedCyclesAutoSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not set up workouts automatically ({error}). Pick a workout for each highlighted day instead.'**
  String savedCyclesAutoSetupFailed(String error);

  /// No description provided for @savedCyclesSuggestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested Cycles'**
  String get savedCyclesSuggestedTitle;

  /// No description provided for @savedCyclesSuggestedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick-start templates — pick one and we\'ll set up real workouts for each training day.'**
  String get savedCyclesSuggestedSubtitle;

  /// No description provided for @savedCyclesWeeksDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks · {days} days/week'**
  String savedCyclesWeeksDaysPerWeek(int weeks, int days);

  /// No description provided for @savedCyclesSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Setting up workouts…'**
  String get savedCyclesSettingUp;

  /// No description provided for @savedCyclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Workout Cycles'**
  String get savedCyclesTitle;

  /// No description provided for @savedCyclesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load saved cycles: {error}'**
  String savedCyclesLoadFailed(String error);

  /// No description provided for @savedCyclesYourCycles.
  ///
  /// In en, this message translates to:
  /// **'Your Saved Cycles'**
  String get savedCyclesYourCycles;

  /// No description provided for @savedCyclesNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No saved workout cycles yet'**
  String get savedCyclesNoneYet;

  /// No description provided for @savedCyclesAutoSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Every cycle you create is automatically saved here so you can reuse it later.'**
  String get savedCyclesAutoSavedHint;

  /// No description provided for @savedCyclesUnnamedCycle.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Cycle'**
  String get savedCyclesUnnamedCycle;

  /// No description provided for @savedCyclesWeeksAndDaysSummary.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, one{{weeks} week} other{{weeks} weeks}} · {days, plural, one{{days} workout day} other{{days} workout days}}/week'**
  String savedCyclesWeeksAndDaysSummary(int weeks, int days);

  /// No description provided for @savedCyclesReuseButton.
  ///
  /// In en, this message translates to:
  /// **'Reuse'**
  String get savedCyclesReuseButton;

  /// No description provided for @newWorkoutCycleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load workouts: {error}'**
  String newWorkoutCycleLoadFailed(String error);

  /// No description provided for @newWorkoutCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Workout Cycle'**
  String get newWorkoutCycleTitle;

  /// No description provided for @newWorkoutCycleRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get newWorkoutCycleRefreshTooltip;

  /// No description provided for @newWorkoutCycleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle Name'**
  String get newWorkoutCycleNameLabel;

  /// No description provided for @newWorkoutCycleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Summer Strength Program'**
  String get newWorkoutCycleNameHint;

  /// No description provided for @newWorkoutCycleNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give your cycle a name you\'ll recognize'**
  String get newWorkoutCycleNameSubtitle;

  /// No description provided for @newWorkoutCycleDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get newWorkoutCycleDescriptionLabel;

  /// No description provided for @newWorkoutCycleDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is this cycle about?'**
  String get newWorkoutCycleDescriptionHint;

  /// No description provided for @newWorkoutCycleStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get newWorkoutCycleStartDateLabel;

  /// No description provided for @newWorkoutCycleStartDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When should this cycle begin?'**
  String get newWorkoutCycleStartDateSubtitle;

  /// No description provided for @newWorkoutCycleWeeksLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (weeks)'**
  String get newWorkoutCycleWeeksLabel;

  /// No description provided for @newWorkoutCycleRepeatsFor.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, one {Repeats for 1 week} other {Repeats for {weeks} weeks}}'**
  String newWorkoutCycleRepeatsFor(int weeks);

  /// No description provided for @newWorkoutCycleScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get newWorkoutCycleScheduleTitle;

  /// No description provided for @newWorkoutCycleScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign a workout to each day'**
  String get newWorkoutCycleScheduleSubtitle;

  /// No description provided for @newWorkoutCycleRecommendedPending.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, one {{pending} of {total} recommended day still needs a workout} other {{pending} of {total} recommended days still need a workout}}'**
  String newWorkoutCycleRecommendedPending(int total, int pending);

  /// No description provided for @newWorkoutCycleRecommendedComplete.
  ///
  /// In en, this message translates to:
  /// **'All recommended days have a workout assigned'**
  String get newWorkoutCycleRecommendedComplete;

  /// No description provided for @newWorkoutCycleLoadingWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Loading your workouts…'**
  String get newWorkoutCycleLoadingWorkouts;

  /// No description provided for @newWorkoutCycleNoWorkoutsFound.
  ///
  /// In en, this message translates to:
  /// **'No Workouts Found'**
  String get newWorkoutCycleNoWorkoutsFound;

  /// No description provided for @newWorkoutCycleCreateWorkoutsFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a custom workout first so you can assign it to a day'**
  String get newWorkoutCycleCreateWorkoutsFirst;

  /// No description provided for @newWorkoutCycleCreateWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Create Workout'**
  String get newWorkoutCycleCreateWorkoutButton;

  /// No description provided for @newWorkoutCycleDeleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Workout'**
  String get newWorkoutCycleDeleteWorkoutTitle;

  /// No description provided for @newWorkoutCycleDeleteWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This cannot be undone.'**
  String newWorkoutCycleDeleteWorkoutConfirm(String name);

  /// No description provided for @newWorkoutCycleDeleteWorkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete workout: {error}'**
  String newWorkoutCycleDeleteWorkoutFailed(String error);

  /// No description provided for @newWorkoutCycleSearchWorkoutsHint.
  ///
  /// In en, this message translates to:
  /// **'Search workouts…'**
  String get newWorkoutCycleSearchWorkoutsHint;

  /// No description provided for @newWorkoutCycleRestDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get newWorkoutCycleRestDay;

  /// No description provided for @newWorkoutCycleNoCustomWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any custom workouts yet'**
  String get newWorkoutCycleNoCustomWorkoutsYet;

  /// No description provided for @newWorkoutCycleNoWorkoutsMatch.
  ///
  /// In en, this message translates to:
  /// **'No workouts match \"{query}\"'**
  String newWorkoutCycleNoWorkoutsMatch(String query);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
