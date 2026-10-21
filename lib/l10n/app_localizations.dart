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
  /// **'Fitness Tracker: Meals & Gym'**
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

  /// No description provided for @onboardingBirthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get onboardingBirthDateLabel;

  /// No description provided for @onboardingBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick your birthday'**
  String get onboardingBirthDateHint;

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

  /// No description provided for @profileBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get profileBirthDate;

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

  /// No description provided for @workoutCalendarExportedPlan.
  ///
  /// In en, this message translates to:
  /// **'Workout plan exported'**
  String get workoutCalendarExportedPlan;

  /// No description provided for @workoutCalendarExportPlanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export your plan. {error}'**
  String workoutCalendarExportPlanFailed(String error);

  /// No description provided for @workoutCalendarImportPlanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import that plan. {error}'**
  String workoutCalendarImportPlanFailed(String error);

  /// No description provided for @workoutCalendarImportFileHint.
  ///
  /// In en, this message translates to:
  /// **'Check that the file is a workout plan exported from this app.'**
  String get workoutCalendarImportFileHint;

  /// No description provided for @workoutCalendarImportedPlan.
  ///
  /// In en, this message translates to:
  /// **'Workout plan imported'**
  String get workoutCalendarImportedPlan;

  /// No description provided for @workoutCalendarLoadWorkoutsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your workouts. {error}'**
  String workoutCalendarLoadWorkoutsFailed(String error);

  /// No description provided for @workoutCalendarSimpleModeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Simple mode: log activities you did'**
  String get workoutCalendarSimpleModeSemantics;

  /// No description provided for @workoutCalendarAdvancedModeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Advanced mode: weekly gym plans'**
  String get workoutCalendarAdvancedModeSemantics;

  /// No description provided for @workoutCalendarReadyMadePlans.
  ///
  /// In en, this message translates to:
  /// **'Ready-made and saved plans'**
  String get workoutCalendarReadyMadePlans;

  /// No description provided for @workoutCalendarExportMyPlan.
  ///
  /// In en, this message translates to:
  /// **'Export my plan'**
  String get workoutCalendarExportMyPlan;

  /// No description provided for @workoutCalendarImportPlan.
  ///
  /// In en, this message translates to:
  /// **'Import a plan'**
  String get workoutCalendarImportPlan;

  /// No description provided for @workoutCalendarLoadPlanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your plan. {error}'**
  String workoutCalendarLoadPlanFailed(String error);

  /// No description provided for @workoutCalendarNoPlanYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a workout plan yet'**
  String get workoutCalendarNoPlanYet;

  /// No description provided for @workoutCalendarNothingPlannedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for this week'**
  String get workoutCalendarNothingPlannedThisWeek;

  /// No description provided for @workoutCalendarThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get workoutCalendarThisWeek;

  /// No description provided for @workoutCalendarNextWeekRelative.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get workoutCalendarNextWeekRelative;

  /// No description provided for @workoutCalendarLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get workoutCalendarLastWeek;

  /// No description provided for @workoutCalendarAddToDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to this day'**
  String get workoutCalendarAddToDayTooltip;

  /// No description provided for @workoutCalendarAddWorkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add this workout. {error}'**
  String workoutCalendarAddWorkoutFailed(String error);

  /// No description provided for @workoutCalendarPlanStartsWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Your plan starts the week of {date}.'**
  String workoutCalendarPlanStartsWeekOf(String date);

  /// No description provided for @workoutCalendarShowThatWeek.
  ///
  /// In en, this message translates to:
  /// **'Show that week'**
  String get workoutCalendarShowThatWeek;

  /// No description provided for @workoutCalendarNewToWorkingOut.
  ///
  /// In en, this message translates to:
  /// **'New to working out?'**
  String get workoutCalendarNewToWorkingOut;

  /// No description provided for @workoutCalendarReadyMadePitch.
  ///
  /// In en, this message translates to:
  /// **'Start with a ready-made plan. Full Body is 3 days a week and we fill in the exercises for you.'**
  String get workoutCalendarReadyMadePitch;

  /// No description provided for @workoutCalendarChooseReadyMadePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a ready-made plan'**
  String get workoutCalendarChooseReadyMadePlan;

  /// No description provided for @workoutCalendarBuildOwnPlan.
  ///
  /// In en, this message translates to:
  /// **'Build my own plan'**
  String get workoutCalendarBuildOwnPlan;

  /// No description provided for @workoutDetailScreenExportWorkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export this workout. {error}'**
  String workoutDetailScreenExportWorkoutFailed(String error);

  /// No description provided for @workoutDetailScreenLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this workout. {error}'**
  String workoutDetailScreenLoadFailed(String error);

  /// No description provided for @workoutDetailScreenEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get workoutDetailScreenEditTooltip;

  /// No description provided for @workoutDetailScreenDurationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String workoutDetailScreenDurationSeconds(int seconds);

  /// No description provided for @workoutDetailsIntensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get workoutDetailsIntensityLight;

  /// No description provided for @workoutDetailsIntensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get workoutDetailsIntensityModerate;

  /// No description provided for @workoutDetailsIntensityVigorous.
  ///
  /// In en, this message translates to:
  /// **'Vigorous'**
  String get workoutDetailsIntensityVigorous;

  /// No description provided for @workoutDetailsEnterMinutes.
  ///
  /// In en, this message translates to:
  /// **'Please enter how many minutes you exercised'**
  String get workoutDetailsEnterMinutes;

  /// No description provided for @workoutDetailsLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Nice work! Logged {minutes} min. You\'ll see it on the Today tab.'**
  String workoutDetailsLoggedSuccess(int minutes);

  /// No description provided for @workoutDetailsLogFailed.
  ///
  /// In en, this message translates to:
  /// **'Error: couldn\'t log this activity. {error}'**
  String workoutDetailsLogFailed(String error);

  /// No description provided for @workoutDetailsAboutActivity.
  ///
  /// In en, this message translates to:
  /// **'About this activity'**
  String get workoutDetailsAboutActivity;

  /// No description provided for @workoutDetailsBurnsAbout.
  ///
  /// In en, this message translates to:
  /// **'Burns about'**
  String get workoutDetailsBurnsAbout;

  /// No description provided for @workoutDetailsKcalPerHour.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal/hour'**
  String workoutDetailsKcalPerHour(String kcal);

  /// No description provided for @workoutDetailsLogActivity.
  ///
  /// In en, this message translates to:
  /// **'Log this activity'**
  String get workoutDetailsLogActivity;

  /// No description provided for @workoutDetailsWhenTapToChange.
  ///
  /// In en, this message translates to:
  /// **'When (tap to change)'**
  String get workoutDetailsWhenTapToChange;

  /// No description provided for @workoutDetailsHowManyMinutes.
  ///
  /// In en, this message translates to:
  /// **'How many minutes?'**
  String get workoutDetailsHowManyMinutes;

  /// No description provided for @workoutDetailsAboutKcalBurned.
  ///
  /// In en, this message translates to:
  /// **'About {kcal} kcal burned'**
  String workoutDetailsAboutKcalBurned(int kcal);

  /// No description provided for @workoutDetailsIDidThis.
  ///
  /// In en, this message translates to:
  /// **'I did this'**
  String get workoutDetailsIDidThis;

  /// No description provided for @exerciseSelectionAllBodyParts.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exerciseSelectionAllBodyParts;

  /// No description provided for @savedCyclesSuggestedFullBodyName.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get savedCyclesSuggestedFullBodyName;

  /// No description provided for @savedCyclesSuggestedFullBodyDescription.
  ///
  /// In en, this message translates to:
  /// **'Whole body, 3 days a week with rest days in between. The best place to start.'**
  String get savedCyclesSuggestedFullBodyDescription;

  /// No description provided for @savedCyclesSuggestedUpperLowerName.
  ///
  /// In en, this message translates to:
  /// **'Upper / Lower'**
  String get savedCyclesSuggestedUpperLowerName;

  /// No description provided for @savedCyclesSuggestedUpperLowerDescription.
  ///
  /// In en, this message translates to:
  /// **'Upper body one day, legs the next. Try it once 3 days feels easy.'**
  String get savedCyclesSuggestedUpperLowerDescription;

  /// No description provided for @savedCyclesSuggestedPushPullLegsName.
  ///
  /// In en, this message translates to:
  /// **'Push Pull Legs'**
  String get savedCyclesSuggestedPushPullLegsName;

  /// No description provided for @savedCyclesSuggestedPushPullLegsDescription.
  ///
  /// In en, this message translates to:
  /// **'Different muscles each day. For people who already train often.'**
  String get savedCyclesSuggestedPushPullLegsDescription;

  /// No description provided for @savedCyclesStartPlanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start this plan. {error}'**
  String savedCyclesStartPlanFailed(String error);

  /// No description provided for @savedCyclesDeletePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete saved plan'**
  String get savedCyclesDeletePlanTitle;

  /// No description provided for @savedCyclesThisPlan.
  ///
  /// In en, this message translates to:
  /// **'this plan'**
  String get savedCyclesThisPlan;

  /// No description provided for @savedCyclesDeletePlanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete this plan. {error}'**
  String savedCyclesDeletePlanFailed(String error);

  /// No description provided for @savedCyclesReadyMadeTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-made plans'**
  String get savedCyclesReadyMadeTitle;

  /// No description provided for @savedCyclesReadyMadeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one and we\'ll fill in the exercises for each training day. Not sure? Start with Full Body.'**
  String get savedCyclesReadyMadeSubtitle;

  /// No description provided for @savedCyclesBeginnerBadge.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get savedCyclesBeginnerBadge;

  /// No description provided for @savedCyclesDaysAWeekWeeks.
  ///
  /// In en, this message translates to:
  /// **'{days} days a week · {weeks} weeks'**
  String savedCyclesDaysAWeekWeeks(int days, int weeks);

  /// No description provided for @savedCyclesPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout plans'**
  String get savedCyclesPlansTitle;

  /// No description provided for @savedCyclesLoadPlansFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your plans. {error}'**
  String savedCyclesLoadPlansFailed(String error);

  /// No description provided for @savedCyclesYourPlans.
  ///
  /// In en, this message translates to:
  /// **'Your saved plans'**
  String get savedCyclesYourPlans;

  /// No description provided for @savedCyclesNoPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No saved plans yet'**
  String get savedCyclesNoPlansYet;

  /// No description provided for @savedCyclesPlansAutoSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Every plan you create is saved here so you can reuse it later.'**
  String get savedCyclesPlansAutoSavedHint;

  /// No description provided for @savedCyclesUnnamedPlan.
  ///
  /// In en, this message translates to:
  /// **'Unnamed plan'**
  String get savedCyclesUnnamedPlan;

  /// No description provided for @newWorkoutCycleRefreshWorkoutListTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh workout list'**
  String get newWorkoutCycleRefreshWorkoutListTooltip;

  /// No description provided for @newWorkoutCyclePlanNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get newWorkoutCyclePlanNameLabel;

  /// No description provided for @newWorkoutCyclePlanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Push Pull Legs'**
  String get newWorkoutCyclePlanNameHint;

  /// No description provided for @newWorkoutCyclePlanNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give it a name so you can save and reuse this plan later'**
  String get newWorkoutCyclePlanNameSubtitle;

  /// No description provided for @newWorkoutCycleDescriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get newWorkoutCycleDescriptionOptionalLabel;

  /// No description provided for @newWorkoutCycleDescriptionExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3 days a week to get stronger'**
  String get newWorkoutCycleDescriptionExampleHint;

  /// No description provided for @newWorkoutCyclePlanStartHint.
  ///
  /// In en, this message translates to:
  /// **'Your plan will start on this date'**
  String get newWorkoutCyclePlanStartHint;

  /// No description provided for @newWorkoutCycleNumberOfWeeksLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of Weeks'**
  String get newWorkoutCycleNumberOfWeeksLabel;

  /// No description provided for @newWorkoutCyclePlanRepeatsFor.
  ///
  /// In en, this message translates to:
  /// **'Your plan will repeat every week for {weeks} weeks'**
  String newWorkoutCyclePlanRepeatsFor(int weeks);

  /// No description provided for @newWorkoutCycleWorkoutScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Schedule'**
  String get newWorkoutCycleWorkoutScheduleTitle;

  /// No description provided for @newWorkoutCycleWorkoutScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose workouts for each day of the week'**
  String get newWorkoutCycleWorkoutScheduleSubtitle;

  /// No description provided for @newWorkoutCycleTemplateSuggestsDays.
  ///
  /// In en, this message translates to:
  /// **'This template suggests {total} training day(s), marked below. Pick a workout for the {pending} day(s) still highlighted in orange — everything else stays a rest day unless you change it.'**
  String newWorkoutCycleTemplateSuggestsDays(int total, int pending);

  /// No description provided for @newWorkoutCycleAllSuggestedDaysAssigned.
  ///
  /// In en, this message translates to:
  /// **'All suggested training days have a workout assigned.'**
  String get newWorkoutCycleAllSuggestedDaysAssigned;

  /// No description provided for @newWorkoutCycleLoadingCustomWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Loading your custom workouts...'**
  String get newWorkoutCycleLoadingCustomWorkouts;

  /// No description provided for @newWorkoutCycleNoCustomWorkoutsFound.
  ///
  /// In en, this message translates to:
  /// **'No custom workouts found'**
  String get newWorkoutCycleNoCustomWorkoutsFound;

  /// No description provided for @newWorkoutCycleCreateWorkoutFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Create a workout first, then add it to your plan'**
  String get newWorkoutCycleCreateWorkoutFirstHint;

  /// No description provided for @newWorkoutCycleDeleteWorkoutRestDayConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Any day using it will become a rest day.'**
  String newWorkoutCycleDeleteWorkoutRestDayConfirm(String name);

  /// No description provided for @newWorkoutCycleDeleteThisWorkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete this workout. {error}'**
  String newWorkoutCycleDeleteThisWorkoutFailed(String error);

  /// No description provided for @newWorkoutCycleNoCustomWorkoutsYetShort.
  ///
  /// In en, this message translates to:
  /// **'No custom workouts yet'**
  String get newWorkoutCycleNoCustomWorkoutsYetShort;

  /// No description provided for @newWorkoutCycleRecommendedTrainingDay.
  ///
  /// In en, this message translates to:
  /// **'Recommended training day'**
  String get newWorkoutCycleRecommendedTrainingDay;

  /// No description provided for @newWorkoutCycleChooseWorkout.
  ///
  /// In en, this message translates to:
  /// **'Choose a workout'**
  String get newWorkoutCycleChooseWorkout;

  /// No description provided for @newWorkoutCycleAddNewWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add New Workout'**
  String get newWorkoutCycleAddNewWorkout;

  /// No description provided for @newWorkoutCycleCreatePlanButton.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get newWorkoutCycleCreatePlanButton;

  /// No description provided for @newWorkoutCycleCreatingPlan.
  ///
  /// In en, this message translates to:
  /// **'Creating your workout plan...'**
  String get newWorkoutCycleCreatingPlan;

  /// No description provided for @newWorkoutCycleCreatePlanFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your plan'**
  String get newWorkoutCycleCreatePlanFailedTitle;

  /// No description provided for @newWorkoutCycleLoadWorkoutsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your workouts. {error}'**
  String newWorkoutCycleLoadWorkoutsFailed(String error);

  /// No description provided for @loginCouldNotLogIn.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t log you in. Please try again.'**
  String get loginCouldNotLogIn;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginLogIn;

  /// No description provided for @loginCreateOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get loginCreateOne;

  /// No description provided for @registerCouldNotCreate.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your account. Please try again.'**
  String get registerCouldNotCreate;

  /// No description provided for @registerPrivacyAgreement.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to our Privacy Policy'**
  String get registerPrivacyAgreement;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your account\'s email and we\'ll send you a code to reset your password.'**
  String get forgotPasswordIntro;

  /// No description provided for @forgotPasswordCodeSentIntro.
  ///
  /// In en, this message translates to:
  /// **'If {email} has an account, we sent it a 6-digit code. Enter it below with your new password.'**
  String forgotPasswordCodeSentIntro(String email);

  /// No description provided for @forgotPasswordCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get forgotPasswordCodeLabel;

  /// No description provided for @forgotPasswordCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from the email'**
  String get forgotPasswordCodeInvalid;

  /// No description provided for @forgotPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get forgotPasswordNewPasswordLabel;

  /// No description provided for @forgotPasswordConfirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get forgotPasswordConfirmNewPasswordLabel;

  /// No description provided for @forgotPasswordChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get forgotPasswordChangeButton;

  /// No description provided for @forgotPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPasswordSendCode;

  /// No description provided for @forgotPasswordResend.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? Send a new code'**
  String get forgotPasswordResend;

  /// No description provided for @forgotPasswordSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the code. Please try again.'**
  String get forgotPasswordSendFailed;

  /// No description provided for @forgotPasswordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t change your password. Please try again.'**
  String get forgotPasswordChangeFailed;

  /// No description provided for @forgotPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. You can log in now.'**
  String get forgotPasswordChanged;

  /// No description provided for @helpCommonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get helpCommonQuestions;

  /// No description provided for @helpFaqLogFoodQ.
  ///
  /// In en, this message translates to:
  /// **'How do I log what I ate?'**
  String get helpFaqLogFoodQ;

  /// No description provided for @helpFaqLogFoodA.
  ///
  /// In en, this message translates to:
  /// **'On the Today tab, tap \"Add\" next to the meal (Breakfast, Lunch, Dinner or Snacks). Search for the food, enter how many grams you ate and tap \"Add\". You can also scan a barcode on the Foods tab.'**
  String get helpFaqLogFoodA;

  /// No description provided for @helpFaqNoScaleQ.
  ///
  /// In en, this message translates to:
  /// **'I don\'t weigh my food. What should I enter?'**
  String get helpFaqNoScaleQ;

  /// No description provided for @helpFaqNoScaleA.
  ///
  /// In en, this message translates to:
  /// **'A rough guess is fine. A slice of bread is about 30 g, an apple about 150 g, a cup of cooked rice about 160 g and a chicken breast about 170 g. Use the quick buttons (50, 100, 150, 200 g) as a starting point.'**
  String get helpFaqNoScaleA;

  /// No description provided for @helpFaqKcalLeftQ.
  ///
  /// In en, this message translates to:
  /// **'What does \"kcal left\" mean?'**
  String get helpFaqKcalLeftQ;

  /// No description provided for @helpFaqKcalLeftA.
  ///
  /// In en, this message translates to:
  /// **'It is how many more calories you can eat today and still stay on track for your goal. If you go over, the number turns red. One day over is fine; what matters is most days.'**
  String get helpFaqKcalLeftA;

  /// No description provided for @helpFaqMacrosQ.
  ///
  /// In en, this message translates to:
  /// **'What are protein, carbs and fat?'**
  String get helpFaqMacrosQ;

  /// No description provided for @helpFaqMacrosA.
  ///
  /// In en, this message translates to:
  /// **'They are the three nutrients that give food its calories. Protein helps build and repair muscle, carbs are your main energy source, and fat supports your body in many ways. Focus on calories first, then on getting enough protein.'**
  String get helpFaqMacrosA;

  /// No description provided for @helpFaqCalorieGoalQ.
  ///
  /// In en, this message translates to:
  /// **'How is my daily calorie goal worked out?'**
  String get helpFaqCalorieGoalQ;

  /// No description provided for @helpFaqCalorieGoalA.
  ///
  /// In en, this message translates to:
  /// **'From your age, weight, height, gender and how active you are (your workouts included), we estimate how many calories you burn on a typical day. To lose weight we take away 500 (less if your burn is small, and never below 1,200 kcal for women or 1,500 for men); to build muscle we add up to 300. Workouts you log are shown but not added again, because your activity level already counts them.'**
  String get helpFaqCalorieGoalA;

  /// No description provided for @helpFaqLogExerciseQ.
  ///
  /// In en, this message translates to:
  /// **'How do I log exercise?'**
  String get helpFaqLogExerciseQ;

  /// No description provided for @helpFaqLogExerciseA.
  ///
  /// In en, this message translates to:
  /// **'Go to the Workouts tab. In Simple mode, find the activity (walking, cycling, …), tap it, choose how many minutes and tap \"I did this\".'**
  String get helpFaqLogExerciseA;

  /// No description provided for @helpFaqAdvancedModeQ.
  ///
  /// In en, this message translates to:
  /// **'What is Advanced mode?'**
  String get helpFaqAdvancedModeQ;

  /// No description provided for @helpFaqAdvancedModeA.
  ///
  /// In en, this message translates to:
  /// **'Advanced mode is for planning gym workouts week by week. If you are new, choose a ready-made plan: Full Body is 3 days a week and we fill in the exercises for you.'**
  String get helpFaqAdvancedModeA;

  /// No description provided for @helpFaqChangeGoalQ.
  ///
  /// In en, this message translates to:
  /// **'How do I change my weight or goal?'**
  String get helpFaqChangeGoalQ;

  /// No description provided for @helpFaqChangeGoalA.
  ///
  /// In en, this message translates to:
  /// **'Go to the Me tab and tap the edit button at the top. To track your weight over time, use \"Weight log\" on the same tab.'**
  String get helpFaqChangeGoalA;

  /// No description provided for @helpDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Calorie goals, calories burned and BMI in this app are estimates to guide you, not medical advice. If you have a health condition, are pregnant, or plan a big change in diet or exercise, check with a doctor first.'**
  String get helpDisclaimer;

  /// No description provided for @helpEmailUs.
  ///
  /// In en, this message translates to:
  /// **'Still stuck? Email us'**
  String get helpEmailUs;

  /// No description provided for @helpNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. You can write to {email}.'**
  String helpNoEmailApp(String email);

  /// No description provided for @appTextFieldHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get appTextFieldHidePassword;

  /// No description provided for @appTextFieldShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get appTextFieldShowPassword;

  /// No description provided for @adaptiveDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get adaptiveDone;

  /// No description provided for @privacyPolicyOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the privacy policy. It\'s at {url}'**
  String privacyPolicyOpenFailed(String url);

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your details. {error}'**
  String onboardingSaveFailed(String error);

  /// No description provided for @onboardingBodyStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We only use these to work out how much you should eat each day. You can change them any time.'**
  String get onboardingBodyStatsSubtitle;

  /// No description provided for @onboardingUnitsMetric.
  ///
  /// In en, this message translates to:
  /// **'kg / cm'**
  String get onboardingUnitsMetric;

  /// No description provided for @onboardingUnitsImperial.
  ///
  /// In en, this message translates to:
  /// **'lb / ft'**
  String get onboardingUnitsImperial;

  /// No description provided for @onboardingWeightLbLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (lb)'**
  String get onboardingWeightLbLabel;

  /// No description provided for @onboardingWeightLbHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 155'**
  String get onboardingWeightLbHint;

  /// No description provided for @onboardingHeightFtLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (ft)'**
  String get onboardingHeightFtLabel;

  /// No description provided for @onboardingHeightFtHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get onboardingHeightFtHint;

  /// No description provided for @onboardingHeightInLabel.
  ///
  /// In en, this message translates to:
  /// **'(in)'**
  String get onboardingHeightInLabel;

  /// No description provided for @onboardingHeightInHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 9'**
  String get onboardingHeightInHint;

  /// No description provided for @onboardingFillStats.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your date of birth, weight and height'**
  String get onboardingFillStats;

  /// No description provided for @onboardingBmiCardLabel.
  ///
  /// In en, this message translates to:
  /// **'BMI (your weight compared to your height)'**
  String get onboardingBmiCardLabel;

  /// No description provided for @onboardingGenderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Men and women burn calories at slightly different rates'**
  String get onboardingGenderSubtitle;

  /// No description provided for @onboardingBmrCaption.
  ///
  /// In en, this message translates to:
  /// **'Calories your body burns resting'**
  String get onboardingBmrCaption;

  /// No description provided for @onboardingBmrFootnote.
  ///
  /// In en, this message translates to:
  /// **'Even if you stayed in bed all day'**
  String get onboardingBmrFootnote;

  /// No description provided for @onboardingKcalValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String onboardingKcalValue(String value);

  /// No description provided for @onboardingKcalPerDayValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal/day'**
  String onboardingKcalPerDayValue(String value);

  /// No description provided for @onboardingTdeeCaption.
  ///
  /// In en, this message translates to:
  /// **'Calories you burn on a typical day'**
  String get onboardingTdeeCaption;

  /// No description provided for @onboardingTdeeFootnote.
  ///
  /// In en, this message translates to:
  /// **'Including your daily activity'**
  String get onboardingTdeeFootnote;

  /// No description provided for @onboardingActMostlySitting.
  ///
  /// In en, this message translates to:
  /// **'Mostly sitting'**
  String get onboardingActMostlySitting;

  /// No description provided for @onboardingActMostlySittingDesc.
  ///
  /// In en, this message translates to:
  /// **'Desk job, little or no exercise'**
  String get onboardingActMostlySittingDesc;

  /// No description provided for @onboardingActLightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get onboardingActLightlyActive;

  /// No description provided for @onboardingActLightlyActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Walks or light exercise 1–3 days a week'**
  String get onboardingActLightlyActiveDesc;

  /// No description provided for @onboardingActModeratelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get onboardingActModeratelyActive;

  /// No description provided for @onboardingActModeratelyActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 3–5 days a week'**
  String get onboardingActModeratelyActiveDesc;

  /// No description provided for @onboardingActActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise 6–7 days a week'**
  String get onboardingActActiveDesc;

  /// No description provided for @onboardingActVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get onboardingActVeryActive;

  /// No description provided for @onboardingActVeryActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical job or training twice a day'**
  String get onboardingActVeryActiveDesc;

  /// No description provided for @onboardingGoalLoseWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get onboardingGoalLoseWeightLabel;

  /// No description provided for @onboardingGoalLoseWeightDetail.
  ///
  /// In en, this message translates to:
  /// **'Eat a bit less than you burn (about 0.5 kg a week)'**
  String get onboardingGoalLoseWeightDetail;

  /// No description provided for @onboardingGoalBuildMuscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get onboardingGoalBuildMuscleLabel;

  /// No description provided for @onboardingGoalBuildMuscleDetail.
  ///
  /// In en, this message translates to:
  /// **'Eat a bit more than you burn, and do strength training'**
  String get onboardingGoalBuildMuscleDetail;

  /// No description provided for @onboardingGoalStayLabel.
  ///
  /// In en, this message translates to:
  /// **'Stay at my weight'**
  String get onboardingGoalStayLabel;

  /// No description provided for @onboardingGoalStayDetail.
  ///
  /// In en, this message translates to:
  /// **'Eat about what you burn'**
  String get onboardingGoalStayDetail;

  /// No description provided for @onboardingOffsetLose.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal less than you burn on a typical day'**
  String onboardingOffsetLose(int kcal);

  /// No description provided for @onboardingOffsetGain.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal more than you burn on a typical day'**
  String onboardingOffsetGain(int kcal);

  /// No description provided for @onboardingOffsetSame.
  ///
  /// In en, this message translates to:
  /// **'The same as you burn on a typical day'**
  String get onboardingOffsetSame;

  /// No description provided for @onboardingDailyGoalCaption.
  ///
  /// In en, this message translates to:
  /// **'Your daily calorie goal'**
  String get onboardingDailyGoalCaption;

  /// No description provided for @newWorkoutCouldNotLoadExercises.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load exercises. {error}'**
  String newWorkoutCouldNotLoadExercises(String error);

  /// No description provided for @workoutModeSimpleSemantics.
  ///
  /// In en, this message translates to:
  /// **'Simple mode: log activities you did'**
  String get workoutModeSimpleSemantics;

  /// No description provided for @workoutModeAdvancedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Advanced mode: weekly gym plans'**
  String get workoutModeAdvancedSemantics;

  /// No description provided for @workoutSimpleIntro.
  ///
  /// In en, this message translates to:
  /// **'Did some exercise? Find the activity and log it to count the calories you burned.'**
  String get workoutSimpleIntro;

  /// No description provided for @workoutSearchActivitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search activities (e.g. walking)'**
  String get workoutSearchActivitiesHint;

  /// No description provided for @workoutCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get workoutCategoryAll;

  /// No description provided for @workoutActivitiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} activity} other{{count} activities}}'**
  String workoutActivitiesCount(int count);

  /// No description provided for @workoutActivitiesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load activities'**
  String get workoutActivitiesLoadError;

  /// No description provided for @workoutNoActivitiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No activities available'**
  String get workoutNoActivitiesAvailable;

  /// No description provided for @workoutNoActivitiesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No activities match your search'**
  String get workoutNoActivitiesMatchSearch;

  /// No description provided for @workoutKcalPerHour.
  ///
  /// In en, this message translates to:
  /// **'≈ {kcal} kcal per hour'**
  String workoutKcalPerHour(int kcal);

  /// No description provided for @workoutKcalPerHourPerKg.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal per hour per kg of body weight'**
  String workoutKcalPerHourPerKg(String value);

  /// No description provided for @progressLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your weight log. {error}'**
  String progressLoadError(String error);

  /// No description provided for @progressSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this entry. {error}'**
  String progressSaveError(String error);

  /// No description provided for @achievementCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load achievements. {error}'**
  String achievementCouldNotLoad(String error);

  /// No description provided for @achievementTypeMeals.
  ///
  /// In en, this message translates to:
  /// **'MEALS'**
  String get achievementTypeMeals;

  /// No description provided for @achievementTypeStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get achievementTypeStreak;

  /// No description provided for @achievementTypeCalories.
  ///
  /// In en, this message translates to:
  /// **'CALORIES'**
  String get achievementTypeCalories;

  /// No description provided for @achievementTypeWorkouts.
  ///
  /// In en, this message translates to:
  /// **'WORKOUTS'**
  String get achievementTypeWorkouts;

  /// No description provided for @achievementTypeCardio.
  ///
  /// In en, this message translates to:
  /// **'CARDIO'**
  String get achievementTypeCardio;

  /// No description provided for @achievementTypeProgress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get achievementTypeProgress;

  /// No description provided for @achievementTypeWeight.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get achievementTypeWeight;

  /// No description provided for @achievementTypeMuscle.
  ///
  /// In en, this message translates to:
  /// **'MUSCLE'**
  String get achievementTypeMuscle;

  /// No description provided for @foodsProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that product. Try searching by name, or add it yourself with the + button.'**
  String get foodsProductNotFound;

  /// No description provided for @foodsScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t scan the barcode. {error}'**
  String foodsScanFailed(String error);

  /// No description provided for @foodsAddToMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String foodsAddToMealTitle(String meal);

  /// No description provided for @foodsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get foodsTryAgain;

  /// No description provided for @foodsKcalPer100g.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal per 100 g'**
  String foodsKcalPer100g(int value);

  /// No description provided for @foodsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No foods match your search.'**
  String get foodsNoMatch;

  /// No description provided for @foodsAddOwnFood.
  ///
  /// In en, this message translates to:
  /// **'Add your own food'**
  String get foodsAddOwnFood;

  /// No description provided for @foodsNewFoodButton.
  ///
  /// In en, this message translates to:
  /// **'New food'**
  String get foodsNewFoodButton;

  /// No description provided for @foodsProteinPer100g.
  ///
  /// In en, this message translates to:
  /// **'Protein: {value} per 100 g'**
  String foodsProteinPer100g(String value);

  /// No description provided for @foodsCarbsPer100g.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {value} per 100 g'**
  String foodsCarbsPer100g(String value);

  /// No description provided for @foodsFatPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fat: {value} per 100 g'**
  String foodsFatPer100g(String value);

  /// No description provided for @foodsProteinPill.
  ///
  /// In en, this message translates to:
  /// **'Protein {value}'**
  String foodsProteinPill(String value);

  /// No description provided for @foodsCarbsPill.
  ///
  /// In en, this message translates to:
  /// **'Carbs {value}'**
  String foodsCarbsPill(String value);

  /// No description provided for @foodsFatPill.
  ///
  /// In en, this message translates to:
  /// **'Fat {value}'**
  String foodsFatPill(String value);

  /// No description provided for @foodsSearchFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get foodsSearchFoodsHint;

  /// No description provided for @foodsScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode'**
  String get foodsScanTooltip;

  /// No description provided for @foodDetailsMealNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please type a name for this meal.'**
  String get foodDetailsMealNameRequired;

  /// No description provided for @foodDetailsGramsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter how many grams you ate.'**
  String get foodDetailsGramsRequired;

  /// No description provided for @foodDetailsAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added {grams} g of {name} to {meal} ({kcal} kcal)'**
  String foodDetailsAddedSnack(int grams, String name, String meal, int kcal);

  /// No description provided for @foodDetailsAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add this food. {error}'**
  String foodDetailsAddFailed(String error);

  /// No description provided for @foodDetailsFavoritesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update favorites. {error}'**
  String foodDetailsFavoritesFailed(String error);

  /// No description provided for @foodDetailsNutritionPer100g.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 g'**
  String get foodDetailsNutritionPer100g;

  /// No description provided for @foodDetailsHowMuch.
  ///
  /// In en, this message translates to:
  /// **'How much did you eat?'**
  String get foodDetailsHowMuch;

  /// No description provided for @foodDetailsAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get foodDetailsAmountLabel;

  /// No description provided for @foodDetailsGramsSuffix.
  ///
  /// In en, this message translates to:
  /// **'grams'**
  String get foodDetailsGramsSuffix;

  /// No description provided for @foodDetailsPortionHint.
  ///
  /// In en, this message translates to:
  /// **'Not sure? A slice of bread is about 30 g, an apple about 150 g, a cup of cooked rice about 160 g.'**
  String get foodDetailsPortionHint;

  /// No description provided for @foodDetailsEnterAmountForCalories.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount to see the calories'**
  String get foodDetailsEnterAmountForCalories;

  /// No description provided for @foodDetailsLiveTotal.
  ///
  /// In en, this message translates to:
  /// **'{grams} g = {kcal} kcal  ·  Protein {protein} g  ·  Carbs {carbs} g  ·  Fat {fat} g'**
  String foodDetailsLiveTotal(
    String grams,
    int kcal,
    String protein,
    String carbs,
    String fat,
  );

  /// No description provided for @foodDetailsWhichMeal.
  ///
  /// In en, this message translates to:
  /// **'Which meal?'**
  String get foodDetailsWhichMeal;

  /// No description provided for @foodDetailsSnackChip.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get foodDetailsSnackChip;

  /// No description provided for @foodDetailsOtherMeal.
  ///
  /// In en, this message translates to:
  /// **'Other…'**
  String get foodDetailsOtherMeal;

  /// No description provided for @foodDetailsMealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get foodDetailsMealNameLabel;

  /// No description provided for @foodDetailsMealNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pre-workout, Late night'**
  String get foodDetailsMealNameHint;

  /// No description provided for @foodDetailsChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get foodDetailsChangeDate;

  /// No description provided for @foodDetailsAddToMealButton.
  ///
  /// In en, this message translates to:
  /// **'Add to meal'**
  String get foodDetailsAddToMealButton;

  /// No description provided for @foodDetailsAddToButton.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String foodDetailsAddToButton(String meal);

  /// No description provided for @mealDetailRemoveFoodTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove food'**
  String get mealDetailRemoveFoodTooltip;

  /// No description provided for @mealHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Past days'**
  String get mealHistoryTitle;

  /// No description provided for @mealHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No meals logged on earlier days yet.'**
  String get mealHistoryEmpty;

  /// No description provided for @mealHistoryKcalEaten.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal eaten'**
  String mealHistoryKcalEaten(int kcal);

  /// No description provided for @homeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'What do these mean?'**
  String get homeHelpTitle;

  /// No description provided for @homeHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal) measure the energy in food. Eating about your daily goal helps you reach your target weight.\n\nProtein, carbs and fat are the three nutrients that give food its calories. Protein helps build and repair muscle, carbs give you energy, and fat supports your body in many ways.\n\nYou don\'t need to hit every number exactly. Focus on calories first, then try to get enough protein.'**
  String get homeHelpBody;

  /// No description provided for @homeHelpGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get homeHelpGotIt;

  /// No description provided for @homeHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'What do these numbers mean?'**
  String get homeHelpTooltip;

  /// No description provided for @homeYourMealsHeading.
  ///
  /// In en, this message translates to:
  /// **'Your meals'**
  String get homeYourMealsHeading;

  /// No description provided for @homeSeePastDays.
  ///
  /// In en, this message translates to:
  /// **'See past days'**
  String get homeSeePastDays;

  /// No description provided for @homeLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load today\'s data'**
  String get homeLoadErrorTitle;

  /// No description provided for @homeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeTryAgain;

  /// No description provided for @homeSemanticsEatenToday.
  ///
  /// In en, this message translates to:
  /// **'{count} calories eaten today'**
  String homeSemanticsEatenToday(int count);

  /// No description provided for @homeSemanticsOverGoal.
  ///
  /// In en, this message translates to:
  /// **'{count} calories over your goal today'**
  String homeSemanticsOverGoal(int count);

  /// No description provided for @homeSemanticsLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count} calories left today'**
  String homeSemanticsLeftToday(int count);

  /// No description provided for @homeKcalEaten.
  ///
  /// In en, this message translates to:
  /// **'kcal eaten'**
  String get homeKcalEaten;

  /// No description provided for @homeKcalOver.
  ///
  /// In en, this message translates to:
  /// **'kcal over'**
  String get homeKcalOver;

  /// No description provided for @homeKcalLeft.
  ///
  /// In en, this message translates to:
  /// **'kcal left'**
  String get homeKcalLeft;

  /// No description provided for @homeSummaryGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get homeSummaryGoal;

  /// No description provided for @homeSummaryEaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get homeSummaryEaten;

  /// No description provided for @homeSummaryExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get homeSummaryExercise;

  /// No description provided for @homeSummaryLabelKcal.
  ///
  /// In en, this message translates to:
  /// **'{label} (kcal)'**
  String homeSummaryLabelKcal(String label);

  /// No description provided for @homeFinishProfileForGoal.
  ///
  /// In en, this message translates to:
  /// **'Finish your profile on the Me tab to get a daily calorie goal.'**
  String get homeFinishProfileForGoal;

  /// No description provided for @homeExerciseAddedToGoal.
  ///
  /// In en, this message translates to:
  /// **'Your activity level already counts your workouts, so they don\'t change your goal.'**
  String get homeExerciseAddedToGoal;

  /// No description provided for @homeNutrientOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{eaten} of {goal} g'**
  String homeNutrientOfGoal(int eaten, int goal);

  /// No description provided for @homeNothingAddedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing added yet'**
  String get homeNothingAddedYet;

  /// No description provided for @homeFoodsAndMore.
  ///
  /// In en, this message translates to:
  /// **'{names} and {count} more'**
  String homeFoodsAndMore(String names, int count);

  /// No description provided for @homeAddFoodToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add food to {meal}'**
  String homeAddFoodToMeal(String meal);

  /// No description provided for @homeAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get homeAddButton;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// No description provided for @profileChangePhotoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileChangePhotoTooltip;

  /// No description provided for @profileHowActive.
  ///
  /// In en, this message translates to:
  /// **'How active you are'**
  String get profileHowActive;

  /// No description provided for @profileYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get profileYourGoal;

  /// No description provided for @profileEditDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit my details'**
  String get profileEditDetails;

  /// No description provided for @profileWeightLog.
  ///
  /// In en, this message translates to:
  /// **'Weight log'**
  String get profileWeightLog;

  /// No description provided for @profileTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get profileTryAgain;

  /// No description provided for @notificationPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Want a reminder?'**
  String get notificationPromptTitle;

  /// No description provided for @notificationPromptBody.
  ///
  /// In en, this message translates to:
  /// **'We can nudge you when you haven\'t logged a meal or a workout, and tell you when you unlock a badge. You can change this any time in Settings.'**
  String get notificationPromptBody;

  /// No description provided for @notificationPromptNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationPromptNotNow;

  /// No description provided for @notificationPromptTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders'**
  String get notificationPromptTurnOn;

  /// No description provided for @settingsCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. {reason}'**
  String settingsCouldNotSave(String reason);

  /// No description provided for @settingsCouldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. {reason}'**
  String settingsCouldNotDelete(String reason);

  /// No description provided for @labelNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get labelNotSet;

  /// No description provided for @labelActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Mostly sitting'**
  String get labelActivitySedentary;

  /// No description provided for @labelActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get labelActivityLight;

  /// No description provided for @labelActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get labelActivityModerate;

  /// No description provided for @labelActivityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labelActivityActive;

  /// No description provided for @labelActivityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get labelActivityVeryActive;

  /// No description provided for @labelGoalWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get labelGoalWeightLoss;

  /// No description provided for @labelGoalMuscleGain.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get labelGoalMuscleGain;

  /// No description provided for @labelGoalMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Stay at my weight'**
  String get labelGoalMaintenance;

  /// No description provided for @labelGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get labelGenderMale;

  /// No description provided for @labelGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get labelGenderFemale;

  /// No description provided for @labelMealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get labelMealBreakfast;

  /// No description provided for @labelMealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get labelMealLunch;

  /// No description provided for @labelMealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get labelMealDinner;

  /// No description provided for @labelMealSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get labelMealSnacks;

  /// No description provided for @labelIntensityVigorous.
  ///
  /// In en, this message translates to:
  /// **'Vigorous'**
  String get labelIntensityVigorous;

  /// No description provided for @labelIntensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get labelIntensityModerate;

  /// No description provided for @labelIntensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get labelIntensityLight;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get errorTryAgain;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your internet connection and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please log in again.'**
  String get errorSessionEnded;

  /// No description provided for @apiCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Please check your details and try again.'**
  String get apiCheckDetails;

  /// No description provided for @apiTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get apiTooManyAttempts;

  /// No description provided for @apiWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password. Please try again.'**
  String get apiWrongCredentials;

  /// No description provided for @apiAccountDeactivated.
  ///
  /// In en, this message translates to:
  /// **'This account has been deactivated.'**
  String get apiAccountDeactivated;

  /// No description provided for @apiInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get apiInvalidEmail;

  /// No description provided for @apiResetCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'This code is wrong or has expired. Ask for a new one.'**
  String get apiResetCodeInvalid;

  /// No description provided for @achievementTargetMeals.
  ///
  /// In en, this message translates to:
  /// **'Log {target} meal(s)'**
  String achievementTargetMeals(int target);

  /// No description provided for @achievementTargetStreak.
  ///
  /// In en, this message translates to:
  /// **'Maintain a streak for {target} days'**
  String achievementTargetStreak(int target);

  /// No description provided for @achievementTargetCalories.
  ///
  /// In en, this message translates to:
  /// **'Reach {target} calories'**
  String achievementTargetCalories(int target);

  /// No description provided for @achievementTargetWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Complete {target} workout(s)'**
  String achievementTargetWorkouts(int target);

  /// No description provided for @achievementTargetCardio.
  ///
  /// In en, this message translates to:
  /// **'Complete {target} cardio session(s)'**
  String achievementTargetCardio(int target);

  /// No description provided for @achievementTargetProgress.
  ///
  /// In en, this message translates to:
  /// **'Log {target} progress update(s)'**
  String achievementTargetProgress(int target);

  /// No description provided for @achievementTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose {target} kg'**
  String achievementTargetWeight(int target);

  /// No description provided for @achievementTargetMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain {target} kg of muscle'**
  String achievementTargetMuscle(int target);

  /// No description provided for @achievementTargetTasks.
  ///
  /// In en, this message translates to:
  /// **'Complete {target} tasks'**
  String achievementTargetTasks(int target);

  /// No description provided for @achievementTargetCaloriesK.
  ///
  /// In en, this message translates to:
  /// **'Reach {thousands}k calories'**
  String achievementTargetCaloriesK(String thousands);

  /// No description provided for @mealScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan your meal with the camera'**
  String get mealScanTooltip;

  /// No description provided for @mealScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your meal'**
  String get mealScanTitle;

  /// No description provided for @mealScanLooking.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at your plate'**
  String get mealScanLooking;

  /// No description provided for @mealScanItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} food} other{{count} foods}}'**
  String mealScanItemCount(int count);

  /// No description provided for @mealScanKcal.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal'**
  String mealScanKcal(int kcal);

  /// No description provided for @mealScanScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get mealScanScanning;

  /// No description provided for @mealScanPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get mealScanPaused;

  /// No description provided for @mealScanPause.
  ///
  /// In en, this message translates to:
  /// **'Pause scanning'**
  String get mealScanPause;

  /// No description provided for @mealScanRescan.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get mealScanRescan;

  /// No description provided for @mealScanNoCamera.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the camera. Check that the app may use it in your phone\'s settings, or add foods by hand below.'**
  String get mealScanNoCamera;

  /// No description provided for @mealScanUnsureHint.
  ///
  /// In en, this message translates to:
  /// **'Foods marked ? may be wrong. Tap one to check it.'**
  String get mealScanUnsureHint;

  /// No description provided for @mealScanAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add a food'**
  String get mealScanAddItem;

  /// No description provided for @mealScanLogTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String mealScanLogTo(String meal);

  /// No description provided for @mealScanLogged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Added {count} food to {meal} ({kcal} kcal)} other{Added {count} foods to {meal} ({kcal} kcal)}}'**
  String mealScanLogged(int count, String meal, int kcal);

  /// No description provided for @mealScanLogFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the meal. {error}'**
  String mealScanLogFailed(String error);

  /// No description provided for @mealScanRow.
  ///
  /// In en, this message translates to:
  /// **'{grams} g · {kcal} kcal'**
  String mealScanRow(int grams, int kcal);

  /// No description provided for @mealScanRowUnsure.
  ///
  /// In en, this message translates to:
  /// **'{grams} g · not sure, tap to check'**
  String mealScanRowUnsure(int grams);

  /// No description provided for @mealScanChangeFood.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get mealScanChangeFood;

  /// No description provided for @mealScanRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mealScanRemove;

  /// No description provided for @mealScanDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mealScanDone;

  /// No description provided for @mealScanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Meal scanning isn\'t available right now. Add foods by hand below.'**
  String get mealScanUnavailable;

  /// No description provided for @mealScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the scanner. Tap the scan button to try again.'**
  String get mealScanFailed;

  /// No description provided for @storyCreate.
  ///
  /// In en, this message translates to:
  /// **'Create story'**
  String get storyCreate;

  /// No description provided for @storyChooseLayout.
  ///
  /// In en, this message translates to:
  /// **'Choose a layout'**
  String get storyChooseLayout;

  /// No description provided for @storyChooseLayoutHint.
  ///
  /// In en, this message translates to:
  /// **'Next you can add your photo, then move and edit everything.'**
  String get storyChooseLayoutHint;

  /// No description provided for @storyLayoutFullPhoto.
  ///
  /// In en, this message translates to:
  /// **'Full photo'**
  String get storyLayoutFullPhoto;

  /// No description provided for @storyLayoutPhotoPanel.
  ///
  /// In en, this message translates to:
  /// **'Photo + stats'**
  String get storyLayoutPhotoPanel;

  /// No description provided for @storyTemplateBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get storyTemplateBold;

  /// No description provided for @storyTemplateCentered.
  ///
  /// In en, this message translates to:
  /// **'Centered'**
  String get storyTemplateCentered;

  /// No description provided for @storyTemplateMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get storyTemplateMinimal;

  /// No description provided for @storyTemplatePanelBottom.
  ///
  /// In en, this message translates to:
  /// **'Panel below'**
  String get storyTemplatePanelBottom;

  /// No description provided for @storyTemplatePanelTop.
  ///
  /// In en, this message translates to:
  /// **'Panel above'**
  String get storyTemplatePanelTop;

  /// No description provided for @storyTemplateCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get storyTemplateCard;

  /// No description provided for @storyStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get storyStatusCompleted;

  /// No description provided for @storyStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned workout'**
  String get storyStatusPlanned;

  /// No description provided for @storyPlanCaption.
  ///
  /// In en, this message translates to:
  /// **'The plan'**
  String get storyPlanCaption;

  /// No description provided for @storyStatDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get storyStatDuration;

  /// No description provided for @storyStatDurationEstimated.
  ///
  /// In en, this message translates to:
  /// **'Est. time'**
  String get storyStatDurationEstimated;

  /// No description provided for @storyStatCalories.
  ///
  /// In en, this message translates to:
  /// **'kcal (est.)'**
  String get storyStatCalories;

  /// No description provided for @storyStatExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get storyStatExercises;

  /// No description provided for @storyStatSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get storyStatSets;

  /// No description provided for @storyStatReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get storyStatReps;

  /// No description provided for @storyMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String storyMinutes(int minutes);

  /// No description provided for @storyHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes}'**
  String storyHoursMinutes(int hours, String minutes);

  /// No description provided for @storyExerciseSetsReps.
  ///
  /// In en, this message translates to:
  /// **'{sets} × {reps}'**
  String storyExerciseSetsReps(int sets, int reps);

  /// No description provided for @storyExerciseSetsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{sets} × {seconds} s'**
  String storyExerciseSetsSeconds(int sets, int seconds);

  /// No description provided for @storyMoreExercises.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String storyMoreExercises(int count);

  /// No description provided for @storyBrand.
  ///
  /// In en, this message translates to:
  /// **'Fitness Tracker'**
  String get storyBrand;

  /// No description provided for @storyNewText.
  ///
  /// In en, this message translates to:
  /// **'Your text'**
  String get storyNewText;

  /// No description provided for @storyToolPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get storyToolPhoto;

  /// No description provided for @storyToolText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get storyToolText;

  /// No description provided for @storyToolStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get storyToolStats;

  /// No description provided for @storyToolStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get storyToolStyle;

  /// No description provided for @storyToolLayers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get storyToolLayers;

  /// No description provided for @storyAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get storyAddPhoto;

  /// No description provided for @storyGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get storyGallery;

  /// No description provided for @storyReplacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get storyReplacePhoto;

  /// No description provided for @storyCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get storyCamera;

  /// No description provided for @storyResetPhoto.
  ///
  /// In en, this message translates to:
  /// **'Recenter'**
  String get storyResetPhoto;

  /// No description provided for @storyPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom, drag to move the photo'**
  String get storyPhotoHint;

  /// No description provided for @storyDim.
  ///
  /// In en, this message translates to:
  /// **'Dim'**
  String get storyDim;

  /// No description provided for @storyGradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get storyGradient;

  /// No description provided for @storyAddText.
  ///
  /// In en, this message translates to:
  /// **'Add text'**
  String get storyAddText;

  /// No description provided for @storyAddExercises.
  ///
  /// In en, this message translates to:
  /// **'Add exercises'**
  String get storyAddExercises;

  /// No description provided for @storyAddStats.
  ///
  /// In en, this message translates to:
  /// **'Add statistics'**
  String get storyAddStats;

  /// No description provided for @storyTextHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a text on the story to select it, tap again to edit it.'**
  String get storyTextHint;

  /// No description provided for @storyEditText.
  ///
  /// In en, this message translates to:
  /// **'Edit text'**
  String get storyEditText;

  /// No description provided for @storyApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get storyApply;

  /// No description provided for @storyFontDisplay.
  ///
  /// In en, this message translates to:
  /// **'Condensed'**
  String get storyFontDisplay;

  /// No description provided for @storyFontBody.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get storyFontBody;

  /// No description provided for @storySize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get storySize;

  /// No description provided for @storySpacing.
  ///
  /// In en, this message translates to:
  /// **'Spacing'**
  String get storySpacing;

  /// No description provided for @storyWeightRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get storyWeightRegular;

  /// No description provided for @storyWeightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get storyWeightMedium;

  /// No description provided for @storyWeightBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get storyWeightBold;

  /// No description provided for @storyWeightBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get storyWeightBlack;

  /// No description provided for @storyAlignStart.
  ///
  /// In en, this message translates to:
  /// **'Align start'**
  String get storyAlignStart;

  /// No description provided for @storyAlignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get storyAlignCenter;

  /// No description provided for @storyAlignEnd.
  ///
  /// In en, this message translates to:
  /// **'Align end'**
  String get storyAlignEnd;

  /// No description provided for @storyColorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get storyColorWhite;

  /// No description provided for @storyColorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get storyColorGray;

  /// No description provided for @storyColorAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get storyColorAccent;

  /// No description provided for @storyColorDark.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get storyColorDark;

  /// No description provided for @storyUppercase.
  ///
  /// In en, this message translates to:
  /// **'Capitals'**
  String get storyUppercase;

  /// No description provided for @storyShadow.
  ///
  /// In en, this message translates to:
  /// **'Shadow'**
  String get storyShadow;

  /// No description provided for @storyStatsNone.
  ///
  /// In en, this message translates to:
  /// **'This workout has no statistics to show.'**
  String get storyStatsNone;

  /// No description provided for @storyStatsHint.
  ///
  /// In en, this message translates to:
  /// **'Turn statistics on or off, and drag to reorder them.'**
  String get storyStatsHint;

  /// No description provided for @storyStatsHintPlanned.
  ///
  /// In en, this message translates to:
  /// **'These are the plan\'s numbers, shown under \"The plan\". Turn them on or off, and drag to reorder.'**
  String get storyStatsHintPlanned;

  /// No description provided for @storyEstimate.
  ///
  /// In en, this message translates to:
  /// **'estimate'**
  String get storyEstimate;

  /// No description provided for @storyAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get storyAccent;

  /// No description provided for @storyBranding.
  ///
  /// In en, this message translates to:
  /// **'Show the app name'**
  String get storyBranding;

  /// No description provided for @storyChangeLayout.
  ///
  /// In en, this message translates to:
  /// **'Change layout'**
  String get storyChangeLayout;

  /// No description provided for @storyResetDesign.
  ///
  /// In en, this message translates to:
  /// **'Reset design'**
  String get storyResetDesign;

  /// No description provided for @storyResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the design?'**
  String get storyResetConfirmTitle;

  /// No description provided for @storyResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Text, stats and style go back to the layout as it started. Your photo stays.'**
  String get storyResetConfirmBody;

  /// No description provided for @storyReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get storyReset;

  /// No description provided for @storyLayerStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get storyLayerStats;

  /// No description provided for @storyLayerBrand.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get storyLayerBrand;

  /// No description provided for @storyLayerEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty text'**
  String get storyLayerEmpty;

  /// No description provided for @storyDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get storyDuplicate;

  /// No description provided for @storyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get storyDelete;

  /// No description provided for @storyLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get storyLock;

  /// No description provided for @storyUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get storyUnlock;

  /// No description provided for @storyBringForward.
  ///
  /// In en, this message translates to:
  /// **'Bring forward'**
  String get storyBringForward;

  /// No description provided for @storySendBackward.
  ///
  /// In en, this message translates to:
  /// **'Send backward'**
  String get storySendBackward;

  /// No description provided for @storyHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get storyHide;

  /// No description provided for @storyShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get storyShow;

  /// No description provided for @storyUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get storyUndo;

  /// No description provided for @storyRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get storyRedo;

  /// No description provided for @storyPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get storyPreview;

  /// No description provided for @storyClosePreview.
  ///
  /// In en, this message translates to:
  /// **'Back to editing'**
  String get storyClosePreview;

  /// No description provided for @storyNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get storyNext;

  /// No description provided for @storyDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this story?'**
  String get storyDiscardTitle;

  /// No description provided for @storyDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes will be lost.'**
  String get storyDiscardBody;

  /// No description provided for @storyDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get storyDiscard;

  /// No description provided for @storyKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get storyKeepEditing;

  /// No description provided for @storyExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the image. {error}'**
  String storyExportFailed(String error);

  /// No description provided for @storyExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get storyExportTitle;

  /// No description provided for @storySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get storySave;

  /// No description provided for @storyShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get storyShare;

  /// No description provided for @storyDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get storyDone;

  /// No description provided for @storySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery'**
  String get storySaved;

  /// No description provided for @storySaveDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access in Settings to save your story.'**
  String get storySaveDenied;

  /// No description provided for @storySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the image. {error}'**
  String storySaveFailed(String error);

  /// No description provided for @storyNotEnoughSpace.
  ///
  /// In en, this message translates to:
  /// **'Not enough storage space to save the image.'**
  String get storyNotEnoughSpace;

  /// No description provided for @storyShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the image. {error}'**
  String storyShareFailed(String error);

  /// No description provided for @storyShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing isn\'t available on this device.'**
  String get storyShareUnavailable;

  /// No description provided for @storyPhotoDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access in Settings to choose a photo.'**
  String get storyPhotoDenied;

  /// No description provided for @storyCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in Settings to take a photo.'**
  String get storyCameraDenied;

  /// No description provided for @storyPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this photo. Try another one.'**
  String get storyPhotoFailed;
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
