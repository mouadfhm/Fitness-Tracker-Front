// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitness Tracker';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

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
  String get onboardingAgeLabel => 'Age';

  @override
  String get onboardingAgeHint => 'e.g. 25';

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
}
