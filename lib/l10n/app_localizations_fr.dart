// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Fitness Tracker';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String languageSystemSubtitle(String language) {
    return 'Suit votre téléphone ($language)';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get navToday => 'Aujourd\'hui';

  @override
  String get navWorkouts => 'Séances';

  @override
  String get navFoods => 'Aliments';

  @override
  String get navMe => 'Moi';

  @override
  String get notifications => 'Notifications';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountSubtitle =>
      'Supprimer définitivement votre compte et toutes vos données';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get retry => 'Réessayer';

  @override
  String get ok => 'OK';

  @override
  String get logout => 'Déconnexion';

  @override
  String get errorLabel => 'Erreur';

  @override
  String get confirmLogoutTitle => 'Confirmer la déconnexion';

  @override
  String get confirmLogoutMessage =>
      'Voulez-vous vraiment vous déconnecter de votre compte ?';

  @override
  String get notifMealRemindersTitle => 'Rappels de repas';

  @override
  String get notifMealRemindersSubtitle =>
      'Un petit rappel quand vous n\'avez pas noté de repas';

  @override
  String get notifWorkoutRemindersTitle => 'Rappels d\'entraînement';

  @override
  String get notifWorkoutRemindersSubtitle =>
      'Un petit rappel quand vous n\'avez pas fait de séance';

  @override
  String get notifAchievementsTitle => 'Succès';

  @override
  String get notifAchievementsSubtitle => 'Quand vous débloquez un badge';

  @override
  String get notifCheckInsTitle => 'Prises de nouvelles';

  @override
  String get notifCheckInsSubtitle => 'Si vous êtes absent depuis un moment';

  @override
  String get notifStreakSavesTitle => 'Sauvetage de série';

  @override
  String get notifStreakSavesSubtitle =>
      'Le soir, si votre série est sur le point de s\'arrêter';

  @override
  String settingsSaveFailed(String error) {
    return 'Impossible d\'enregistrer : $error';
  }

  @override
  String get settingsLoadingSettings => 'Chargement de vos paramètres…';

  @override
  String get settingsLoadSettingsFailed =>
      'Impossible de charger vos paramètres';

  @override
  String get settingsUnknownError => 'Erreur inconnue';

  @override
  String get settingsQuietHours => 'Heures silencieuses';

  @override
  String settingsQuietHoursRange(String from, String to) {
    return 'Aucune notification entre $from et $to';
  }

  @override
  String get settingsQuietHoursAnyTime =>
      'Les notifications peuvent arriver à toute heure';

  @override
  String get settingsQuietHoursFrom => 'De';

  @override
  String get settingsQuietHoursTo => 'À';

  @override
  String get settingsDeleteAccountConfirm =>
      'Voulez-vous vraiment supprimer votre compte ? Cette action est irréversible et toutes vos données seront définitivement supprimées.';

  @override
  String get settingsDeleteAccountSuccess => 'Compte supprimé avec succès';

  @override
  String settingsDeleteAccountFailed(String error) {
    return 'Échec de la suppression du compte : $error';
  }

  @override
  String get loginTitle => 'Content de vous revoir';

  @override
  String get loginHeading => 'Rebonjour !';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour continuer votre parcours fitness';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Veuillez saisir votre email';

  @override
  String get emailInvalid => 'Veuillez saisir une adresse email valide';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginPasswordRequired => 'Veuillez saisir votre mot de passe';

  @override
  String get loginButton => 'Connexion';

  @override
  String get loginFailed => 'Échec de la connexion. Veuillez réessayer.';

  @override
  String get loginNoAccount => 'Pas encore de compte ? ';

  @override
  String get registerLink => 'S\'inscrire';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerHeading => 'Bienvenue !';

  @override
  String get registerSubtitle => 'Créez votre compte pour commencer';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get fullNameRequired => 'Veuillez saisir votre nom complet';

  @override
  String get fullNameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get registerPasswordRequired => 'Veuillez saisir un mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordRequired => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get registrationFailed =>
      'Échec de l\'inscription. Veuillez réessayer.';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get onboardingFailedSave =>
      'Échec de l\'enregistrement du profil. Veuillez réessayer.';

  @override
  String get onboardingStep1Title => 'Vos données corporelles';

  @override
  String get onboardingStep1Subtitle =>
      'On s\'en sert pour calculer vos besoins caloriques quotidiens';

  @override
  String get onboardingAgeLabel => 'Âge';

  @override
  String get onboardingAgeHint => 'ex. 25';

  @override
  String get onboardingWeightLabel => 'Poids (kg)';

  @override
  String get onboardingWeightHint => 'ex. 70';

  @override
  String get onboardingHeightLabel => 'Taille (cm)';

  @override
  String get onboardingHeightHint => 'ex. 175';

  @override
  String get onboardingInvalidStats =>
      'Veuillez saisir un âge, un poids et une taille valides';

  @override
  String get onboardingBmiEnterStats => 'Saisissez vos données';

  @override
  String get onboardingBmiUnderweight => 'Insuffisance pondérale';

  @override
  String get onboardingBmiHealthy => 'Poids santé';

  @override
  String get onboardingBmiOverweight => 'Surpoids';

  @override
  String get onboardingBmiObese => 'Obésité';

  @override
  String get onboardingBmiLabel => 'IMC';

  @override
  String get onboardingStep2Title => 'Quel est votre genre ?';

  @override
  String get onboardingStep2Subtitle =>
      'Influence le calcul de votre métabolisme';

  @override
  String get onboardingBmrCardTitle =>
      'Calories quotidiennes estimées au repos';

  @override
  String get onboardingBmrCardSubtitle => 'Métabolisme de base';

  @override
  String get onboardingGenderMaleLabel => 'Homme';

  @override
  String get onboardingGenderMaleDesc =>
      'Métabolisme de base plus élevé en moyenne';

  @override
  String get onboardingGenderFemaleLabel => 'Femme';

  @override
  String get onboardingGenderFemaleDesc =>
      'Métabolisme de base plus bas en moyenne';

  @override
  String get onboardingStep3Title => 'Quel est votre niveau d\'activité ?';

  @override
  String get onboardingStep3Subtitle =>
      'Choisissez ce qui décrit le mieux votre semaine type';

  @override
  String get onboardingTdeeCardTitle =>
      'Dépense énergétique quotidienne totale';

  @override
  String onboardingTdeeMultiplier(String value) {
    return '×$value multiplicateur d\'activité';
  }

  @override
  String get onboardingActivitySedentary => 'Sédentaire';

  @override
  String get onboardingActivitySedentaryDesc =>
      'Travail de bureau, peu ou pas d\'exercice';

  @override
  String get onboardingActivityLight => 'Léger';

  @override
  String get onboardingActivityLightDesc =>
      'Exercice léger 1 à 3 jours/semaine';

  @override
  String get onboardingActivityModerate => 'Modéré';

  @override
  String get onboardingActivityModerateDesc => 'Exercice 3 à 5 jours/semaine';

  @override
  String get onboardingActivityActive => 'Actif';

  @override
  String get onboardingActivityActiveDesc =>
      'Exercice intense 6 à 7 jours/semaine';

  @override
  String get onboardingActivityVeryActive => 'Très actif';

  @override
  String get onboardingActivityVeryActiveDesc =>
      'Travail physique ou entraînement biquotidien';

  @override
  String get onboardingStep4Title => 'Quel est votre objectif ?';

  @override
  String get onboardingStep4Subtitle =>
      'On ajustera votre objectif quotidien en conséquence';

  @override
  String get onboardingTargetCardTitle => 'Votre objectif calorique quotidien';

  @override
  String onboardingTargetFromTdee(String offset) {
    return '$offset kcal par rapport à votre DEQT';
  }

  @override
  String get onboardingGoalLoseWeight => 'Perdre du poids';

  @override
  String get onboardingGoalLoseWeightDesc => 'Déficit quotidien de 500 kcal';

  @override
  String get onboardingGoalBuildMuscle => 'Prendre du muscle';

  @override
  String get onboardingGoalBuildMuscleDesc => 'Surplus quotidien de +300 kcal';

  @override
  String get onboardingGoalStayFit => 'Rester en forme';

  @override
  String get onboardingGoalStayFitDesc => 'Maintenir votre poids actuel';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingLetsGo => 'C\'est parti !';

  @override
  String appTextFieldRequired(String field) {
    return 'Veuillez saisir $field';
  }

  @override
  String logoutFailed(String error) {
    return 'Échec de la déconnexion : $error';
  }

  @override
  String get homeNoMealsLogged => 'Aucun repas enregistré pour l\'instant';

  @override
  String get homeToday => 'Aujourd\'hui';

  @override
  String get homeYesterday => 'Hier';

  @override
  String get homeMacroCalories => 'Calories';

  @override
  String get homeMacroProtein => 'Protéines';

  @override
  String get homeMacroFat => 'Lipides';

  @override
  String get homeMacroCarbs => 'Glucides';

  @override
  String get homeTitle => 'Suivi nutritionnel';

  @override
  String get homeDailyMacroGoals => 'Objectifs journaliers';

  @override
  String get homeYourMeals => 'Vos repas';

  @override
  String get profileImagePickFailed =>
      'Échec de la sélection de l\'image. Veuillez réessayer.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEditTooltip => 'Modifier le profil';

  @override
  String get profileFreeMember => 'Membre gratuit';

  @override
  String get profileAge => 'Âge';

  @override
  String profileYearsValue(String value) {
    return '$value ans';
  }

  @override
  String get profileWeight => 'Poids';

  @override
  String profileKgValue(String value) {
    return '$value kg';
  }

  @override
  String get profileHeight => 'Taille';

  @override
  String profileCmValue(String value) {
    return '$value cm';
  }

  @override
  String get profileActivityLevel => 'Niveau d\'activité';

  @override
  String get profileFitnessGoal => 'Objectif fitness';

  @override
  String get profileGender => 'Genre';

  @override
  String get profileProgress => 'Progrès';

  @override
  String get profileAchievements => 'Succès';

  @override
  String get profileHelp => 'Aide';

  @override
  String profileAppVersion(String version) {
    return 'Version de l\'app : $version';
  }

  @override
  String profileErrorMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get helpSupportTitle => 'Aide et assistance';

  @override
  String get helpContactSupport => 'Contacter l\'assistance';

  @override
  String get helpContactSupportSubtitle => 'Obtenez de l\'aide de notre équipe';

  @override
  String get helpFaqs => 'FAQ';

  @override
  String get helpFaqsSubtitle => 'Questions fréquentes';

  @override
  String get helpVideoTutorials => 'Tutoriels vidéo';

  @override
  String get helpVideoTutorialsSubtitle => 'Apprenez à utiliser l\'application';

  @override
  String get achievementUnlocked => 'DÉBLOQUÉ';

  @override
  String get achievementLocked => 'VERROUILLÉ';

  @override
  String get achievementDescriptionLabel => 'DESCRIPTION';

  @override
  String get achievementRequirementsLabel => 'CONDITIONS';

  @override
  String get achievementTargetLabel => 'Objectif';

  @override
  String get achievementCompletionDetailsLabel => 'DÉTAILS DE RÉUSSITE';

  @override
  String get achievementCompletedOnLabel => 'Terminé le';

  @override
  String achievementLoadError(String error) {
    return 'Erreur lors du chargement des succès : $error';
  }

  @override
  String get achievementNoneFound => 'Aucun succès trouvé';

  @override
  String achievementCompleteToUnlock(String description) {
    return 'À accomplir pour débloquer : $description';
  }

  @override
  String get achievementCompletedBadge => 'TERMINÉ';

  @override
  String get foodsNoBarcodeScanned => 'Aucun code-barres scanné.';

  @override
  String foodsNotFoundForBarcode(String barcode) {
    return 'Aucun aliment trouvé pour le code-barres : $barcode';
  }

  @override
  String foodsScanError(String error) {
    return 'Erreur lors du scan du code-barres : $error';
  }

  @override
  String get foodsSortByTitle => 'Trier les aliments par';

  @override
  String get sortDefault => 'Par défaut';

  @override
  String get foodsTitle => 'Aliments';

  @override
  String get foodsSortTooltip => 'Trier les aliments';

  @override
  String foodsSortingBy(String sortTitle) {
    return 'Trié par : $sortTitle';
  }

  @override
  String foodsCaloriesInline(String value) {
    return 'Calories : $value';
  }

  @override
  String foodsCaloriesKcal(String value) {
    return 'Calories : $value kcal';
  }

  @override
  String foodsProteinGrams(String value) {
    return 'Protéines : ${value}g';
  }

  @override
  String foodsCarbsGrams(String value) {
    return 'Glucides : ${value}g';
  }

  @override
  String foodsFatGrams(String value) {
    return 'Lipides : ${value}g';
  }

  @override
  String foodsProteinShort(String value) {
    return 'P : ${value}g';
  }

  @override
  String foodsCarbsShort(String value) {
    return 'G : ${value}g';
  }

  @override
  String foodsFatShort(String value) {
    return 'L : ${value}g';
  }

  @override
  String get foodsNoFoodsFound => 'Aucun aliment trouvé.';

  @override
  String get foodsSearchHint => 'Rechercher des aliments...';

  @override
  String get foodScanTitle => 'Scanner un code-barres';

  @override
  String get foodScanButton => 'Scanner le code-barres';

  @override
  String foodScanCalories(String value) {
    return 'Calories : $value kcal';
  }

  @override
  String foodScanProtein(String value) {
    return 'Protéines : $value g';
  }

  @override
  String foodScanCarbs(String value) {
    return 'Glucides : $value g';
  }

  @override
  String foodScanFats(String value) {
    return 'Lipides : $value g';
  }

  @override
  String get foodScanAddToMeal => 'Ajouter au repas';

  @override
  String get foodDetailsEnterQuantity => 'Veuillez saisir une quantité';

  @override
  String get foodDetailsEnterMealTime => 'Veuillez saisir un moment de repas';

  @override
  String get foodDetailsSelectMealTime =>
      'Veuillez sélectionner un moment de repas';

  @override
  String get foodDetailsEnterValidQuantity =>
      'Veuillez saisir une quantité valide';

  @override
  String get foodDetailsMealStoredSuccess => 'Repas enregistré avec succès !';

  @override
  String foodDetailsErrorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get foodDetailsRemovedFromFavorites => 'Retiré des favoris';

  @override
  String get foodDetailsAddedToFavorites => 'Ajouté aux favoris';

  @override
  String foodDetailsErrorUpdatingFavorites(String error) {
    return 'Erreur lors de la mise à jour des favoris : $error';
  }

  @override
  String get foodDetailsRemoveFromFavoritesTooltip => 'Retirer des favoris';

  @override
  String get foodDetailsAddToFavoritesTooltip => 'Ajouter aux favoris';

  @override
  String get foodDetailsNutritionFacts => 'Valeurs nutritionnelles';

  @override
  String get foodDetailsFatsLabel => 'Lipides';

  @override
  String get foodDetailsAddToMealPlan => 'Ajouter au plan de repas';

  @override
  String get foodDetailsSelectMealTimeHint => 'Choisir un moment de repas';

  @override
  String get foodDetailsCustomMealTimeHint =>
      'Saisir un moment de repas personnalisé';

  @override
  String get foodDetailsCustomMealTimeExamples =>
      'Exemples : Milieu de matinée, Tard le soir, Deuxième petit-déjeuner, etc.';

  @override
  String get foodDetailsQuantityHint => 'Quantité (grammes)';

  @override
  String mealDetailTitle(String mealTime) {
    return 'Détails - $mealTime';
  }

  @override
  String get mealDetailNoFoods => 'Aucun aliment dans ce repas';

  @override
  String get mealDetailRemoveFoodTitle => 'Retirer l\'aliment';

  @override
  String mealDetailRemoveFoodConfirm(String name) {
    return 'Voulez-vous vraiment retirer $name de ce repas ?';
  }

  @override
  String get mealDetailRemoveAction => 'Retirer';

  @override
  String get mealDetailQuantityLabel => 'Quantité';

  @override
  String get newFoodAddFailed =>
      'Échec de l\'ajout de l\'aliment. Veuillez réessayer.';

  @override
  String get newFoodInvalidNumber => 'Veuillez saisir un nombre valide';

  @override
  String get newFoodTitle => 'Ajouter un aliment';

  @override
  String get newFoodNameLabel => 'Nom de l\'aliment';

  @override
  String get newFoodNameHint => 'Saisissez le nom de l\'aliment';

  @override
  String get newFoodNameRequired => 'Veuillez saisir le nom de l\'aliment';

  @override
  String get newFoodCarbohydrates => 'Glucides';

  @override
  String get newFoodAddButton => 'Ajouter l\'aliment';

  @override
  String get updateProfileSuccessDefault => 'Profil mis à jour avec succès.';

  @override
  String get updateProfileFailed =>
      'Échec de la mise à jour du profil. Veuillez réessayer.';

  @override
  String get updateProfileAgeRequired => 'Veuillez saisir l\'âge';

  @override
  String get updateProfileAgeInvalid => 'Veuillez saisir un âge valide';

  @override
  String get updateProfileWeightRequired => 'Veuillez saisir le poids';

  @override
  String get updateProfileWeightInvalid => 'Veuillez saisir un poids valide';

  @override
  String get updateProfileHeightRequired => 'Veuillez saisir la taille';

  @override
  String get updateProfileHeightInvalid => 'Veuillez saisir une taille valide';

  @override
  String get updateProfileGenderRequired => 'Veuillez sélectionner un genre';

  @override
  String get updateProfileActivityRequired =>
      'Veuillez sélectionner un niveau d\'activité';

  @override
  String get updateProfileGoalRequired =>
      'Veuillez sélectionner un objectif fitness';

  @override
  String get updateProfileTitle => 'Mettre à jour le profil';

  @override
  String get progressFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get progressInvalidWeight => 'Valeur de poids invalide';

  @override
  String get progressAddedSuccess => 'Progrès ajouté avec succès !';

  @override
  String progressAddError(String error) {
    return 'Erreur lors de l\'ajout du progrès : $error';
  }

  @override
  String get progressNoDataAvailable => 'Aucune donnée de progrès disponible';

  @override
  String progressTooltip(String date, String weight) {
    return 'Date : $date\nPoids : $weight kg';
  }

  @override
  String get progressTitle => 'Suivi des progrès';

  @override
  String get progressAddEntryTitle => 'Ajouter une entrée';

  @override
  String get progressDateLabel => 'Date';

  @override
  String get progressAddYourProgress => 'Ajouter votre progrès';

  @override
  String get progressChartTitle => 'Graphique de progression';

  @override
  String get workoutModeSimple => 'Simple';

  @override
  String get workoutModeAdvanced => 'Avancé';

  @override
  String get workoutTitle => 'Entraînements';

  @override
  String get workoutDifficultyEasy => 'Facile';

  @override
  String get workoutDifficultyMedium => 'Moyen';

  @override
  String get workoutDifficultyHard => 'Difficile';

  @override
  String get workoutSearchExercisesHint => 'Rechercher des exercices...';

  @override
  String get workoutLoading => 'Chargement des entraînements...';

  @override
  String workoutFoundCount(int count) {
    return '$count entraînements trouvés';
  }

  @override
  String get workoutAllCategories => 'Toutes les catégories';

  @override
  String get workoutLoadError => 'Erreur lors du chargement des entraînements';

  @override
  String get workoutTryAgain => 'Réessayer';

  @override
  String get workoutNoneAvailable => 'Aucun entraînement disponible';

  @override
  String get workoutNoneMatchSearch =>
      'Aucun entraînement ne correspond à votre recherche';

  @override
  String get workoutClearFilters => 'Effacer les filtres';

  @override
  String get workoutNoDescription => 'Aucune description';

  @override
  String get workoutCategoryOther => 'Autre';

  @override
  String get workoutDetailsUnknownWorkout => 'Entraînement inconnu';

  @override
  String get workoutDetailsEnterDuration => 'Veuillez saisir une durée';

  @override
  String get workoutDetailsEnterValidDuration =>
      'Veuillez saisir une durée valide';

  @override
  String get workoutDetailsAddedSuccess => 'Entraînement ajouté avec succès !';

  @override
  String get workoutDetailsNoName => 'Sans nom';

  @override
  String get workoutDetailsUncategorized => 'Non catégorisé';

  @override
  String get workoutDetailsAboutTitle => 'À propos de cet entraînement';

  @override
  String get workoutDetailsIntensity => 'Intensité';

  @override
  String workoutDetailsCaloriesPerHour(String value) {
    return '$value/h';
  }

  @override
  String get workoutDetailsScheduleTitle => 'Planifier l\'entraînement';

  @override
  String get workoutDetailsDurationHint => 'Durée en minutes';

  @override
  String get workoutDetailsAddToPlan => 'Ajouter à mon programme';

  @override
  String workoutListLoadFailed(String error) {
    return 'Échec du chargement des entraînements : $error';
  }

  @override
  String workoutListImportFailed(String error) {
    return 'Échec de l\'importation du programme d\'entraînement : $error';
  }

  @override
  String workoutListSingleImportedSuccess(String name) {
    return 'Entraînement « $name » importé avec succès';
  }

  @override
  String get workoutListCycleImportedSuccess =>
      'Cycle d\'entraînement importé avec succès';

  @override
  String get workoutListDeletedSuccess => 'Entraînement supprimé avec succès';

  @override
  String workoutListDeleteFailed(String error) {
    return 'Échec de la suppression de l\'entraînement : $error';
  }

  @override
  String get workoutListTitle => 'Gestion des entraînements';

  @override
  String get workoutListImportTooltip =>
      'Importer un programme d\'entraînement';

  @override
  String get workoutListRefreshTooltip => 'Actualiser les entraînements';

  @override
  String get workoutListUnnamedWorkout => 'Entraînement sans nom';

  @override
  String get workoutListNoDescription => 'Aucune description';

  @override
  String get workoutListDeleteTooltip => 'Supprimer l\'entraînement';

  @override
  String get workoutListNoWorkoutsYet => 'Aucun entraînement pour l\'instant';

  @override
  String get workoutListCreateFirstWorkout =>
      'Créez votre premier entraînement pour commencer';

  @override
  String get workoutListCreateNewWorkout => 'Créer un entraînement';

  @override
  String get workoutListErrorLoading =>
      'Erreur lors du chargement des entraînements';

  @override
  String get workoutListUnknownError => 'Une erreur inconnue s\'est produite';

  @override
  String get dayMonday => 'Lundi';

  @override
  String get dayTuesday => 'Mardi';

  @override
  String get dayWednesday => 'Mercredi';

  @override
  String get dayThursday => 'Jeudi';

  @override
  String get dayFriday => 'Vendredi';

  @override
  String get daySaturday => 'Samedi';

  @override
  String get daySunday => 'Dimanche';

  @override
  String get workoutCalendarNoExportPlan =>
      'Aucun programme d\'entraînement à exporter';

  @override
  String get workoutCalendarExportedSuccess =>
      'Cycle d\'entraînement exporté avec succès';

  @override
  String workoutCalendarExportFailed(String error) {
    return 'Échec de l\'exportation du cycle d\'entraînement : $error';
  }

  @override
  String get workoutCalendarImportedCycleDefaultName => 'Cycle importé';

  @override
  String get workoutCalendarTitle => 'Mes entraînements';

  @override
  String get workoutCalendarOptionsTooltip =>
      'Options du programme d\'entraînement';

  @override
  String get workoutCalendarSavedCycles => 'Cycles d\'entraînement enregistrés';

  @override
  String get workoutCalendarExportCycle => 'Exporter le cycle d\'entraînement';

  @override
  String get workoutCalendarNoPlanAvailable =>
      'Aucun programme d\'entraînement disponible';

  @override
  String workoutCalendarNoPlanForWeek(int week) {
    return 'Aucun programme pour la semaine $week';
  }

  @override
  String workoutCalendarWeekLabel(int week) {
    return 'Semaine $week';
  }

  @override
  String workoutCalendarNoWorkoutsForDay(String day) {
    return 'Aucun entraînement pour $day';
  }

  @override
  String get workoutCalendarAddWorkoutButton => 'Ajouter un entraînement';

  @override
  String workoutCalendarWorkoutsForDay(String day) {
    return 'Entraînements pour $day';
  }

  @override
  String get workoutCalendarAddMoreTooltip => 'Ajouter plus d\'entraînements';

  @override
  String get workoutCalendarSearchWorkoutsHint =>
      'Rechercher des entraînements...';

  @override
  String get workoutCalendarAvailableWorkouts => 'Entraînements disponibles';

  @override
  String get workoutCalendarNoMatchingWorkouts =>
      'Aucun entraînement correspondant trouvé';

  @override
  String get workoutCalendarCreateFirstWorkout =>
      'Créez votre premier entraînement';

  @override
  String workoutCalendarAddFailed(String error) {
    return 'Échec de l\'ajout de l\'entraînement : $error';
  }

  @override
  String get workoutCalendarDetailsButton => 'Détails';

  @override
  String get workoutCalendarRemoveExerciseTooltip => 'Retirer l\'exercice';

  @override
  String get workoutCalendarMalformedEntry =>
      'Cette entrée d\'entraînement n\'a pas pu être chargée.';

  @override
  String get workoutCalendarRemoveEntryTooltip => 'Retirer l\'entrée';

  @override
  String get workoutCalendarPreviousWeek => 'Semaine précédente';

  @override
  String get workoutCalendarNextWeek => 'Semaine suivante';

  @override
  String get workoutCalendarCreateWorkoutPlan =>
      'Créer un programme d\'entraînement';

  @override
  String get workoutCalendarReuseSavedCycle => 'Réutiliser un cycle enregistré';

  @override
  String get importDialogWorkoutsToCreate =>
      'Les entraînements suivants seront créés :';

  @override
  String get importDialogUnmatchedExercises =>
      'Ces exercices sont introuvables et seront ignorés :';

  @override
  String get importDialogImportButton => 'Importer';

  @override
  String newWorkoutLoadExercisesFailed(String error) {
    return 'Échec du chargement des exercices : $error';
  }

  @override
  String get newWorkoutNeedExercise =>
      'Veuillez ajouter au moins un exercice à votre entraînement';

  @override
  String get newWorkoutTitle => 'Créer un entraînement';

  @override
  String get newWorkoutRefreshExercisesTooltip =>
      'Actualiser la liste des exercices';

  @override
  String get newWorkoutDetailsTitle => 'Détails de l\'entraînement';

  @override
  String get newWorkoutNameLabel => 'Nom de l\'entraînement';

  @override
  String get newWorkoutNameHint => 'ex. Haut du corps - Force';

  @override
  String get newWorkoutNameRequired => 'Veuillez saisir un nom d\'entraînement';

  @override
  String get newWorkoutDescriptionLabel => 'Description';

  @override
  String get newWorkoutDescriptionHint =>
      'Objectif de cet entraînement, groupes musculaires ciblés, etc.';

  @override
  String get newWorkoutDescriptionRequired => 'Veuillez saisir une description';

  @override
  String get newWorkoutExercisesTitle => 'Exercices';

  @override
  String get newWorkoutAddExercise => 'Ajouter un exercice';

  @override
  String get newWorkoutExercisesSubtitle =>
      'Ajoutez des exercices et configurez séries, répétitions et repos';

  @override
  String get newWorkoutNoExercisesYet =>
      'Aucun exercice ajouté pour l\'instant';

  @override
  String get newWorkoutAddExercisesPrompt =>
      'Ajoutez des exercices pour créer votre entraînement personnalisé';

  @override
  String get newWorkoutSetsLabel => 'Séries';

  @override
  String get newWorkoutRepsLabel => 'Répétitions';

  @override
  String get newWorkoutRestLabel => 'Repos (sec)';

  @override
  String get newWorkoutSelectExercisesTitle => 'Choisir des exercices';

  @override
  String get newWorkoutSearchExercisesHint => 'Rechercher des exercices...';

  @override
  String get newWorkoutNoExercisesFound => 'Aucun exercice trouvé';

  @override
  String get newWorkoutSaveButton => 'Enregistrer l\'entraînement';

  @override
  String get newWorkoutSaving => 'Enregistrement de votre entraînement...';

  @override
  String get newWorkoutErrorCreating =>
      'Erreur lors de la création de l\'entraînement';

  @override
  String get workoutDetailScreenExportedSuccess =>
      'Entraînement exporté avec succès';

  @override
  String workoutDetailScreenExportFailed(String error) {
    return 'Échec de l\'exportation de l\'entraînement : $error';
  }

  @override
  String get workoutDetailScreenTitle => 'Détails de l\'entraînement';

  @override
  String workoutDetailScreenErrorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get workoutDetailScreenNoDetails =>
      'Aucun détail d\'entraînement disponible';

  @override
  String get workoutDetailScreenRefresh => 'Actualiser';

  @override
  String get workoutDetailScreenExportTooltip => 'Exporter l\'entraînement';

  @override
  String get workoutDetailScreenNoDescription =>
      'Aucune description disponible';

  @override
  String workoutDetailScreenExercisesCount(int count) {
    return '$count exercices';
  }

  @override
  String workoutDetailScreenMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String workoutDetailScreenSetsCount(int count) {
    return '$count séries';
  }

  @override
  String workoutDetailScreenRepsCount(int count) {
    return '$count répétitions';
  }

  @override
  String workoutDetailScreenRestSeconds(int seconds) {
    return '${seconds}s de repos';
  }

  @override
  String get workoutDetailScreenDescriptionLabel => 'Description :';

  @override
  String workoutDetailScreenEquipmentLabel(String value) {
    return 'Équipement : $value';
  }

  @override
  String workoutDetailScreenLevelLabel(String value) {
    return 'Niveau : $value';
  }

  @override
  String get exerciseSelectionPleaseSelect =>
      'Veuillez sélectionner un exercice';

  @override
  String get exerciseSelectionInvalidValues =>
      'Veuillez saisir des valeurs valides pour les séries, répétitions et repos';

  @override
  String get exerciseSelectionInvalidDuration =>
      'Veuillez saisir une durée valide ou laisser vide';

  @override
  String get exerciseSelectionTitle => 'Choisir un exercice';

  @override
  String get exerciseSelectionFilterByBodyPart =>
      'Filtrer par partie du corps :';

  @override
  String get exerciseSelectionDurationLabel => 'Durée (sec)';

  @override
  String get exerciseSelectionOptionalHint => 'Facultatif';

  @override
  String get exerciseSelectionAddToWorkout => 'Ajouter à l\'entraînement';

  @override
  String get editWorkoutTitle => 'Modifier l\'entraînement';

  @override
  String get editWorkoutAddExercisesPrompt =>
      'Ajoutez des exercices pour mettre à jour votre entraînement personnalisé';

  @override
  String get editWorkoutUpdateButton => 'Mettre à jour l\'entraînement';

  @override
  String get editWorkoutUpdating => 'Mise à jour de votre entraînement...';

  @override
  String get editWorkoutErrorUpdating =>
      'Erreur lors de la mise à jour de l\'entraînement';

  @override
  String savedCyclesScheduled(String name) {
    return '« $name » programmé';
  }

  @override
  String get savedCyclesDefaultName => 'Cycle';

  @override
  String savedCyclesReuseFailed(String error) {
    return 'Échec de la réutilisation du cycle : $error';
  }

  @override
  String get savedCyclesDeleteTitle => 'Supprimer le cycle enregistré';

  @override
  String savedCyclesDeleteConfirm(String name) {
    return 'Supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String get savedCyclesThisCycle => 'ce cycle';

  @override
  String savedCyclesDeleteFailed(String error) {
    return 'Échec de la suppression du cycle : $error';
  }

  @override
  String savedCyclesAutoSetupFailed(String error) {
    return 'Impossible de configurer automatiquement les entraînements ($error). Choisissez plutôt un entraînement pour chaque jour en surbrillance.';
  }

  @override
  String get savedCyclesSuggestedTitle => 'Cycles suggérés';

  @override
  String get savedCyclesSuggestedSubtitle =>
      'Modèles de démarrage rapide — choisissez-en un et nous configurerons de vrais entraînements pour chaque jour.';

  @override
  String savedCyclesWeeksDaysPerWeek(int weeks, int days) {
    return '$weeks semaines · $days jours/semaine';
  }

  @override
  String get savedCyclesSettingUp => 'Configuration des entraînements…';

  @override
  String get savedCyclesTitle => 'Cycles d\'entraînement enregistrés';

  @override
  String savedCyclesLoadFailed(String error) {
    return 'Échec du chargement des cycles enregistrés : $error';
  }

  @override
  String get savedCyclesYourCycles => 'Vos cycles enregistrés';

  @override
  String get savedCyclesNoneYet =>
      'Aucun cycle d\'entraînement enregistré pour l\'instant';

  @override
  String get savedCyclesAutoSavedHint =>
      'Chaque cycle que vous créez est automatiquement enregistré ici pour que vous puissiez le réutiliser plus tard.';

  @override
  String get savedCyclesUnnamedCycle => 'Cycle sans nom';

  @override
  String savedCyclesWeeksAndDaysSummary(int weeks, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semaines',
      one: '$weeks semaine',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours d\'entraînement',
      one: '$days jour d\'entraînement',
    );
    return '$_temp0 · $_temp1/semaine';
  }

  @override
  String get savedCyclesReuseButton => 'Réutiliser';

  @override
  String newWorkoutCycleLoadFailed(String error) {
    return 'Échec du chargement des séances : $error';
  }

  @override
  String get newWorkoutCycleTitle => 'Nouveau cycle d\'entraînement';

  @override
  String get newWorkoutCycleRefreshTooltip => 'Actualiser';

  @override
  String get newWorkoutCycleNameLabel => 'Nom du cycle';

  @override
  String get newWorkoutCycleNameHint => 'ex. Programme de force estival';

  @override
  String get newWorkoutCycleNameSubtitle =>
      'Donnez à votre cycle un nom que vous reconnaîtrez';

  @override
  String get newWorkoutCycleDescriptionLabel => 'Description';

  @override
  String get newWorkoutCycleDescriptionHint =>
      'De quoi s\'agit-il dans ce cycle ?';

  @override
  String get newWorkoutCycleStartDateLabel => 'Date de début';

  @override
  String get newWorkoutCycleStartDateSubtitle =>
      'Quand ce cycle doit-il commencer ?';

  @override
  String get newWorkoutCycleWeeksLabel => 'Durée (semaines)';

  @override
  String newWorkoutCycleRepeatsFor(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Se répète pendant $weeks semaines',
      one: 'Se répète pendant 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String get newWorkoutCycleScheduleTitle => 'Programme hebdomadaire';

  @override
  String get newWorkoutCycleScheduleSubtitle =>
      'Attribuez une séance à chaque jour';

  @override
  String newWorkoutCycleRecommendedPending(int total, int pending) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other:
          '$pending jours recommandés sur $total n\'ont pas encore de séance',
      one: '$pending jour recommandé sur $total n\'a pas encore de séance',
    );
    return '$_temp0';
  }

  @override
  String get newWorkoutCycleRecommendedComplete =>
      'Tous les jours recommandés ont une séance assignée';

  @override
  String get newWorkoutCycleLoadingWorkouts => 'Chargement de vos séances…';

  @override
  String get newWorkoutCycleNoWorkoutsFound => 'Aucune séance trouvée';

  @override
  String get newWorkoutCycleCreateWorkoutsFirst =>
      'Créez d\'abord une séance personnalisée pour pouvoir l\'attribuer à un jour';

  @override
  String get newWorkoutCycleCreateWorkoutButton => 'Créer une séance';

  @override
  String get newWorkoutCycleDeleteWorkoutTitle => 'Supprimer la séance';

  @override
  String newWorkoutCycleDeleteWorkoutConfirm(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String newWorkoutCycleDeleteWorkoutFailed(String error) {
    return 'Échec de la suppression de la séance : $error';
  }

  @override
  String get newWorkoutCycleSearchWorkoutsHint => 'Rechercher des séances…';

  @override
  String get newWorkoutCycleRestDay => 'Jour de repos';

  @override
  String get newWorkoutCycleNoCustomWorkoutsYet =>
      'Vous n\'avez pas encore créé de séance personnalisée';

  @override
  String newWorkoutCycleNoWorkoutsMatch(String query) {
    return 'Aucune séance ne correspond à « $query »';
  }
}
