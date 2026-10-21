// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitness Tracker: Meals & Gym';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String languageSystemSubtitle(String language) {
    return 'Follows your phone ($language)';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get navToday => 'Today';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navFoods => 'Foods';

  @override
  String get navMe => 'Me';

  @override
  String get notifications => 'Notifications';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your account and all data';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get logout => 'Logout';

  @override
  String get errorLabel => 'Error';

  @override
  String get confirmLogoutTitle => 'Confirm Logout';

  @override
  String get confirmLogoutMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get notifMealRemindersTitle => 'Meal reminders';

  @override
  String get notifMealRemindersSubtitle =>
      'A nudge when you have not logged a meal';

  @override
  String get notifWorkoutRemindersTitle => 'Workout reminders';

  @override
  String get notifWorkoutRemindersSubtitle =>
      'A nudge when you have not trained';

  @override
  String get notifAchievementsTitle => 'Achievements';

  @override
  String get notifAchievementsSubtitle => 'When you unlock a badge';

  @override
  String get notifCheckInsTitle => 'Check-ins';

  @override
  String get notifCheckInsSubtitle => 'If you have been away for a while';

  @override
  String get notifStreakSavesTitle => 'Streak saves';

  @override
  String get notifStreakSavesSubtitle =>
      'In the evening, if your streak is about to break';

  @override
  String settingsSaveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get settingsLoadingSettings => 'Loading your settings…';

  @override
  String get settingsLoadSettingsFailed => 'Could not load your settings';

  @override
  String get settingsUnknownError => 'Unknown error';

  @override
  String get settingsQuietHours => 'Quiet hours';

  @override
  String settingsQuietHoursRange(String from, String to) {
    return 'No notifications between $from and $to';
  }

  @override
  String get settingsQuietHoursAnyTime =>
      'Notifications can arrive at any hour';

  @override
  String get settingsQuietHoursFrom => 'From';

  @override
  String get settingsQuietHoursTo => 'To';

  @override
  String get settingsDeleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.';

  @override
  String get settingsDeleteAccountSuccess => 'Account deleted successfully';

  @override
  String settingsDeleteAccountFailed(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginHeading => 'Hello Again!';

  @override
  String get loginSubtitle => 'Login to continue your fitness journey';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Please enter your password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Register';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerHeading => 'Welcome!';

  @override
  String get registerSubtitle => 'Create your account to get started';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameRequired => 'Please enter your full name';

  @override
  String get fullNameTooShort => 'Name must be at least 2 characters';

  @override
  String get registerPasswordRequired => 'Please enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get onboardingFailedSave =>
      'Failed to save profile. Please try again.';

  @override
  String get onboardingStep1Title => 'Your body stats';

  @override
  String get onboardingStep1Subtitle =>
      'We use these to calculate your daily calorie needs';

  @override
  String get onboardingBirthDateLabel => 'Date of birth';

  @override
  String get onboardingBirthDateHint => 'Tap to pick your birthday';

  @override
  String get onboardingWeightLabel => 'Weight (kg)';

  @override
  String get onboardingWeightHint => 'e.g. 70';

  @override
  String get onboardingHeightLabel => 'Height (cm)';

  @override
  String get onboardingHeightHint => 'e.g. 175';

  @override
  String get onboardingInvalidStats =>
      'Please enter valid age, weight, and height';

  @override
  String get onboardingBmiEnterStats => 'Enter your stats';

  @override
  String get onboardingBmiUnderweight => 'Underweight';

  @override
  String get onboardingBmiHealthy => 'Healthy Range';

  @override
  String get onboardingBmiOverweight => 'Overweight';

  @override
  String get onboardingBmiObese => 'Obese';

  @override
  String get onboardingBmiLabel => 'BMI';

  @override
  String get onboardingStep2Title => 'What\'s your gender?';

  @override
  String get onboardingStep2Subtitle =>
      'Affects your metabolic rate calculation';

  @override
  String get onboardingBmrCardTitle => 'Estimated Daily Calories at Rest';

  @override
  String get onboardingBmrCardSubtitle => 'Basal Metabolic Rate';

  @override
  String get onboardingGenderMaleLabel => 'Male';

  @override
  String get onboardingGenderMaleDesc => 'Higher BMR on average';

  @override
  String get onboardingGenderFemaleLabel => 'Female';

  @override
  String get onboardingGenderFemaleDesc => 'Lower BMR on average';

  @override
  String get onboardingStep3Title => 'How active are you?';

  @override
  String get onboardingStep3Subtitle =>
      'Pick what describes a typical week for you';

  @override
  String get onboardingTdeeCardTitle => 'Total Daily Energy Expenditure';

  @override
  String onboardingTdeeMultiplier(String value) {
    return '×$value activity multiplier';
  }

  @override
  String get onboardingActivitySedentary => 'Sedentary';

  @override
  String get onboardingActivitySedentaryDesc =>
      'Desk job, little to no exercise';

  @override
  String get onboardingActivityLight => 'Light';

  @override
  String get onboardingActivityLightDesc => 'Light exercise 1–3 days/week';

  @override
  String get onboardingActivityModerate => 'Moderate';

  @override
  String get onboardingActivityModerateDesc => 'Exercise 3–5 days/week';

  @override
  String get onboardingActivityActive => 'Active';

  @override
  String get onboardingActivityActiveDesc => 'Hard exercise 6–7 days/week';

  @override
  String get onboardingActivityVeryActive => 'Very Active';

  @override
  String get onboardingActivityVeryActiveDesc =>
      'Physical job or 2× daily training';

  @override
  String get onboardingStep4Title => 'What\'s your goal?';

  @override
  String get onboardingStep4Subtitle =>
      'We\'ll adjust your daily target accordingly';

  @override
  String get onboardingTargetCardTitle => 'Your Daily Calorie Target';

  @override
  String onboardingTargetFromTdee(String offset) {
    return '$offset kcal from your TDEE';
  }

  @override
  String get onboardingGoalLoseWeight => 'Lose Weight';

  @override
  String get onboardingGoalLoseWeightDesc => '500 kcal daily deficit';

  @override
  String get onboardingGoalBuildMuscle => 'Build Muscle';

  @override
  String get onboardingGoalBuildMuscleDesc => '+300 kcal daily surplus';

  @override
  String get onboardingGoalStayFit => 'Stay Fit';

  @override
  String get onboardingGoalStayFitDesc => 'Maintain current weight';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingLetsGo => 'Let\'s Go!';

  @override
  String appTextFieldRequired(String field) {
    return 'Please enter $field';
  }

  @override
  String logoutFailed(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get homeNoMealsLogged => 'No meals logged yet';

  @override
  String get homeToday => 'Today';

  @override
  String get homeYesterday => 'Yesterday';

  @override
  String get homeMacroCalories => 'Calories';

  @override
  String get homeMacroProtein => 'Protein';

  @override
  String get homeMacroFat => 'Fat';

  @override
  String get homeMacroCarbs => 'Carbs';

  @override
  String get homeTitle => 'Nutrition Tracker';

  @override
  String get homeDailyMacroGoals => 'Daily Macro Goals';

  @override
  String get homeYourMeals => 'Your Meals';

  @override
  String get profileImagePickFailed =>
      'Failed to select image. Please try again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditTooltip => 'Edit Profile';

  @override
  String get profileFreeMember => 'Free Member';

  @override
  String get profileAge => 'Age';

  @override
  String get profileBirthDate => 'Birthday';

  @override
  String profileYearsValue(String value) {
    return '$value years';
  }

  @override
  String get profileWeight => 'Weight';

  @override
  String profileKgValue(String value) {
    return '$value kg';
  }

  @override
  String get profileHeight => 'Height';

  @override
  String profileCmValue(String value) {
    return '$value cm';
  }

  @override
  String get profileActivityLevel => 'Activity Level';

  @override
  String get profileFitnessGoal => 'Fitness Goal';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileProgress => 'Progress';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileHelp => 'Help';

  @override
  String profileAppVersion(String version) {
    return 'App version: $version';
  }

  @override
  String profileErrorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpContactSupport => 'Contact Support';

  @override
  String get helpContactSupportSubtitle => 'Get help from our team';

  @override
  String get helpFaqs => 'FAQs';

  @override
  String get helpFaqsSubtitle => 'Frequently asked questions';

  @override
  String get helpVideoTutorials => 'Video Tutorials';

  @override
  String get helpVideoTutorialsSubtitle => 'Learn how to use the app';

  @override
  String get achievementUnlocked => 'UNLOCKED';

  @override
  String get achievementLocked => 'LOCKED';

  @override
  String get achievementDescriptionLabel => 'DESCRIPTION';

  @override
  String get achievementRequirementsLabel => 'REQUIREMENTS';

  @override
  String get achievementTargetLabel => 'Target';

  @override
  String get achievementCompletionDetailsLabel => 'COMPLETION DETAILS';

  @override
  String get achievementCompletedOnLabel => 'Completed On';

  @override
  String achievementLoadError(String error) {
    return 'Error loading achievements: $error';
  }

  @override
  String get achievementNoneFound => 'No achievements found';

  @override
  String achievementCompleteToUnlock(String description) {
    return 'Complete to unlock: $description';
  }

  @override
  String get achievementCompletedBadge => 'COMPLETED';

  @override
  String get foodsNoBarcodeScanned => 'No barcode scanned.';

  @override
  String foodsNotFoundForBarcode(String barcode) {
    return 'Food not found for barcode: $barcode';
  }

  @override
  String foodsScanError(String error) {
    return 'Error scanning barcode: $error';
  }

  @override
  String get foodsSortByTitle => 'Sort Foods By';

  @override
  String get sortDefault => 'Default';

  @override
  String get foodsTitle => 'Foods';

  @override
  String get foodsSortTooltip => 'Sort foods';

  @override
  String foodsSortingBy(String sortTitle) {
    return 'Sorting by: $sortTitle';
  }

  @override
  String foodsCaloriesInline(String value) {
    return 'Calories: $value';
  }

  @override
  String foodsCaloriesKcal(String value) {
    return 'Calories: $value kcal';
  }

  @override
  String foodsProteinGrams(String value) {
    return 'Protein: ${value}g';
  }

  @override
  String foodsCarbsGrams(String value) {
    return 'Carbs: ${value}g';
  }

  @override
  String foodsFatGrams(String value) {
    return 'Fat: ${value}g';
  }

  @override
  String foodsProteinShort(String value) {
    return 'P: ${value}g';
  }

  @override
  String foodsCarbsShort(String value) {
    return 'C: ${value}g';
  }

  @override
  String foodsFatShort(String value) {
    return 'F: ${value}g';
  }

  @override
  String get foodsNoFoodsFound => 'No foods found.';

  @override
  String get foodsSearchHint => 'Search Foods...';

  @override
  String get foodScanTitle => 'Scan Food Barcode';

  @override
  String get foodScanButton => 'Scan Barcode';

  @override
  String foodScanCalories(String value) {
    return 'Calories: $value kcal';
  }

  @override
  String foodScanProtein(String value) {
    return 'Protein: $value g';
  }

  @override
  String foodScanCarbs(String value) {
    return 'Carbs: $value g';
  }

  @override
  String foodScanFats(String value) {
    return 'Fats: $value g';
  }

  @override
  String get foodScanAddToMeal => 'Add to Meal';

  @override
  String get foodDetailsEnterQuantity => 'Please enter a quantity';

  @override
  String get foodDetailsEnterMealTime => 'Please enter a meal time';

  @override
  String get foodDetailsSelectMealTime => 'Please select a meal time';

  @override
  String get foodDetailsEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String get foodDetailsMealStoredSuccess => 'Meal stored successfully!';

  @override
  String foodDetailsErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get foodDetailsRemovedFromFavorites => 'Removed from favorites';

  @override
  String get foodDetailsAddedToFavorites => 'Added to favorites';

  @override
  String foodDetailsErrorUpdatingFavorites(String error) {
    return 'Error updating favorites: $error';
  }

  @override
  String get foodDetailsRemoveFromFavoritesTooltip => 'Remove from favorites';

  @override
  String get foodDetailsAddToFavoritesTooltip => 'Add to favorites';

  @override
  String get foodDetailsNutritionFacts => 'Nutrition Facts';

  @override
  String get foodDetailsFatsLabel => 'Fats';

  @override
  String get foodDetailsAddToMealPlan => 'Add to Meal Plan';

  @override
  String get foodDetailsSelectMealTimeHint => 'Select Meal Time';

  @override
  String get foodDetailsCustomMealTimeHint => 'Enter Custom Meal Time';

  @override
  String get foodDetailsCustomMealTimeExamples =>
      'Examples: Mid-morning, Late-night, Second Breakfast, etc.';

  @override
  String get foodDetailsQuantityHint => 'Quantity (grams)';

  @override
  String mealDetailTitle(String mealTime) {
    return '$mealTime Details';
  }

  @override
  String get mealDetailNoFoods => 'No foods in this meal';

  @override
  String get mealDetailRemoveFoodTitle => 'Remove Food';

  @override
  String mealDetailRemoveFoodConfirm(String name) {
    return 'Are you sure you want to remove $name from this meal?';
  }

  @override
  String get mealDetailRemoveAction => 'Remove';

  @override
  String get mealDetailQuantityLabel => 'Quantity';

  @override
  String get newFoodAddFailed => 'Failed to add food. Please try again.';

  @override
  String get newFoodInvalidNumber => 'Please enter a valid number';

  @override
  String get newFoodTitle => 'Add New Food';

  @override
  String get newFoodNameLabel => 'Food Name';

  @override
  String get newFoodNameHint => 'Enter food name';

  @override
  String get newFoodNameRequired => 'Please enter food name';

  @override
  String get newFoodCarbohydrates => 'Carbohydrates';

  @override
  String get newFoodAddButton => 'Add Food';

  @override
  String get updateProfileSuccessDefault => 'Profile updated successfully.';

  @override
  String get updateProfileFailed => 'Profile update failed. Please try again.';

  @override
  String get updateProfileAgeRequired => 'Please enter age';

  @override
  String get updateProfileAgeInvalid => 'Please enter a valid age';

  @override
  String get updateProfileWeightRequired => 'Please enter weight';

  @override
  String get updateProfileWeightInvalid => 'Please enter a valid weight';

  @override
  String get updateProfileHeightRequired => 'Please enter height';

  @override
  String get updateProfileHeightInvalid => 'Please enter a valid height';

  @override
  String get updateProfileGenderRequired => 'Please select a gender';

  @override
  String get updateProfileActivityRequired => 'Please select an activity level';

  @override
  String get updateProfileGoalRequired => 'Please select a fitness goal';

  @override
  String get updateProfileTitle => 'Update Profile';

  @override
  String get progressFillAllFields => 'Please fill in all fields';

  @override
  String get progressInvalidWeight => 'Invalid weight value';

  @override
  String get progressAddedSuccess => 'Progress added successfully!';

  @override
  String progressAddError(String error) {
    return 'Error adding progress: $error';
  }

  @override
  String get progressNoDataAvailable => 'No progress data available';

  @override
  String progressTooltip(String date, String weight) {
    return 'Date: $date\nWeight: $weight kg';
  }

  @override
  String get progressTitle => 'Progress Tracker';

  @override
  String get progressAddEntryTitle => 'Add Progress Entry';

  @override
  String get progressDateLabel => 'Date';

  @override
  String get progressAddYourProgress => 'Add Your Progress';

  @override
  String get progressChartTitle => 'Progress Chart';

  @override
  String get workoutModeSimple => 'Simple';

  @override
  String get workoutModeAdvanced => 'Advanced';

  @override
  String get workoutTitle => 'Workouts';

  @override
  String get workoutDifficultyEasy => 'Easy';

  @override
  String get workoutDifficultyMedium => 'Medium';

  @override
  String get workoutDifficultyHard => 'Hard';

  @override
  String get workoutSearchExercisesHint => 'Search Exercises...';

  @override
  String get workoutLoading => 'Loading workouts...';

  @override
  String workoutFoundCount(int count) {
    return 'Found $count workouts';
  }

  @override
  String get workoutAllCategories => 'All Categories';

  @override
  String get workoutLoadError => 'Error loading workouts';

  @override
  String get workoutTryAgain => 'Try Again';

  @override
  String get workoutNoneAvailable => 'No workouts available';

  @override
  String get workoutNoneMatchSearch => 'No workouts match your search';

  @override
  String get workoutClearFilters => 'Clear filters';

  @override
  String get workoutNoDescription => 'No Description';

  @override
  String get workoutCategoryOther => 'Other';

  @override
  String get workoutDetailsUnknownWorkout => 'Unknown Workout';

  @override
  String get workoutDetailsEnterDuration => 'Please enter a duration';

  @override
  String get workoutDetailsEnterValidDuration =>
      'Please enter a valid duration';

  @override
  String get workoutDetailsAddedSuccess => 'Workout added successfully!';

  @override
  String get workoutDetailsNoName => 'No Name';

  @override
  String get workoutDetailsUncategorized => 'Uncategorized';

  @override
  String get workoutDetailsAboutTitle => 'About This Workout';

  @override
  String get workoutDetailsIntensity => 'Intensity';

  @override
  String workoutDetailsCaloriesPerHour(String value) {
    return '$value/hr';
  }

  @override
  String get workoutDetailsScheduleTitle => 'Schedule Workout';

  @override
  String get workoutDetailsDurationHint => 'Duration in minutes';

  @override
  String get workoutDetailsAddToPlan => 'Add to My Plan';

  @override
  String workoutListLoadFailed(String error) {
    return 'Failed to load workouts: $error';
  }

  @override
  String workoutListImportFailed(String error) {
    return 'Failed to import workout program: $error';
  }

  @override
  String workoutListSingleImportedSuccess(String name) {
    return 'Workout \"$name\" imported successfully';
  }

  @override
  String get workoutListCycleImportedSuccess =>
      'Workout cycle imported successfully';

  @override
  String get workoutListDeletedSuccess => 'Workout deleted successfully';

  @override
  String workoutListDeleteFailed(String error) {
    return 'Failed to delete workout: $error';
  }

  @override
  String get workoutListTitle => 'Workout Management';

  @override
  String get workoutListImportTooltip => 'Import workout program';

  @override
  String get workoutListRefreshTooltip => 'Refresh workouts';

  @override
  String get workoutListUnnamedWorkout => 'Unnamed Workout';

  @override
  String get workoutListNoDescription => 'No description';

  @override
  String get workoutListDeleteTooltip => 'Delete workout';

  @override
  String get workoutListNoWorkoutsYet => 'No Workouts Yet';

  @override
  String get workoutListCreateFirstWorkout =>
      'Create your first workout to get started';

  @override
  String get workoutListCreateNewWorkout => 'Create New Workout';

  @override
  String get workoutListErrorLoading => 'Error Loading Workouts';

  @override
  String get workoutListUnknownError => 'An unknown error occurred';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get workoutCalendarNoExportPlan => 'No workout plan to export';

  @override
  String get workoutCalendarExportedSuccess =>
      'Workout cycle exported successfully';

  @override
  String workoutCalendarExportFailed(String error) {
    return 'Failed to export workout cycle: $error';
  }

  @override
  String get workoutCalendarImportedCycleDefaultName => 'Imported Cycle';

  @override
  String get workoutCalendarTitle => 'My Workouts';

  @override
  String get workoutCalendarOptionsTooltip => 'Workout program options';

  @override
  String get workoutCalendarSavedCycles => 'Saved workout cycles';

  @override
  String get workoutCalendarExportCycle => 'Export workout cycle';

  @override
  String get workoutCalendarNoPlanAvailable => 'No workout plan available';

  @override
  String workoutCalendarNoPlanForWeek(int week) {
    return 'No workout plan for week $week';
  }

  @override
  String workoutCalendarWeekLabel(int week) {
    return 'Week $week';
  }

  @override
  String workoutCalendarNoWorkoutsForDay(String day) {
    return 'No workouts for $day';
  }

  @override
  String get workoutCalendarAddWorkoutButton => 'Add Workout';

  @override
  String workoutCalendarWorkoutsForDay(String day) {
    return 'Workouts for $day';
  }

  @override
  String get workoutCalendarAddMoreTooltip => 'Add more workouts';

  @override
  String get workoutCalendarSearchWorkoutsHint => 'Search workouts...';

  @override
  String get workoutCalendarAvailableWorkouts => 'Available Workouts';

  @override
  String get workoutCalendarNoMatchingWorkouts => 'No matching workouts found';

  @override
  String get workoutCalendarCreateFirstWorkout => 'Create your first workout';

  @override
  String workoutCalendarAddFailed(String error) {
    return 'Failed to add workout: $error';
  }

  @override
  String get workoutCalendarDetailsButton => 'Details';

  @override
  String get workoutCalendarRemoveExerciseTooltip => 'Remove exercise';

  @override
  String get workoutCalendarMalformedEntry =>
      'This workout entry couldn\'t be loaded.';

  @override
  String get workoutCalendarRemoveEntryTooltip => 'Remove entry';

  @override
  String get workoutCalendarPreviousWeek => 'Previous Week';

  @override
  String get workoutCalendarNextWeek => 'Next Week';

  @override
  String get workoutCalendarCreateWorkoutPlan => 'Create Workout Plan';

  @override
  String get workoutCalendarReuseSavedCycle => 'Reuse a Saved Cycle';

  @override
  String get importDialogWorkoutsToCreate =>
      'The following workouts will be created:';

  @override
  String get importDialogUnmatchedExercises =>
      'These exercises weren\'t found and will be skipped:';

  @override
  String get importDialogImportButton => 'Import';

  @override
  String newWorkoutLoadExercisesFailed(String error) {
    return 'Failed to load exercises: $error';
  }

  @override
  String get newWorkoutNeedExercise =>
      'Please add at least one exercise to your workout';

  @override
  String get newWorkoutTitle => 'Create New Workout';

  @override
  String get newWorkoutRefreshExercisesTooltip => 'Refresh exercise list';

  @override
  String get newWorkoutDetailsTitle => 'Workout Details';

  @override
  String get newWorkoutNameLabel => 'Workout Name';

  @override
  String get newWorkoutNameHint => 'e.g., Upper Body Strength';

  @override
  String get newWorkoutNameRequired => 'Please enter a workout name';

  @override
  String get newWorkoutDescriptionLabel => 'Description';

  @override
  String get newWorkoutDescriptionHint =>
      'Focus of this workout, target muscle groups, etc.';

  @override
  String get newWorkoutDescriptionRequired => 'Please enter a description';

  @override
  String get newWorkoutExercisesTitle => 'Exercises';

  @override
  String get newWorkoutAddExercise => 'Add Exercise';

  @override
  String get newWorkoutExercisesSubtitle =>
      'Add exercises and configure sets, reps, and rest periods';

  @override
  String get newWorkoutNoExercisesYet => 'No exercises added yet';

  @override
  String get newWorkoutAddExercisesPrompt =>
      'Add exercises to create your custom workout';

  @override
  String get newWorkoutSetsLabel => 'Sets';

  @override
  String get newWorkoutRepsLabel => 'Reps';

  @override
  String get newWorkoutRestLabel => 'Rest (sec)';

  @override
  String get newWorkoutSelectExercisesTitle => 'Select Exercises';

  @override
  String get newWorkoutSearchExercisesHint => 'Search exercises...';

  @override
  String get newWorkoutNoExercisesFound => 'No exercises found';

  @override
  String get newWorkoutSaveButton => 'Save Workout';

  @override
  String get newWorkoutSaving => 'Saving your workout...';

  @override
  String get newWorkoutErrorCreating => 'Error Creating Workout';

  @override
  String get workoutDetailScreenExportedSuccess =>
      'Workout exported successfully';

  @override
  String workoutDetailScreenExportFailed(String error) {
    return 'Failed to export workout: $error';
  }

  @override
  String get workoutDetailScreenTitle => 'Workout Details';

  @override
  String workoutDetailScreenErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get workoutDetailScreenNoDetails => 'No workout details available';

  @override
  String get workoutDetailScreenRefresh => 'Refresh';

  @override
  String get workoutDetailScreenExportTooltip => 'Export workout';

  @override
  String get workoutDetailScreenNoDescription => 'No description available';

  @override
  String workoutDetailScreenExercisesCount(int count) {
    return '$count Exercises';
  }

  @override
  String workoutDetailScreenMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String workoutDetailScreenSetsCount(int count) {
    return '$count sets';
  }

  @override
  String workoutDetailScreenRepsCount(int count) {
    return '$count reps';
  }

  @override
  String workoutDetailScreenRestSeconds(int seconds) {
    return '${seconds}s rest';
  }

  @override
  String get workoutDetailScreenDescriptionLabel => 'Description:';

  @override
  String workoutDetailScreenEquipmentLabel(String value) {
    return 'Equipment: $value';
  }

  @override
  String workoutDetailScreenLevelLabel(String value) {
    return 'Level: $value';
  }

  @override
  String get exerciseSelectionPleaseSelect => 'Please select an exercise';

  @override
  String get exerciseSelectionInvalidValues =>
      'Please enter valid values for sets, reps, and rest';

  @override
  String get exerciseSelectionInvalidDuration =>
      'Please enter a valid duration or leave it empty';

  @override
  String get exerciseSelectionTitle => 'Select Exercise';

  @override
  String get exerciseSelectionFilterByBodyPart => 'Filter by Body Part:';

  @override
  String get exerciseSelectionDurationLabel => 'Duration (sec)';

  @override
  String get exerciseSelectionOptionalHint => 'Optional';

  @override
  String get exerciseSelectionAddToWorkout => 'Add to Workout';

  @override
  String get editWorkoutTitle => 'Edit Workout';

  @override
  String get editWorkoutAddExercisesPrompt =>
      'Add exercises to update your custom workout';

  @override
  String get editWorkoutUpdateButton => 'Update Workout';

  @override
  String get editWorkoutUpdating => 'Updating your workout...';

  @override
  String get editWorkoutErrorUpdating => 'Error Updating Workout';

  @override
  String savedCyclesScheduled(String name) {
    return '\"$name\" scheduled';
  }

  @override
  String get savedCyclesDefaultName => 'Cycle';

  @override
  String savedCyclesReuseFailed(String error) {
    return 'Failed to reuse cycle: $error';
  }

  @override
  String get savedCyclesDeleteTitle => 'Delete Saved Cycle';

  @override
  String savedCyclesDeleteConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get savedCyclesThisCycle => 'this cycle';

  @override
  String savedCyclesDeleteFailed(String error) {
    return 'Failed to delete cycle: $error';
  }

  @override
  String savedCyclesAutoSetupFailed(String error) {
    return 'Could not set up workouts automatically ($error). Pick a workout for each highlighted day instead.';
  }

  @override
  String get savedCyclesSuggestedTitle => 'Suggested Cycles';

  @override
  String get savedCyclesSuggestedSubtitle =>
      'Quick-start templates — pick one and we\'ll set up real workouts for each training day.';

  @override
  String savedCyclesWeeksDaysPerWeek(int weeks, int days) {
    return '$weeks weeks · $days days/week';
  }

  @override
  String get savedCyclesSettingUp => 'Setting up workouts…';

  @override
  String get savedCyclesTitle => 'Saved Workout Cycles';

  @override
  String savedCyclesLoadFailed(String error) {
    return 'Failed to load saved cycles: $error';
  }

  @override
  String get savedCyclesYourCycles => 'Your Saved Cycles';

  @override
  String get savedCyclesNoneYet => 'No saved workout cycles yet';

  @override
  String get savedCyclesAutoSavedHint =>
      'Every cycle you create is automatically saved here so you can reuse it later.';

  @override
  String get savedCyclesUnnamedCycle => 'Unnamed Cycle';

  @override
  String savedCyclesWeeksAndDaysSummary(int weeks, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '$weeks week',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days workout days',
      one: '$days workout day',
    );
    return '$_temp0 · $_temp1/week';
  }

  @override
  String get savedCyclesReuseButton => 'Reuse';

  @override
  String newWorkoutCycleLoadFailed(String error) {
    return 'Failed to load workouts: $error';
  }

  @override
  String get newWorkoutCycleTitle => 'New Workout Cycle';

  @override
  String get newWorkoutCycleRefreshTooltip => 'Refresh';

  @override
  String get newWorkoutCycleNameLabel => 'Cycle Name';

  @override
  String get newWorkoutCycleNameHint => 'e.g. Summer Strength Program';

  @override
  String get newWorkoutCycleNameSubtitle =>
      'Give your cycle a name you\'ll recognize';

  @override
  String get newWorkoutCycleDescriptionLabel => 'Description';

  @override
  String get newWorkoutCycleDescriptionHint => 'What is this cycle about?';

  @override
  String get newWorkoutCycleStartDateLabel => 'Start Date';

  @override
  String get newWorkoutCycleStartDateSubtitle =>
      'When should this cycle begin?';

  @override
  String get newWorkoutCycleWeeksLabel => 'Duration (weeks)';

  @override
  String newWorkoutCycleRepeatsFor(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Repeats for $weeks weeks',
      one: 'Repeats for 1 week',
    );
    return '$_temp0';
  }

  @override
  String get newWorkoutCycleScheduleTitle => 'Weekly Schedule';

  @override
  String get newWorkoutCycleScheduleSubtitle => 'Assign a workout to each day';

  @override
  String newWorkoutCycleRecommendedPending(int total, int pending) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$pending of $total recommended days still need a workout',
      one: '$pending of $total recommended day still needs a workout',
    );
    return '$_temp0';
  }

  @override
  String get newWorkoutCycleRecommendedComplete =>
      'All recommended days have a workout assigned';

  @override
  String get newWorkoutCycleLoadingWorkouts => 'Loading your workouts…';

  @override
  String get newWorkoutCycleNoWorkoutsFound => 'No Workouts Found';

  @override
  String get newWorkoutCycleCreateWorkoutsFirst =>
      'Create a custom workout first so you can assign it to a day';

  @override
  String get newWorkoutCycleCreateWorkoutButton => 'Create Workout';

  @override
  String get newWorkoutCycleDeleteWorkoutTitle => 'Delete Workout';

  @override
  String newWorkoutCycleDeleteWorkoutConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This cannot be undone.';
  }

  @override
  String newWorkoutCycleDeleteWorkoutFailed(String error) {
    return 'Failed to delete workout: $error';
  }

  @override
  String get newWorkoutCycleSearchWorkoutsHint => 'Search workouts…';

  @override
  String get newWorkoutCycleRestDay => 'Rest Day';

  @override
  String get newWorkoutCycleNoCustomWorkoutsYet =>
      'You haven\'t created any custom workouts yet';

  @override
  String newWorkoutCycleNoWorkoutsMatch(String query) {
    return 'No workouts match \"$query\"';
  }

  @override
  String get workoutCalendarExportedPlan => 'Workout plan exported';

  @override
  String workoutCalendarExportPlanFailed(String error) {
    return 'Couldn\'t export your plan. $error';
  }

  @override
  String workoutCalendarImportPlanFailed(String error) {
    return 'Couldn\'t import that plan. $error';
  }

  @override
  String get workoutCalendarImportFileHint =>
      'Check that the file is a workout plan exported from this app.';

  @override
  String get workoutCalendarImportedPlan => 'Workout plan imported';

  @override
  String workoutCalendarLoadWorkoutsFailed(String error) {
    return 'Couldn\'t load your workouts. $error';
  }

  @override
  String get workoutCalendarSimpleModeSemantics =>
      'Simple mode: log activities you did';

  @override
  String get workoutCalendarAdvancedModeSemantics =>
      'Advanced mode: weekly gym plans';

  @override
  String get workoutCalendarReadyMadePlans => 'Ready-made and saved plans';

  @override
  String get workoutCalendarExportMyPlan => 'Export my plan';

  @override
  String get workoutCalendarImportPlan => 'Import a plan';

  @override
  String workoutCalendarLoadPlanFailed(String error) {
    return 'Couldn\'t load your plan. $error';
  }

  @override
  String get workoutCalendarNoPlanYet => 'You don\'t have a workout plan yet';

  @override
  String get workoutCalendarNothingPlannedThisWeek =>
      'Nothing planned for this week';

  @override
  String get workoutCalendarThisWeek => 'This week';

  @override
  String get workoutCalendarNextWeekRelative => 'Next week';

  @override
  String get workoutCalendarLastWeek => 'Last week';

  @override
  String get workoutCalendarAddToDayTooltip => 'Add to this day';

  @override
  String workoutCalendarAddWorkoutFailed(String error) {
    return 'Couldn\'t add this workout. $error';
  }

  @override
  String workoutCalendarPlanStartsWeekOf(String date) {
    return 'Your plan starts the week of $date.';
  }

  @override
  String get workoutCalendarShowThatWeek => 'Show that week';

  @override
  String get workoutCalendarNewToWorkingOut => 'New to working out?';

  @override
  String get workoutCalendarReadyMadePitch =>
      'Start with a ready-made plan. Full Body is 3 days a week and we fill in the exercises for you.';

  @override
  String get workoutCalendarChooseReadyMadePlan => 'Choose a ready-made plan';

  @override
  String get workoutCalendarBuildOwnPlan => 'Build my own plan';

  @override
  String workoutDetailScreenExportWorkoutFailed(String error) {
    return 'Couldn\'t export this workout. $error';
  }

  @override
  String workoutDetailScreenLoadFailed(String error) {
    return 'Couldn\'t load this workout. $error';
  }

  @override
  String get workoutDetailScreenEditTooltip => 'Edit workout';

  @override
  String workoutDetailScreenDurationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get workoutDetailsIntensityLight => 'Light';

  @override
  String get workoutDetailsIntensityModerate => 'Moderate';

  @override
  String get workoutDetailsIntensityVigorous => 'Vigorous';

  @override
  String get workoutDetailsEnterMinutes =>
      'Please enter how many minutes you exercised';

  @override
  String workoutDetailsLoggedSuccess(int minutes) {
    return 'Nice work! Logged $minutes min. You\'ll see it on the Today tab.';
  }

  @override
  String workoutDetailsLogFailed(String error) {
    return 'Error: couldn\'t log this activity. $error';
  }

  @override
  String get workoutDetailsAboutActivity => 'About this activity';

  @override
  String get workoutDetailsBurnsAbout => 'Burns about';

  @override
  String workoutDetailsKcalPerHour(String kcal) {
    return '$kcal kcal/hour';
  }

  @override
  String get workoutDetailsLogActivity => 'Log this activity';

  @override
  String get workoutDetailsWhenTapToChange => 'When (tap to change)';

  @override
  String get workoutDetailsHowManyMinutes => 'How many minutes?';

  @override
  String workoutDetailsAboutKcalBurned(int kcal) {
    return 'About $kcal kcal burned';
  }

  @override
  String get workoutDetailsIDidThis => 'I did this';

  @override
  String get exerciseSelectionAllBodyParts => 'All';

  @override
  String get savedCyclesSuggestedFullBodyName => 'Full Body';

  @override
  String get savedCyclesSuggestedFullBodyDescription =>
      'Whole body, 3 days a week with rest days in between. The best place to start.';

  @override
  String get savedCyclesSuggestedUpperLowerName => 'Upper / Lower';

  @override
  String get savedCyclesSuggestedUpperLowerDescription =>
      'Upper body one day, legs the next. Try it once 3 days feels easy.';

  @override
  String get savedCyclesSuggestedPushPullLegsName => 'Push Pull Legs';

  @override
  String get savedCyclesSuggestedPushPullLegsDescription =>
      'Different muscles each day. For people who already train often.';

  @override
  String savedCyclesStartPlanFailed(String error) {
    return 'Couldn\'t start this plan. $error';
  }

  @override
  String get savedCyclesDeletePlanTitle => 'Delete saved plan';

  @override
  String get savedCyclesThisPlan => 'this plan';

  @override
  String savedCyclesDeletePlanFailed(String error) {
    return 'Couldn\'t delete this plan. $error';
  }

  @override
  String get savedCyclesReadyMadeTitle => 'Ready-made plans';

  @override
  String get savedCyclesReadyMadeSubtitle =>
      'Pick one and we\'ll fill in the exercises for each training day. Not sure? Start with Full Body.';

  @override
  String get savedCyclesBeginnerBadge => 'Beginner';

  @override
  String savedCyclesDaysAWeekWeeks(int days, int weeks) {
    return '$days days a week · $weeks weeks';
  }

  @override
  String get savedCyclesPlansTitle => 'Workout plans';

  @override
  String savedCyclesLoadPlansFailed(String error) {
    return 'Couldn\'t load your plans. $error';
  }

  @override
  String get savedCyclesYourPlans => 'Your saved plans';

  @override
  String get savedCyclesNoPlansYet => 'No saved plans yet';

  @override
  String get savedCyclesPlansAutoSavedHint =>
      'Every plan you create is saved here so you can reuse it later.';

  @override
  String get savedCyclesUnnamedPlan => 'Unnamed plan';

  @override
  String get newWorkoutCycleRefreshWorkoutListTooltip => 'Refresh workout list';

  @override
  String get newWorkoutCyclePlanNameLabel => 'Plan Name';

  @override
  String get newWorkoutCyclePlanNameHint => 'e.g. Push Pull Legs';

  @override
  String get newWorkoutCyclePlanNameSubtitle =>
      'Give it a name so you can save and reuse this plan later';

  @override
  String get newWorkoutCycleDescriptionOptionalLabel =>
      'Description (optional)';

  @override
  String get newWorkoutCycleDescriptionExampleHint =>
      'e.g. 3 days a week to get stronger';

  @override
  String get newWorkoutCyclePlanStartHint =>
      'Your plan will start on this date';

  @override
  String get newWorkoutCycleNumberOfWeeksLabel => 'Number of Weeks';

  @override
  String newWorkoutCyclePlanRepeatsFor(int weeks) {
    return 'Your plan will repeat every week for $weeks weeks';
  }

  @override
  String get newWorkoutCycleWorkoutScheduleTitle => 'Workout Schedule';

  @override
  String get newWorkoutCycleWorkoutScheduleSubtitle =>
      'Choose workouts for each day of the week';

  @override
  String newWorkoutCycleTemplateSuggestsDays(int total, int pending) {
    return 'This template suggests $total training day(s), marked below. Pick a workout for the $pending day(s) still highlighted in orange — everything else stays a rest day unless you change it.';
  }

  @override
  String get newWorkoutCycleAllSuggestedDaysAssigned =>
      'All suggested training days have a workout assigned.';

  @override
  String get newWorkoutCycleLoadingCustomWorkouts =>
      'Loading your custom workouts...';

  @override
  String get newWorkoutCycleNoCustomWorkoutsFound => 'No custom workouts found';

  @override
  String get newWorkoutCycleCreateWorkoutFirstHint =>
      'Create a workout first, then add it to your plan';

  @override
  String newWorkoutCycleDeleteWorkoutRestDayConfirm(String name) {
    return 'Delete \"$name\"? Any day using it will become a rest day.';
  }

  @override
  String newWorkoutCycleDeleteThisWorkoutFailed(String error) {
    return 'Couldn\'t delete this workout. $error';
  }

  @override
  String get newWorkoutCycleNoCustomWorkoutsYetShort =>
      'No custom workouts yet';

  @override
  String get newWorkoutCycleRecommendedTrainingDay =>
      'Recommended training day';

  @override
  String get newWorkoutCycleChooseWorkout => 'Choose a workout';

  @override
  String get newWorkoutCycleAddNewWorkout => 'Add New Workout';

  @override
  String get newWorkoutCycleCreatePlanButton => 'Create Plan';

  @override
  String get newWorkoutCycleCreatingPlan => 'Creating your workout plan...';

  @override
  String get newWorkoutCycleCreatePlanFailedTitle =>
      'Couldn\'t create your plan';

  @override
  String newWorkoutCycleLoadWorkoutsFailed(String error) {
    return 'Couldn\'t load your workouts. $error';
  }

  @override
  String get loginCouldNotLogIn => 'Couldn\'t log you in. Please try again.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginLogIn => 'Log in';

  @override
  String get loginCreateOne => 'Create one';

  @override
  String get registerCouldNotCreate =>
      'Couldn\'t create your account. Please try again.';

  @override
  String get registerPrivacyAgreement =>
      'By creating an account you agree to our Privacy Policy';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordIntro =>
      'Enter your account\'s email and we\'ll send you a code to reset your password.';

  @override
  String forgotPasswordCodeSentIntro(String email) {
    return 'If $email has an account, we sent it a 6-digit code. Enter it below with your new password.';
  }

  @override
  String get forgotPasswordCodeLabel => 'Code';

  @override
  String get forgotPasswordCodeInvalid =>
      'Enter the 6-digit code from the email';

  @override
  String get forgotPasswordNewPasswordLabel => 'New Password';

  @override
  String get forgotPasswordConfirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get forgotPasswordChangeButton => 'Change password';

  @override
  String get forgotPasswordSendCode => 'Send code';

  @override
  String get forgotPasswordResend => 'Didn\'t get it? Send a new code';

  @override
  String get forgotPasswordSendFailed =>
      'Couldn\'t send the code. Please try again.';

  @override
  String get forgotPasswordChangeFailed =>
      'Couldn\'t change your password. Please try again.';

  @override
  String get forgotPasswordChanged => 'Password changed. You can log in now.';

  @override
  String get helpCommonQuestions => 'Common questions';

  @override
  String get helpFaqLogFoodQ => 'How do I log what I ate?';

  @override
  String get helpFaqLogFoodA =>
      'On the Today tab, tap \"Add\" next to the meal (Breakfast, Lunch, Dinner or Snacks). Search for the food, enter how many grams you ate and tap \"Add\". You can also scan a barcode on the Foods tab.';

  @override
  String get helpFaqNoScaleQ => 'I don\'t weigh my food. What should I enter?';

  @override
  String get helpFaqNoScaleA =>
      'A rough guess is fine. A slice of bread is about 30 g, an apple about 150 g, a cup of cooked rice about 160 g and a chicken breast about 170 g. Use the quick buttons (50, 100, 150, 200 g) as a starting point.';

  @override
  String get helpFaqKcalLeftQ => 'What does \"kcal left\" mean?';

  @override
  String get helpFaqKcalLeftA =>
      'It is how many more calories you can eat today and still stay on track for your goal. If you go over, the number turns red. One day over is fine; what matters is most days.';

  @override
  String get helpFaqMacrosQ => 'What are protein, carbs and fat?';

  @override
  String get helpFaqMacrosA =>
      'They are the three nutrients that give food its calories. Protein helps build and repair muscle, carbs are your main energy source, and fat supports your body in many ways. Focus on calories first, then on getting enough protein.';

  @override
  String get helpFaqCalorieGoalQ => 'How is my daily calorie goal worked out?';

  @override
  String get helpFaqCalorieGoalA =>
      'From your age, weight, height, gender and how active you are, we estimate how many calories you burn on a normal day. Then we take away 500 to lose weight, add 300 to build muscle, or keep it the same. Exercise you log is added on top for that day.';

  @override
  String get helpFaqLogExerciseQ => 'How do I log exercise?';

  @override
  String get helpFaqLogExerciseA =>
      'Go to the Workouts tab. In Simple mode, find the activity (walking, cycling, …), tap it, choose how many minutes and tap \"I did this\".';

  @override
  String get helpFaqAdvancedModeQ => 'What is Advanced mode?';

  @override
  String get helpFaqAdvancedModeA =>
      'Advanced mode is for planning gym workouts week by week. If you are new, choose a ready-made plan: Full Body is 3 days a week and we fill in the exercises for you.';

  @override
  String get helpFaqChangeGoalQ => 'How do I change my weight or goal?';

  @override
  String get helpFaqChangeGoalA =>
      'Go to the Me tab and tap the edit button at the top. To track your weight over time, use \"Weight log\" on the same tab.';

  @override
  String get helpDisclaimer =>
      'Calorie goals, calories burned and BMI in this app are estimates to guide you, not medical advice. If you have a health condition, are pregnant, or plan a big change in diet or exercise, check with a doctor first.';

  @override
  String get helpEmailUs => 'Still stuck? Email us';

  @override
  String helpNoEmailApp(String email) {
    return 'No email app found. You can write to $email.';
  }

  @override
  String get appTextFieldHidePassword => 'Hide password';

  @override
  String get appTextFieldShowPassword => 'Show password';

  @override
  String get adaptiveDone => 'Done';

  @override
  String privacyPolicyOpenFailed(String url) {
    return 'Couldn\'t open the privacy policy. It\'s at $url';
  }

  @override
  String onboardingSaveFailed(String error) {
    return 'Couldn\'t save your details. $error';
  }

  @override
  String get onboardingBodyStatsSubtitle =>
      'We only use these to work out how much you should eat each day. You can change them any time.';

  @override
  String get onboardingUnitsMetric => 'kg / cm';

  @override
  String get onboardingUnitsImperial => 'lb / ft';

  @override
  String get onboardingWeightLbLabel => 'Weight (lb)';

  @override
  String get onboardingWeightLbHint => 'e.g. 155';

  @override
  String get onboardingHeightFtLabel => 'Height (ft)';

  @override
  String get onboardingHeightFtHint => 'e.g. 5';

  @override
  String get onboardingHeightInLabel => '(in)';

  @override
  String get onboardingHeightInHint => 'e.g. 9';

  @override
  String get onboardingFillStats =>
      'Please fill in your date of birth, weight and height';

  @override
  String get onboardingBmiCardLabel =>
      'BMI (your weight compared to your height)';

  @override
  String get onboardingGenderSubtitle =>
      'Men and women burn calories at slightly different rates';

  @override
  String get onboardingBmrCaption => 'Calories your body burns resting';

  @override
  String get onboardingBmrFootnote => 'Even if you stayed in bed all day';

  @override
  String onboardingKcalValue(String value) {
    return '$value kcal';
  }

  @override
  String onboardingKcalPerDayValue(String value) {
    return '$value kcal/day';
  }

  @override
  String get onboardingTdeeCaption => 'Calories you burn on a typical day';

  @override
  String get onboardingTdeeFootnote => 'Including your daily activity';

  @override
  String get onboardingActMostlySitting => 'Mostly sitting';

  @override
  String get onboardingActMostlySittingDesc =>
      'Desk job, little or no exercise';

  @override
  String get onboardingActLightlyActive => 'Lightly active';

  @override
  String get onboardingActLightlyActiveDesc =>
      'Walks or light exercise 1–3 days a week';

  @override
  String get onboardingActModeratelyActive => 'Moderately active';

  @override
  String get onboardingActModeratelyActiveDesc => 'Exercise 3–5 days a week';

  @override
  String get onboardingActActiveDesc => 'Hard exercise 6–7 days a week';

  @override
  String get onboardingActVeryActive => 'Very active';

  @override
  String get onboardingActVeryActiveDesc =>
      'Physical job or training twice a day';

  @override
  String get onboardingGoalLoseWeightLabel => 'Lose weight';

  @override
  String get onboardingGoalLoseWeightDetail =>
      'Eat a bit less than you burn (about 0.5 kg a week)';

  @override
  String get onboardingGoalBuildMuscleLabel => 'Build muscle';

  @override
  String get onboardingGoalBuildMuscleDetail =>
      'Eat a bit more than you burn, and do strength training';

  @override
  String get onboardingGoalStayLabel => 'Stay at my weight';

  @override
  String get onboardingGoalStayDetail => 'Eat about what you burn';

  @override
  String get onboardingOffsetLose =>
      '500 kcal less than you burn on a typical day';

  @override
  String get onboardingOffsetGain =>
      '300 kcal more than you burn on a typical day';

  @override
  String get onboardingOffsetSame => 'The same as you burn on a typical day';

  @override
  String get onboardingDailyGoalCaption => 'Your daily calorie goal';

  @override
  String newWorkoutCouldNotLoadExercises(String error) {
    return 'Couldn\'t load exercises. $error';
  }

  @override
  String get workoutModeSimpleSemantics =>
      'Simple mode: log activities you did';

  @override
  String get workoutModeAdvancedSemantics => 'Advanced mode: weekly gym plans';

  @override
  String get workoutSimpleIntro =>
      'Did some exercise? Find the activity and log it to count the calories you burned.';

  @override
  String get workoutSearchActivitiesHint => 'Search activities (e.g. walking)';

  @override
  String get workoutCategoryAll => 'All';

  @override
  String workoutActivitiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities',
      one: '$count activity',
    );
    return '$_temp0';
  }

  @override
  String get workoutActivitiesLoadError => 'Couldn\'t load activities';

  @override
  String get workoutNoActivitiesAvailable => 'No activities available';

  @override
  String get workoutNoActivitiesMatchSearch =>
      'No activities match your search';

  @override
  String workoutKcalPerHour(int kcal) {
    return '≈ $kcal kcal per hour';
  }

  @override
  String workoutKcalPerHourPerKg(String value) {
    return '$value kcal per hour per kg of body weight';
  }

  @override
  String progressLoadError(String error) {
    return 'Couldn\'t load your weight log. $error';
  }

  @override
  String progressSaveError(String error) {
    return 'Couldn\'t save this entry. $error';
  }

  @override
  String achievementCouldNotLoad(String error) {
    return 'Couldn\'t load achievements. $error';
  }

  @override
  String get achievementTypeMeals => 'MEALS';

  @override
  String get achievementTypeStreak => 'STREAK';

  @override
  String get achievementTypeCalories => 'CALORIES';

  @override
  String get achievementTypeWorkouts => 'WORKOUTS';

  @override
  String get achievementTypeCardio => 'CARDIO';

  @override
  String get achievementTypeProgress => 'PROGRESS';

  @override
  String get achievementTypeWeight => 'WEIGHT';

  @override
  String get achievementTypeMuscle => 'MUSCLE';

  @override
  String get foodsProductNotFound =>
      'We couldn\'t find that product. Try searching by name, or add it yourself with the + button.';

  @override
  String foodsScanFailed(String error) {
    return 'Couldn\'t scan the barcode. $error';
  }

  @override
  String foodsAddToMealTitle(String meal) {
    return 'Add to $meal';
  }

  @override
  String get foodsTryAgain => 'Try again';

  @override
  String foodsKcalPer100g(int value) {
    return '$value kcal per 100 g';
  }

  @override
  String get foodsNoMatch => 'No foods match your search.';

  @override
  String get foodsAddOwnFood => 'Add your own food';

  @override
  String get foodsNewFoodButton => 'New food';

  @override
  String foodsProteinPer100g(String value) {
    return 'Protein: $value per 100 g';
  }

  @override
  String foodsCarbsPer100g(String value) {
    return 'Carbs: $value per 100 g';
  }

  @override
  String foodsFatPer100g(String value) {
    return 'Fat: $value per 100 g';
  }

  @override
  String foodsProteinPill(String value) {
    return 'Protein $value';
  }

  @override
  String foodsCarbsPill(String value) {
    return 'Carbs $value';
  }

  @override
  String foodsFatPill(String value) {
    return 'Fat $value';
  }

  @override
  String get foodsSearchFoodsHint => 'Search foods';

  @override
  String get foodsScanTooltip => 'Scan a barcode';

  @override
  String get foodDetailsMealNameRequired => 'Please type a name for this meal.';

  @override
  String get foodDetailsGramsRequired => 'Please enter how many grams you ate.';

  @override
  String foodDetailsAddedSnack(int grams, String name, String meal, int kcal) {
    return 'Added $grams g of $name to $meal ($kcal kcal)';
  }

  @override
  String foodDetailsAddFailed(String error) {
    return 'Couldn\'t add this food. $error';
  }

  @override
  String foodDetailsFavoritesFailed(String error) {
    return 'Couldn\'t update favorites. $error';
  }

  @override
  String get foodDetailsNutritionPer100g => 'Nutrition per 100 g';

  @override
  String get foodDetailsHowMuch => 'How much did you eat?';

  @override
  String get foodDetailsAmountLabel => 'Amount';

  @override
  String get foodDetailsGramsSuffix => 'grams';

  @override
  String get foodDetailsPortionHint =>
      'Not sure? A slice of bread is about 30 g, an apple about 150 g, a cup of cooked rice about 160 g.';

  @override
  String get foodDetailsEnterAmountForCalories =>
      'Enter an amount to see the calories';

  @override
  String foodDetailsLiveTotal(
    String grams,
    int kcal,
    String protein,
    String carbs,
    String fat,
  ) {
    return '$grams g = $kcal kcal  ·  Protein $protein g  ·  Carbs $carbs g  ·  Fat $fat g';
  }

  @override
  String get foodDetailsWhichMeal => 'Which meal?';

  @override
  String get foodDetailsSnackChip => 'Snack';

  @override
  String get foodDetailsOtherMeal => 'Other…';

  @override
  String get foodDetailsMealNameLabel => 'Meal name';

  @override
  String get foodDetailsMealNameHint => 'e.g. Pre-workout, Late night';

  @override
  String get foodDetailsChangeDate => 'Change date';

  @override
  String get foodDetailsAddToMealButton => 'Add to meal';

  @override
  String foodDetailsAddToButton(String meal) {
    return 'Add to $meal';
  }

  @override
  String get mealDetailRemoveFoodTooltip => 'Remove food';

  @override
  String get mealHistoryTitle => 'Past days';

  @override
  String get mealHistoryEmpty => 'No meals logged on earlier days yet.';

  @override
  String mealHistoryKcalEaten(int kcal) {
    return '$kcal kcal eaten';
  }

  @override
  String get homeHelpTitle => 'What do these mean?';

  @override
  String get homeHelpBody =>
      'Calories (kcal) measure the energy in food. Eating about your daily goal helps you reach your target weight.\n\nProtein, carbs and fat are the three nutrients that give food its calories. Protein helps build and repair muscle, carbs give you energy, and fat supports your body in many ways.\n\nYou don\'t need to hit every number exactly. Focus on calories first, then try to get enough protein.';

  @override
  String get homeHelpGotIt => 'Got it';

  @override
  String get homeHelpTooltip => 'What do these numbers mean?';

  @override
  String get homeYourMealsHeading => 'Your meals';

  @override
  String get homeSeePastDays => 'See past days';

  @override
  String get homeLoadErrorTitle => 'We couldn\'t load today\'s data';

  @override
  String get homeTryAgain => 'Try again';

  @override
  String homeSemanticsEatenToday(int count) {
    return '$count calories eaten today';
  }

  @override
  String homeSemanticsOverGoal(int count) {
    return '$count calories over your goal today';
  }

  @override
  String homeSemanticsLeftToday(int count) {
    return '$count calories left today';
  }

  @override
  String get homeKcalEaten => 'kcal eaten';

  @override
  String get homeKcalOver => 'kcal over';

  @override
  String get homeKcalLeft => 'kcal left';

  @override
  String get homeSummaryGoal => 'Goal';

  @override
  String get homeSummaryEaten => 'Eaten';

  @override
  String get homeSummaryExercise => 'Exercise';

  @override
  String homeSummaryLabelKcal(String label) {
    return '$label (kcal)';
  }

  @override
  String get homeFinishProfileForGoal =>
      'Finish your profile on the Me tab to get a daily calorie goal.';

  @override
  String get homeExerciseAddedToGoal =>
      'Today\'s exercise is already added to your goal.';

  @override
  String homeNutrientOfGoal(int eaten, int goal) {
    return '$eaten of $goal g';
  }

  @override
  String get homeNothingAddedYet => 'Nothing added yet';

  @override
  String homeFoodsAndMore(String names, int count) {
    return '$names and $count more';
  }

  @override
  String homeAddFoodToMeal(String meal) {
    return 'Add food to $meal';
  }

  @override
  String get homeAddButton => 'Add';

  @override
  String get profileLogoutTitle => 'Log out?';

  @override
  String get profileLogoutConfirm =>
      'Are you sure you want to log out of your account?';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileChangePhotoTooltip => 'Change profile photo';

  @override
  String get profileHowActive => 'How active you are';

  @override
  String get profileYourGoal => 'Your goal';

  @override
  String get profileEditDetails => 'Edit my details';

  @override
  String get profileWeightLog => 'Weight log';

  @override
  String get profileTryAgain => 'Try again';

  @override
  String get notificationPromptTitle => 'Want a reminder?';

  @override
  String get notificationPromptBody =>
      'We can nudge you when you haven\'t logged a meal or a workout, and tell you when you unlock a badge. You can change this any time in Settings.';

  @override
  String get notificationPromptNotNow => 'Not now';

  @override
  String get notificationPromptTurnOn => 'Turn on reminders';

  @override
  String settingsCouldNotSave(String reason) {
    return 'Couldn\'t save. $reason';
  }

  @override
  String settingsCouldNotDelete(String reason) {
    return 'Couldn\'t delete your account. $reason';
  }

  @override
  String get labelNotSet => 'Not set';

  @override
  String get labelActivitySedentary => 'Mostly sitting';

  @override
  String get labelActivityLight => 'Lightly active';

  @override
  String get labelActivityModerate => 'Moderately active';

  @override
  String get labelActivityActive => 'Active';

  @override
  String get labelActivityVeryActive => 'Very active';

  @override
  String get labelGoalWeightLoss => 'Lose weight';

  @override
  String get labelGoalMuscleGain => 'Build muscle';

  @override
  String get labelGoalMaintenance => 'Stay at my weight';

  @override
  String get labelGenderMale => 'Male';

  @override
  String get labelGenderFemale => 'Female';

  @override
  String get labelMealBreakfast => 'Breakfast';

  @override
  String get labelMealLunch => 'Lunch';

  @override
  String get labelMealDinner => 'Dinner';

  @override
  String get labelMealSnacks => 'Snacks';

  @override
  String get labelIntensityVigorous => 'Vigorous';

  @override
  String get labelIntensityModerate => 'Moderate';

  @override
  String get labelIntensityLight => 'Light';

  @override
  String get errorTryAgain => 'Please try again.';

  @override
  String get errorNoConnection =>
      'Can\'t reach the server. Check your internet connection and try again.';

  @override
  String get errorSessionEnded =>
      'Your session has ended. Please log in again.';

  @override
  String get apiCheckDetails => 'Please check your details and try again.';

  @override
  String get apiTooManyAttempts =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get apiWrongCredentials =>
      'Wrong email or password. Please try again.';

  @override
  String get apiAccountDeactivated => 'This account has been deactivated.';

  @override
  String get apiInvalidEmail => 'Please enter a valid email address.';

  @override
  String get apiResetCodeInvalid =>
      'This code is wrong or has expired. Ask for a new one.';

  @override
  String achievementTargetMeals(int target) {
    return 'Log $target meal(s)';
  }

  @override
  String achievementTargetStreak(int target) {
    return 'Maintain a streak for $target days';
  }

  @override
  String achievementTargetCalories(int target) {
    return 'Reach $target calories';
  }

  @override
  String achievementTargetWorkouts(int target) {
    return 'Complete $target workout(s)';
  }

  @override
  String achievementTargetCardio(int target) {
    return 'Complete $target cardio session(s)';
  }

  @override
  String achievementTargetProgress(int target) {
    return 'Log $target progress update(s)';
  }

  @override
  String achievementTargetWeight(int target) {
    return 'Lose $target kg';
  }

  @override
  String achievementTargetMuscle(int target) {
    return 'Gain $target kg of muscle';
  }

  @override
  String achievementTargetTasks(int target) {
    return 'Complete $target tasks';
  }

  @override
  String achievementTargetCaloriesK(String thousands) {
    return 'Reach ${thousands}k calories';
  }

  @override
  String get mealScanTooltip => 'Scan your meal with the camera';

  @override
  String get mealScanTitle => 'Your meal';

  @override
  String get mealScanLooking => 'Point the camera at your plate';

  @override
  String mealScanItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foods',
      one: '$count food',
    );
    return '$_temp0';
  }

  @override
  String mealScanKcal(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get mealScanScanning => 'Scanning';

  @override
  String get mealScanPaused => 'Paused';

  @override
  String get mealScanPause => 'Pause scanning';

  @override
  String get mealScanRescan => 'Scan again';

  @override
  String get mealScanNoCamera =>
      'Couldn\'t open the camera. Check that the app may use it in your phone\'s settings, or add foods by hand below.';

  @override
  String get mealScanUnsureHint =>
      'Foods marked ? may be wrong. Tap one to check it.';

  @override
  String get mealScanAddItem => 'Add a food';

  @override
  String mealScanLogTo(String meal) {
    return 'Add to $meal';
  }

  @override
  String mealScanLogged(int count, String meal, int kcal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count foods to $meal ($kcal kcal)',
      one: 'Added $count food to $meal ($kcal kcal)',
    );
    return '$_temp0';
  }

  @override
  String mealScanLogFailed(String error) {
    return 'Couldn\'t add the meal. $error';
  }

  @override
  String mealScanRow(int grams, int kcal) {
    return '$grams g · $kcal kcal';
  }

  @override
  String mealScanRowUnsure(int grams) {
    return '$grams g · not sure, tap to check';
  }

  @override
  String get mealScanChangeFood => 'Change';

  @override
  String get mealScanRemove => 'Remove';

  @override
  String get mealScanDone => 'Done';

  @override
  String get mealScanUnavailable =>
      'Meal scanning isn\'t available right now. Add foods by hand below.';

  @override
  String get mealScanFailed =>
      'Couldn\'t reach the scanner. Tap the scan button to try again.';

  @override
  String get storyCreate => 'Create story';

  @override
  String get storyChooseLayout => 'Choose a layout';

  @override
  String get storyChooseLayoutHint =>
      'Next you can add your photo, then move and edit everything.';

  @override
  String get storyLayoutFullPhoto => 'Full photo';

  @override
  String get storyLayoutPhotoPanel => 'Photo + stats';

  @override
  String get storyTemplateBold => 'Bold';

  @override
  String get storyTemplateCentered => 'Centered';

  @override
  String get storyTemplateMinimal => 'Minimal';

  @override
  String get storyTemplatePanelBottom => 'Panel below';

  @override
  String get storyTemplatePanelTop => 'Panel above';

  @override
  String get storyTemplateCard => 'Card';

  @override
  String get storyStatusCompleted => 'Workout complete';

  @override
  String get storyStatusPlanned => 'Planned workout';

  @override
  String get storyPlanCaption => 'The plan';

  @override
  String get storyStatDuration => 'Duration';

  @override
  String get storyStatDurationEstimated => 'Est. time';

  @override
  String get storyStatCalories => 'kcal (est.)';

  @override
  String get storyStatExercises => 'Exercises';

  @override
  String get storyStatSets => 'Sets';

  @override
  String get storyStatReps => 'Reps';

  @override
  String storyMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String storyHoursMinutes(int hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String storyExerciseSetsReps(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String storyExerciseSetsSeconds(int sets, int seconds) {
    return '$sets × $seconds s';
  }

  @override
  String storyMoreExercises(int count) {
    return '+$count more';
  }

  @override
  String get storyBrand => 'Fitness Tracker';

  @override
  String get storyNewText => 'Your text';

  @override
  String get storyToolPhoto => 'Photo';

  @override
  String get storyToolText => 'Text';

  @override
  String get storyToolStats => 'Stats';

  @override
  String get storyToolStyle => 'Style';

  @override
  String get storyToolLayers => 'Layers';

  @override
  String get storyAddPhoto => 'Add photo';

  @override
  String get storyGallery => 'Gallery';

  @override
  String get storyReplacePhoto => 'Replace';

  @override
  String get storyCamera => 'Camera';

  @override
  String get storyResetPhoto => 'Recenter';

  @override
  String get storyPhotoHint => 'Pinch to zoom, drag to move the photo';

  @override
  String get storyDim => 'Dim';

  @override
  String get storyGradient => 'Gradient';

  @override
  String get storyAddText => 'Add text';

  @override
  String get storyAddExercises => 'Add exercises';

  @override
  String get storyAddStats => 'Add statistics';

  @override
  String get storyTextHint =>
      'Tap a text on the story to select it, tap again to edit it.';

  @override
  String get storyEditText => 'Edit text';

  @override
  String get storyApply => 'Apply';

  @override
  String get storyFontDisplay => 'Condensed';

  @override
  String get storyFontBody => 'Regular';

  @override
  String get storySize => 'Size';

  @override
  String get storySpacing => 'Spacing';

  @override
  String get storyWeightRegular => 'Regular';

  @override
  String get storyWeightMedium => 'Medium';

  @override
  String get storyWeightBold => 'Bold';

  @override
  String get storyWeightBlack => 'Black';

  @override
  String get storyAlignStart => 'Align start';

  @override
  String get storyAlignCenter => 'Center';

  @override
  String get storyAlignEnd => 'Align end';

  @override
  String get storyColorWhite => 'White';

  @override
  String get storyColorGray => 'Gray';

  @override
  String get storyColorAccent => 'Accent';

  @override
  String get storyColorDark => 'Black';

  @override
  String get storyUppercase => 'Capitals';

  @override
  String get storyShadow => 'Shadow';

  @override
  String get storyStatsNone => 'This workout has no statistics to show.';

  @override
  String get storyStatsHint =>
      'Turn statistics on or off, and drag to reorder them.';

  @override
  String get storyStatsHintPlanned =>
      'These are the plan\'s numbers, shown under \"The plan\". Turn them on or off, and drag to reorder.';

  @override
  String get storyEstimate => 'estimate';

  @override
  String get storyAccent => 'Accent color';

  @override
  String get storyBranding => 'Show the app name';

  @override
  String get storyChangeLayout => 'Change layout';

  @override
  String get storyResetDesign => 'Reset design';

  @override
  String get storyResetConfirmTitle => 'Reset the design?';

  @override
  String get storyResetConfirmBody =>
      'Text, stats and style go back to the layout as it started. Your photo stays.';

  @override
  String get storyReset => 'Reset';

  @override
  String get storyLayerStats => 'Statistics';

  @override
  String get storyLayerBrand => 'App name';

  @override
  String get storyLayerEmpty => 'Empty text';

  @override
  String get storyDuplicate => 'Duplicate';

  @override
  String get storyDelete => 'Delete';

  @override
  String get storyLock => 'Lock';

  @override
  String get storyUnlock => 'Unlock';

  @override
  String get storyBringForward => 'Bring forward';

  @override
  String get storySendBackward => 'Send backward';

  @override
  String get storyHide => 'Hide';

  @override
  String get storyShow => 'Show';

  @override
  String get storyUndo => 'Undo';

  @override
  String get storyRedo => 'Redo';

  @override
  String get storyPreview => 'Preview';

  @override
  String get storyClosePreview => 'Back to editing';

  @override
  String get storyNext => 'Next';

  @override
  String get storyDiscardTitle => 'Discard this story?';

  @override
  String get storyDiscardBody => 'Your changes will be lost.';

  @override
  String get storyDiscard => 'Discard';

  @override
  String get storyKeepEditing => 'Keep editing';

  @override
  String storyExportFailed(String error) {
    return 'Couldn\'t create the image. $error';
  }

  @override
  String get storyExportTitle => 'Your story';

  @override
  String get storySave => 'Save';

  @override
  String get storyShare => 'Share';

  @override
  String get storyDone => 'Done';

  @override
  String get storySaved => 'Saved to your gallery';

  @override
  String get storySaveDenied =>
      'Allow photo access in Settings to save your story.';

  @override
  String storySaveFailed(String error) {
    return 'Couldn\'t save the image. $error';
  }

  @override
  String get storyNotEnoughSpace =>
      'Not enough storage space to save the image.';

  @override
  String storyShareFailed(String error) {
    return 'Couldn\'t share the image. $error';
  }

  @override
  String get storyShareUnavailable =>
      'Sharing isn\'t available on this device.';

  @override
  String get storyPhotoDenied =>
      'Allow photo access in Settings to choose a photo.';

  @override
  String get storyCameraDenied =>
      'Allow camera access in Settings to take a photo.';

  @override
  String get storyPhotoFailed => 'Couldn\'t open this photo. Try another one.';
}
