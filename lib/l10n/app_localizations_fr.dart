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
  String get onboardingBirthDateLabel => 'Date de naissance';

  @override
  String get onboardingBirthDateHint => 'Touchez pour choisir votre date';

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
  String get profileBirthDate => 'Date de naissance';

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

  @override
  String get workoutCalendarExportedPlan => 'Programme d\'entraînement exporté';

  @override
  String workoutCalendarExportPlanFailed(String error) {
    return 'Impossible d\'exporter votre programme. $error';
  }

  @override
  String workoutCalendarImportPlanFailed(String error) {
    return 'Impossible d\'importer ce programme. $error';
  }

  @override
  String get workoutCalendarImportFileHint =>
      'Vérifiez que le fichier est un programme d\'entraînement exporté depuis cette application.';

  @override
  String get workoutCalendarImportedPlan => 'Programme d\'entraînement importé';

  @override
  String workoutCalendarLoadWorkoutsFailed(String error) {
    return 'Impossible de charger vos entraînements. $error';
  }

  @override
  String get workoutCalendarSimpleModeSemantics =>
      'Mode simple : enregistrez les activités que vous avez faites';

  @override
  String get workoutCalendarAdvancedModeSemantics =>
      'Mode avancé : programmes de musculation hebdomadaires';

  @override
  String get workoutCalendarReadyMadePlans =>
      'Programmes prêts à l\'emploi et enregistrés';

  @override
  String get workoutCalendarExportMyPlan => 'Exporter mon programme';

  @override
  String get workoutCalendarImportPlan => 'Importer un programme';

  @override
  String workoutCalendarLoadPlanFailed(String error) {
    return 'Impossible de charger votre programme. $error';
  }

  @override
  String get workoutCalendarNoPlanYet =>
      'Vous n\'avez pas encore de programme d\'entraînement';

  @override
  String get workoutCalendarNothingPlannedThisWeek =>
      'Rien de prévu cette semaine';

  @override
  String get workoutCalendarThisWeek => 'Cette semaine';

  @override
  String get workoutCalendarNextWeekRelative => 'La semaine prochaine';

  @override
  String get workoutCalendarLastWeek => 'La semaine dernière';

  @override
  String get workoutCalendarAddToDayTooltip => 'Ajouter à ce jour';

  @override
  String workoutCalendarAddWorkoutFailed(String error) {
    return 'Impossible d\'ajouter cet entraînement. $error';
  }

  @override
  String workoutCalendarPlanStartsWeekOf(String date) {
    return 'Votre programme commence la semaine du $date.';
  }

  @override
  String get workoutCalendarShowThatWeek => 'Afficher cette semaine';

  @override
  String get workoutCalendarNewToWorkingOut => 'Vous débutez ?';

  @override
  String get workoutCalendarReadyMadePitch =>
      'Commencez avec un programme prêt à l\'emploi. Full Body, c\'est 3 jours par semaine, et nous choisissons les exercices pour vous.';

  @override
  String get workoutCalendarChooseReadyMadePlan =>
      'Choisir un programme prêt à l\'emploi';

  @override
  String get workoutCalendarBuildOwnPlan => 'Créer mon propre programme';

  @override
  String workoutDetailScreenExportWorkoutFailed(String error) {
    return 'Impossible d\'exporter cet entraînement. $error';
  }

  @override
  String workoutDetailScreenLoadFailed(String error) {
    return 'Impossible de charger cet entraînement. $error';
  }

  @override
  String get workoutDetailScreenEditTooltip => 'Modifier l\'entraînement';

  @override
  String workoutDetailScreenDurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String get workoutDetailsIntensityLight => 'Légère';

  @override
  String get workoutDetailsIntensityModerate => 'Modérée';

  @override
  String get workoutDetailsIntensityVigorous => 'Intense';

  @override
  String get workoutDetailsEnterMinutes =>
      'Indiquez combien de minutes vous avez fait de l\'exercice';

  @override
  String workoutDetailsLoggedSuccess(int minutes) {
    return 'Bravo ! $minutes min enregistrées. Vous les verrez dans l\'onglet Aujourd\'hui.';
  }

  @override
  String workoutDetailsLogFailed(String error) {
    return 'Erreur : impossible d\'enregistrer cette activité. $error';
  }

  @override
  String get workoutDetailsAboutActivity => 'À propos de cette activité';

  @override
  String get workoutDetailsBurnsAbout => 'Brûle environ';

  @override
  String workoutDetailsKcalPerHour(String kcal) {
    return '$kcal kcal/heure';
  }

  @override
  String get workoutDetailsLogActivity => 'Enregistrer cette activité';

  @override
  String get workoutDetailsWhenTapToChange => 'Quand (touchez pour modifier)';

  @override
  String get workoutDetailsHowManyMinutes => 'Combien de minutes ?';

  @override
  String workoutDetailsAboutKcalBurned(int kcal) {
    return 'Environ $kcal kcal brûlées';
  }

  @override
  String get workoutDetailsIDidThis => 'Je l\'ai fait';

  @override
  String get exerciseSelectionAllBodyParts => 'Toutes';

  @override
  String get savedCyclesSuggestedFullBodyName => 'Corps entier';

  @override
  String get savedCyclesSuggestedFullBodyDescription =>
      'Tout le corps, 3 jours par semaine avec des jours de repos entre les séances. Idéal pour commencer.';

  @override
  String get savedCyclesSuggestedUpperLowerName => 'Haut / Bas';

  @override
  String get savedCyclesSuggestedUpperLowerDescription =>
      'Le haut du corps un jour, les jambes le lendemain. À essayer quand 3 jours par semaine vous semblent faciles.';

  @override
  String get savedCyclesSuggestedPushPullLegsName => 'Poussée Tirage Jambes';

  @override
  String get savedCyclesSuggestedPushPullLegsDescription =>
      'Des muscles différents chaque jour. Pour ceux qui s\'entraînent déjà souvent.';

  @override
  String savedCyclesStartPlanFailed(String error) {
    return 'Impossible de démarrer ce programme. $error';
  }

  @override
  String get savedCyclesDeletePlanTitle => 'Supprimer le programme enregistré';

  @override
  String get savedCyclesThisPlan => 'ce programme';

  @override
  String savedCyclesDeletePlanFailed(String error) {
    return 'Impossible de supprimer ce programme. $error';
  }

  @override
  String get savedCyclesReadyMadeTitle => 'Programmes prêts à l\'emploi';

  @override
  String get savedCyclesReadyMadeSubtitle =>
      'Choisissez-en un et nous ajouterons les exercices pour chaque jour d\'entraînement. Vous hésitez ? Commencez par Corps entier.';

  @override
  String get savedCyclesBeginnerBadge => 'Débutant';

  @override
  String savedCyclesDaysAWeekWeeks(int days, int weeks) {
    return '$days jours par semaine · $weeks semaines';
  }

  @override
  String get savedCyclesPlansTitle => 'Programmes d\'entraînement';

  @override
  String savedCyclesLoadPlansFailed(String error) {
    return 'Impossible de charger vos programmes. $error';
  }

  @override
  String get savedCyclesYourPlans => 'Vos programmes enregistrés';

  @override
  String get savedCyclesNoPlansYet =>
      'Aucun programme enregistré pour l\'instant';

  @override
  String get savedCyclesPlansAutoSavedHint =>
      'Chaque programme que vous créez est enregistré ici pour que vous puissiez le réutiliser plus tard.';

  @override
  String get savedCyclesUnnamedPlan => 'Programme sans nom';

  @override
  String get newWorkoutCycleRefreshWorkoutListTooltip =>
      'Actualiser la liste des séances';

  @override
  String get newWorkoutCyclePlanNameLabel => 'Nom du programme';

  @override
  String get newWorkoutCyclePlanNameHint => 'ex. Poussée Tirage Jambes';

  @override
  String get newWorkoutCyclePlanNameSubtitle =>
      'Donnez-lui un nom pour pouvoir enregistrer et réutiliser ce programme plus tard';

  @override
  String get newWorkoutCycleDescriptionOptionalLabel =>
      'Description (facultatif)';

  @override
  String get newWorkoutCycleDescriptionExampleHint =>
      'ex. 3 jours par semaine pour gagner en force';

  @override
  String get newWorkoutCyclePlanStartHint =>
      'Votre programme commencera à cette date';

  @override
  String get newWorkoutCycleNumberOfWeeksLabel => 'Nombre de semaines';

  @override
  String newWorkoutCyclePlanRepeatsFor(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other:
          'Votre programme se répétera chaque semaine pendant $weeks semaines',
      one: 'Votre programme se répétera chaque semaine pendant $weeks semaine',
    );
    return '$_temp0';
  }

  @override
  String get newWorkoutCycleWorkoutScheduleTitle => 'Planning des séances';

  @override
  String get newWorkoutCycleWorkoutScheduleSubtitle =>
      'Choisissez les séances pour chaque jour de la semaine';

  @override
  String newWorkoutCycleTemplateSuggestsDays(int total, int pending) {
    return 'Ce modèle propose $total jour(s) d\'entraînement, indiqués ci-dessous. Choisissez une séance pour le(s) $pending jour(s) encore surligné(s) en orange — les autres jours restent des jours de repos, sauf si vous les modifiez.';
  }

  @override
  String get newWorkoutCycleAllSuggestedDaysAssigned =>
      'Tous les jours d\'entraînement proposés ont une séance attribuée.';

  @override
  String get newWorkoutCycleLoadingCustomWorkouts =>
      'Chargement de vos séances personnalisées...';

  @override
  String get newWorkoutCycleNoCustomWorkoutsFound =>
      'Aucune séance personnalisée trouvée';

  @override
  String get newWorkoutCycleCreateWorkoutFirstHint =>
      'Créez d\'abord une séance, puis ajoutez-la à votre programme';

  @override
  String newWorkoutCycleDeleteWorkoutRestDayConfirm(String name) {
    return 'Supprimer « $name » ? Les jours qui l\'utilisent deviendront des jours de repos.';
  }

  @override
  String newWorkoutCycleDeleteThisWorkoutFailed(String error) {
    return 'Impossible de supprimer cette séance. $error';
  }

  @override
  String get newWorkoutCycleNoCustomWorkoutsYetShort =>
      'Aucune séance personnalisée pour l\'instant';

  @override
  String get newWorkoutCycleRecommendedTrainingDay =>
      'Jour d\'entraînement recommandé';

  @override
  String get newWorkoutCycleChooseWorkout => 'Choisir une séance';

  @override
  String get newWorkoutCycleAddNewWorkout => 'Ajouter une séance';

  @override
  String get newWorkoutCycleCreatePlanButton => 'Créer le programme';

  @override
  String get newWorkoutCycleCreatingPlan =>
      'Création de votre programme d\'entraînement...';

  @override
  String get newWorkoutCycleCreatePlanFailedTitle =>
      'Impossible de créer votre programme';

  @override
  String newWorkoutCycleLoadWorkoutsFailed(String error) {
    return 'Impossible de charger vos séances. $error';
  }

  @override
  String get loginCouldNotLogIn => 'Connexion impossible. Veuillez réessayer.';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginLogIn => 'Se connecter';

  @override
  String get loginCreateOne => 'Créez-en un';

  @override
  String get registerCouldNotCreate =>
      'Impossible de créer votre compte. Veuillez réessayer.';

  @override
  String get registerPrivacyAgreement =>
      'En créant un compte, vous acceptez notre politique de confidentialité';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordIntro =>
      'Saisissez l\'adresse e-mail de votre compte et nous vous enverrons un code pour réinitialiser votre mot de passe.';

  @override
  String forgotPasswordCodeSentIntro(String email) {
    return 'Si $email correspond à un compte, nous y avons envoyé un code à 6 chiffres. Saisissez-le ci-dessous avec votre nouveau mot de passe.';
  }

  @override
  String get forgotPasswordCodeLabel => 'Code';

  @override
  String get forgotPasswordCodeInvalid =>
      'Saisissez le code à 6 chiffres reçu par e-mail';

  @override
  String get forgotPasswordNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get forgotPasswordConfirmNewPasswordLabel =>
      'Confirmer le nouveau mot de passe';

  @override
  String get forgotPasswordChangeButton => 'Changer le mot de passe';

  @override
  String get forgotPasswordSendCode => 'Envoyer le code';

  @override
  String get forgotPasswordResend => 'Rien reçu ? Envoyer un nouveau code';

  @override
  String get forgotPasswordSendFailed =>
      'Impossible d\'envoyer le code. Veuillez réessayer.';

  @override
  String get forgotPasswordChangeFailed =>
      'Impossible de changer votre mot de passe. Veuillez réessayer.';

  @override
  String get forgotPasswordChanged =>
      'Mot de passe modifié. Vous pouvez maintenant vous connecter.';

  @override
  String get helpCommonQuestions => 'Questions fréquentes';

  @override
  String get helpFaqLogFoodQ => 'Comment enregistrer ce que j\'ai mangé ?';

  @override
  String get helpFaqLogFoodA =>
      'Dans l\'onglet Aujourd\'hui, appuyez sur « Ajouter » à côté du repas (petit-déjeuner, déjeuner, dîner ou collations). Recherchez l\'aliment, indiquez combien de grammes vous avez mangé et appuyez sur « Ajouter ». Vous pouvez aussi scanner un code-barres dans l\'onglet Aliments.';

  @override
  String get helpFaqNoScaleQ =>
      'Je ne pèse pas mes aliments. Que dois-je saisir ?';

  @override
  String get helpFaqNoScaleA =>
      'Une estimation approximative suffit. Une tranche de pain pèse environ 30 g, une pomme environ 150 g, une tasse de riz cuit environ 160 g et un blanc de poulet environ 170 g. Servez-vous des boutons rapides (50, 100, 150, 200 g) comme point de départ.';

  @override
  String get helpFaqKcalLeftQ => 'Que signifie « kcal restantes » ?';

  @override
  String get helpFaqKcalLeftA =>
      'C\'est le nombre de calories que vous pouvez encore manger aujourd\'hui tout en restant sur la bonne voie pour votre objectif. Si vous le dépassez, le nombre devient rouge. Un jour de dépassement n\'est pas grave ; ce qui compte, c\'est la plupart des jours.';

  @override
  String get helpFaqMacrosQ =>
      'Que sont les protéines, les glucides et les lipides ?';

  @override
  String get helpFaqMacrosA =>
      'Ce sont les trois nutriments qui apportent les calories des aliments. Les protéines aident à construire et réparer les muscles, les glucides sont votre principale source d\'énergie et les lipides soutiennent votre corps de bien des façons. Concentrez-vous d\'abord sur les calories, puis sur un apport suffisant en protéines.';

  @override
  String get helpFaqCalorieGoalQ =>
      'Comment mon objectif calorique quotidien est-il calculé ?';

  @override
  String get helpFaqCalorieGoalA =>
      'À partir de votre âge, votre poids, votre taille, votre sexe et votre niveau d\'activité, nous estimons combien de calories vous brûlez lors d\'une journée normale. Ensuite, nous retirons 500 pour perdre du poids, ajoutons 300 pour prendre du muscle, ou gardons la même valeur. L\'exercice que vous enregistrez s\'ajoute pour la journée.';

  @override
  String get helpFaqLogExerciseQ =>
      'Comment enregistrer une activité physique ?';

  @override
  String get helpFaqLogExerciseA =>
      'Allez dans l\'onglet Entraînements. En mode Simple, trouvez l\'activité (marche, vélo, …), appuyez dessus, choisissez le nombre de minutes et appuyez sur « Je l\'ai fait ».';

  @override
  String get helpFaqAdvancedModeQ => 'Qu\'est-ce que le mode Avancé ?';

  @override
  String get helpFaqAdvancedModeA =>
      'Le mode Avancé sert à planifier vos séances de salle semaine par semaine. Si vous débutez, choisissez un programme tout prêt : Full Body, c\'est 3 jours par semaine et nous ajoutons les exercices pour vous.';

  @override
  String get helpFaqChangeGoalQ =>
      'Comment modifier mon poids ou mon objectif ?';

  @override
  String get helpFaqChangeGoalA =>
      'Allez dans l\'onglet Moi et appuyez sur le bouton de modification en haut. Pour suivre votre poids au fil du temps, utilisez « Suivi du poids » dans le même onglet.';

  @override
  String get helpDisclaimer =>
      'Les objectifs caloriques, les calories brûlées et l\'IMC affichés dans cette application sont des estimations pour vous guider, pas un avis médical. Si vous avez un problème de santé, êtes enceinte ou prévoyez un changement important d\'alimentation ou d\'activité physique, consultez d\'abord un médecin.';

  @override
  String get helpEmailUs => 'Toujours bloqué ? Écrivez-nous';

  @override
  String helpNoEmailApp(String email) {
    return 'Aucune application de messagerie trouvée. Vous pouvez écrire à $email.';
  }

  @override
  String get appTextFieldHidePassword => 'Masquer le mot de passe';

  @override
  String get appTextFieldShowPassword => 'Afficher le mot de passe';

  @override
  String get adaptiveDone => 'OK';

  @override
  String privacyPolicyOpenFailed(String url) {
    return 'Impossible d\'ouvrir la politique de confidentialité. Elle se trouve à l\'adresse $url';
  }

  @override
  String onboardingSaveFailed(String error) {
    return 'Impossible d\'enregistrer vos informations. $error';
  }

  @override
  String get onboardingBodyStatsSubtitle =>
      'Nous les utilisons uniquement pour calculer combien vous devriez manger chaque jour. Vous pouvez les modifier à tout moment.';

  @override
  String get onboardingUnitsMetric => 'kg / cm';

  @override
  String get onboardingUnitsImperial => 'lb / ft';

  @override
  String get onboardingWeightLbLabel => 'Poids (lb)';

  @override
  String get onboardingWeightLbHint => 'ex. 155';

  @override
  String get onboardingHeightFtLabel => 'Taille (ft)';

  @override
  String get onboardingHeightFtHint => 'ex. 5';

  @override
  String get onboardingHeightInLabel => '(in)';

  @override
  String get onboardingHeightInHint => 'ex. 9';

  @override
  String get onboardingFillStats =>
      'Veuillez indiquer votre date de naissance, votre poids et votre taille';

  @override
  String get onboardingBmiCardLabel =>
      'IMC (votre poids par rapport à votre taille)';

  @override
  String get onboardingGenderSubtitle =>
      'Les hommes et les femmes brûlent les calories à un rythme légèrement différent';

  @override
  String get onboardingBmrCaption =>
      'Calories brûlées par votre corps au repos';

  @override
  String get onboardingBmrFootnote =>
      'Même si vous restiez au lit toute la journée';

  @override
  String onboardingKcalValue(String value) {
    return '$value kcal';
  }

  @override
  String onboardingKcalPerDayValue(String value) {
    return '$value kcal/jour';
  }

  @override
  String get onboardingTdeeCaption =>
      'Calories brûlées lors d\'une journée type';

  @override
  String get onboardingTdeeFootnote => 'Activité quotidienne comprise';

  @override
  String get onboardingActMostlySitting => 'Plutôt assis';

  @override
  String get onboardingActMostlySittingDesc =>
      'Travail de bureau, peu ou pas d\'exercice';

  @override
  String get onboardingActLightlyActive => 'Légèrement actif';

  @override
  String get onboardingActLightlyActiveDesc =>
      'Marche ou exercice léger 1 à 3 jours par semaine';

  @override
  String get onboardingActModeratelyActive => 'Modérément actif';

  @override
  String get onboardingActModeratelyActiveDesc =>
      'Exercice 3 à 5 jours par semaine';

  @override
  String get onboardingActActiveDesc =>
      'Exercice intense 6 à 7 jours par semaine';

  @override
  String get onboardingActVeryActive => 'Très actif';

  @override
  String get onboardingActVeryActiveDesc =>
      'Travail physique ou entraînement deux fois par jour';

  @override
  String get onboardingGoalLoseWeightLabel => 'Perdre du poids';

  @override
  String get onboardingGoalLoseWeightDetail =>
      'Manger un peu moins que ce que vous brûlez (environ 0,5 kg par semaine)';

  @override
  String get onboardingGoalBuildMuscleLabel => 'Prendre du muscle';

  @override
  String get onboardingGoalBuildMuscleDetail =>
      'Manger un peu plus que ce que vous brûlez et faire de la musculation';

  @override
  String get onboardingGoalStayLabel => 'Garder mon poids';

  @override
  String get onboardingGoalStayDetail => 'Manger à peu près ce que vous brûlez';

  @override
  String get onboardingOffsetLose =>
      '500 kcal de moins que ce que vous brûlez lors d\'une journée type';

  @override
  String get onboardingOffsetGain =>
      '300 kcal de plus que ce que vous brûlez lors d\'une journée type';

  @override
  String get onboardingOffsetSame =>
      'Autant que ce que vous brûlez lors d\'une journée type';

  @override
  String get onboardingDailyGoalCaption => 'Votre objectif calorique quotidien';

  @override
  String newWorkoutCouldNotLoadExercises(String error) {
    return 'Impossible de charger les exercices. $error';
  }

  @override
  String get workoutModeSimpleSemantics =>
      'Mode simple : enregistrez les activités que vous avez faites';

  @override
  String get workoutModeAdvancedSemantics =>
      'Mode avancé : programmes de musculation hebdomadaires';

  @override
  String get workoutSimpleIntro =>
      'Vous avez fait du sport ? Trouvez l\'activité et enregistrez-la pour compter les calories brûlées.';

  @override
  String get workoutSearchActivitiesHint =>
      'Rechercher une activité (ex. marche)';

  @override
  String get workoutCategoryAll => 'Toutes';

  @override
  String workoutActivitiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activités',
      one: '$count activité',
    );
    return '$_temp0';
  }

  @override
  String get workoutActivitiesLoadError =>
      'Impossible de charger les activités';

  @override
  String get workoutNoActivitiesAvailable => 'Aucune activité disponible';

  @override
  String get workoutNoActivitiesMatchSearch =>
      'Aucune activité ne correspond à votre recherche';

  @override
  String workoutKcalPerHour(int kcal) {
    return '≈ $kcal kcal par heure';
  }

  @override
  String workoutKcalPerHourPerKg(String value) {
    return '$value kcal par heure et par kg de poids corporel';
  }

  @override
  String progressLoadError(String error) {
    return 'Impossible de charger votre suivi du poids. $error';
  }

  @override
  String progressSaveError(String error) {
    return 'Impossible d\'enregistrer cette entrée. $error';
  }

  @override
  String achievementCouldNotLoad(String error) {
    return 'Impossible de charger les succès. $error';
  }

  @override
  String get achievementTypeMeals => 'REPAS';

  @override
  String get achievementTypeStreak => 'SÉRIE';

  @override
  String get achievementTypeCalories => 'CALORIES';

  @override
  String get achievementTypeWorkouts => 'ENTRAÎNEMENTS';

  @override
  String get achievementTypeCardio => 'CARDIO';

  @override
  String get achievementTypeProgress => 'PROGRÈS';

  @override
  String get achievementTypeWeight => 'POIDS';

  @override
  String get achievementTypeMuscle => 'MUSCULATION';

  @override
  String get foodsProductNotFound =>
      'Produit introuvable. Essayez de le rechercher par son nom, ou ajoutez-le vous-même avec le bouton +.';

  @override
  String foodsScanFailed(String error) {
    return 'Impossible de scanner le code-barres. $error';
  }

  @override
  String foodsAddToMealTitle(String meal) {
    return 'Ajouter au repas : $meal';
  }

  @override
  String get foodsTryAgain => 'Réessayer';

  @override
  String foodsKcalPer100g(int value) {
    return '$value kcal pour 100 g';
  }

  @override
  String get foodsNoMatch => 'Aucun aliment ne correspond à votre recherche.';

  @override
  String get foodsAddOwnFood => 'Ajouter votre propre aliment';

  @override
  String get foodsNewFoodButton => 'Nouvel aliment';

  @override
  String foodsProteinPer100g(String value) {
    return 'Protéines : $value pour 100 g';
  }

  @override
  String foodsCarbsPer100g(String value) {
    return 'Glucides : $value pour 100 g';
  }

  @override
  String foodsFatPer100g(String value) {
    return 'Lipides : $value pour 100 g';
  }

  @override
  String foodsProteinPill(String value) {
    return 'Protéines $value';
  }

  @override
  String foodsCarbsPill(String value) {
    return 'Glucides $value';
  }

  @override
  String foodsFatPill(String value) {
    return 'Lipides $value';
  }

  @override
  String get foodsSearchFoodsHint => 'Rechercher des aliments';

  @override
  String get foodsScanTooltip => 'Scanner un code-barres';

  @override
  String get foodDetailsMealNameRequired =>
      'Veuillez saisir un nom pour ce repas.';

  @override
  String get foodDetailsGramsRequired =>
      'Veuillez indiquer combien de grammes vous avez mangé.';

  @override
  String foodDetailsAddedSnack(int grams, String name, String meal, int kcal) {
    return '$grams g de $name ajoutés au repas : $meal ($kcal kcal)';
  }

  @override
  String foodDetailsAddFailed(String error) {
    return 'Impossible d\'ajouter cet aliment. $error';
  }

  @override
  String foodDetailsFavoritesFailed(String error) {
    return 'Impossible de mettre à jour les favoris. $error';
  }

  @override
  String get foodDetailsNutritionPer100g =>
      'Valeurs nutritionnelles pour 100 g';

  @override
  String get foodDetailsHowMuch => 'Quelle quantité avez-vous mangée ?';

  @override
  String get foodDetailsAmountLabel => 'Quantité';

  @override
  String get foodDetailsGramsSuffix => 'grammes';

  @override
  String get foodDetailsPortionHint =>
      'Vous hésitez ? Une tranche de pain pèse environ 30 g, une pomme environ 150 g, une tasse de riz cuit environ 160 g.';

  @override
  String get foodDetailsEnterAmountForCalories =>
      'Saisissez une quantité pour voir les calories';

  @override
  String foodDetailsLiveTotal(
    String grams,
    int kcal,
    String protein,
    String carbs,
    String fat,
  ) {
    return '$grams g = $kcal kcal  ·  Protéines $protein g  ·  Glucides $carbs g  ·  Lipides $fat g';
  }

  @override
  String get foodDetailsWhichMeal => 'Quel repas ?';

  @override
  String get foodDetailsSnackChip => 'Collation';

  @override
  String get foodDetailsOtherMeal => 'Autre…';

  @override
  String get foodDetailsMealNameLabel => 'Nom du repas';

  @override
  String get foodDetailsMealNameHint => 'ex. Avant l\'entraînement, En soirée';

  @override
  String get foodDetailsChangeDate => 'Changer la date';

  @override
  String get foodDetailsAddToMealButton => 'Ajouter au repas';

  @override
  String foodDetailsAddToButton(String meal) {
    return 'Ajouter ($meal)';
  }

  @override
  String get mealDetailRemoveFoodTooltip => 'Retirer l\'aliment';

  @override
  String get mealHistoryTitle => 'Jours précédents';

  @override
  String get mealHistoryEmpty =>
      'Aucun repas enregistré les jours précédents pour l\'instant.';

  @override
  String mealHistoryKcalEaten(int kcal) {
    return '$kcal kcal consommées';
  }

  @override
  String get homeHelpTitle => 'Que signifient ces chiffres ?';

  @override
  String get homeHelpBody =>
      'Les calories (kcal) mesurent l\'énergie contenue dans les aliments. Manger à peu près votre objectif quotidien vous aide à atteindre votre poids cible.\n\nLes protéines, les glucides et les lipides sont les trois nutriments qui apportent les calories. Les protéines aident à construire et réparer les muscles, les glucides vous donnent de l\'énergie, et les lipides soutiennent votre corps de bien des façons.\n\nPas besoin d\'atteindre chaque chiffre exactement. Concentrez-vous d\'abord sur les calories, puis essayez de manger assez de protéines.';

  @override
  String get homeHelpGotIt => 'Compris';

  @override
  String get homeHelpTooltip => 'Que signifient ces chiffres ?';

  @override
  String get homeYourMealsHeading => 'Vos repas';

  @override
  String get homeSeePastDays => 'Voir les jours précédents';

  @override
  String get homeLoadErrorTitle => 'Impossible de charger les données du jour';

  @override
  String get homeTryAgain => 'Réessayer';

  @override
  String homeSemanticsEatenToday(int count) {
    return '$count calories consommées aujourd\'hui';
  }

  @override
  String homeSemanticsOverGoal(int count) {
    return '$count calories au-dessus de votre objectif aujourd\'hui';
  }

  @override
  String homeSemanticsLeftToday(int count) {
    return '$count calories restantes aujourd\'hui';
  }

  @override
  String get homeKcalEaten => 'kcal consommées';

  @override
  String get homeKcalOver => 'kcal en trop';

  @override
  String get homeKcalLeft => 'kcal restantes';

  @override
  String get homeSummaryGoal => 'Objectif';

  @override
  String get homeSummaryEaten => 'Consommé';

  @override
  String get homeSummaryExercise => 'Exercice';

  @override
  String homeSummaryLabelKcal(String label) {
    return '$label (kcal)';
  }

  @override
  String get homeFinishProfileForGoal =>
      'Complétez votre profil dans l\'onglet Moi pour obtenir un objectif calorique quotidien.';

  @override
  String get homeExerciseAddedToGoal =>
      'L\'exercice du jour est déjà ajouté à votre objectif.';

  @override
  String homeNutrientOfGoal(int eaten, int goal) {
    return '$eaten sur $goal g';
  }

  @override
  String get homeNothingAddedYet => 'Rien d\'ajouté pour l\'instant';

  @override
  String homeFoodsAndMore(String names, int count) {
    return '$names et $count de plus';
  }

  @override
  String homeAddFoodToMeal(String meal) {
    return 'Ajouter un aliment au repas : $meal';
  }

  @override
  String get homeAddButton => 'Ajouter';

  @override
  String get profileLogoutTitle => 'Se déconnecter ?';

  @override
  String get profileLogoutConfirm =>
      'Voulez-vous vraiment vous déconnecter de votre compte ?';

  @override
  String get profileLogOut => 'Se déconnecter';

  @override
  String get profileChangePhotoTooltip => 'Changer la photo de profil';

  @override
  String get profileHowActive => 'Votre niveau d\'activité';

  @override
  String get profileYourGoal => 'Votre objectif';

  @override
  String get profileEditDetails => 'Modifier mes informations';

  @override
  String get profileWeightLog => 'Suivi du poids';

  @override
  String get profileTryAgain => 'Réessayer';

  @override
  String get notificationPromptTitle => 'Envie d\'un rappel ?';

  @override
  String get notificationPromptBody =>
      'Nous pouvons vous faire signe quand vous n\'avez pas enregistré de repas ou d\'entraînement, et vous prévenir quand vous débloquez un badge. Vous pouvez modifier cela à tout moment dans les Paramètres.';

  @override
  String get notificationPromptNotNow => 'Pas maintenant';

  @override
  String get notificationPromptTurnOn => 'Activer les rappels';

  @override
  String settingsCouldNotSave(String reason) {
    return 'Enregistrement impossible. $reason';
  }

  @override
  String settingsCouldNotDelete(String reason) {
    return 'Impossible de supprimer votre compte. $reason';
  }

  @override
  String get labelNotSet => 'Non renseigné';

  @override
  String get labelActivitySedentary => 'Plutôt assis';

  @override
  String get labelActivityLight => 'Légèrement actif';

  @override
  String get labelActivityModerate => 'Modérément actif';

  @override
  String get labelActivityActive => 'Actif';

  @override
  String get labelActivityVeryActive => 'Très actif';

  @override
  String get labelGoalWeightLoss => 'Perdre du poids';

  @override
  String get labelGoalMuscleGain => 'Prendre du muscle';

  @override
  String get labelGoalMaintenance => 'Garder mon poids';

  @override
  String get labelGenderMale => 'Homme';

  @override
  String get labelGenderFemale => 'Femme';

  @override
  String get labelMealBreakfast => 'Petit-déjeuner';

  @override
  String get labelMealLunch => 'Déjeuner';

  @override
  String get labelMealDinner => 'Dîner';

  @override
  String get labelMealSnacks => 'Collations';

  @override
  String get labelIntensityVigorous => 'Intense';

  @override
  String get labelIntensityModerate => 'Modérée';

  @override
  String get labelIntensityLight => 'Légère';

  @override
  String get errorTryAgain => 'Veuillez réessayer.';

  @override
  String get errorNoConnection =>
      'Impossible de joindre le serveur. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get errorSessionEnded =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get apiCheckDetails => 'Vérifiez vos informations et réessayez.';

  @override
  String get apiTooManyAttempts =>
      'Trop de tentatives. Patientez une minute et réessayez.';

  @override
  String get apiWrongCredentials =>
      'E-mail ou mot de passe incorrect. Veuillez réessayer.';

  @override
  String get apiAccountDeactivated => 'Ce compte a été désactivé.';

  @override
  String get apiInvalidEmail => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get apiResetCodeInvalid =>
      'Ce code est incorrect ou a expiré. Demandez-en un nouveau.';

  @override
  String achievementTargetMeals(int target) {
    return 'Enregistrer $target repas';
  }

  @override
  String achievementTargetStreak(int target) {
    return 'Garder une série de $target jours';
  }

  @override
  String achievementTargetCalories(int target) {
    return 'Atteindre $target calories';
  }

  @override
  String achievementTargetWorkouts(int target) {
    return 'Terminer $target séance(s)';
  }

  @override
  String achievementTargetCardio(int target) {
    return 'Terminer $target séance(s) de cardio';
  }

  @override
  String achievementTargetProgress(int target) {
    return 'Enregistrer $target mise(s) à jour de progrès';
  }

  @override
  String achievementTargetWeight(int target) {
    return 'Perdre $target kg';
  }

  @override
  String achievementTargetMuscle(int target) {
    return 'Prendre $target kg de muscle';
  }

  @override
  String achievementTargetTasks(int target) {
    return 'Terminer $target tâches';
  }

  @override
  String achievementTargetCaloriesK(String thousands) {
    return 'Atteindre ${thousands}k calories';
  }

  @override
  String get mealScanTooltip => 'Scanner votre repas avec la caméra';

  @override
  String get mealScanTitle => 'Votre repas';

  @override
  String get mealScanLooking => 'Pointez la caméra vers votre assiette';

  @override
  String mealScanItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aliments',
      one: '$count aliment',
    );
    return '$_temp0';
  }

  @override
  String mealScanKcal(int kcal) {
    return '$kcal kcal';
  }

  @override
  String get mealScanScanning => 'Analyse en cours';

  @override
  String get mealScanPaused => 'En pause';

  @override
  String get mealScanPause => 'Mettre l\'analyse en pause';

  @override
  String get mealScanRescan => 'Relancer l\'analyse';

  @override
  String get mealScanNoCamera =>
      'Impossible d\'ouvrir la caméra. Vérifiez que l\'application peut l\'utiliser dans les réglages du téléphone, ou ajoutez les aliments à la main ci-dessous.';

  @override
  String get mealScanUnsureHint =>
      'Les aliments marqués ? peuvent être erronés. Touchez-en un pour le vérifier.';

  @override
  String get mealScanAddItem => 'Ajouter un aliment';

  @override
  String mealScanLogTo(String meal) {
    return 'Ajouter au repas : $meal';
  }

  @override
  String mealScanLogged(int count, String meal, int kcal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aliments ajoutés au repas : $meal ($kcal kcal)',
      one: '$count aliment ajouté au repas : $meal ($kcal kcal)',
    );
    return '$_temp0';
  }

  @override
  String mealScanLogFailed(String error) {
    return 'Impossible d\'ajouter le repas. $error';
  }

  @override
  String mealScanRow(int grams, int kcal) {
    return '$grams g · $kcal kcal';
  }

  @override
  String mealScanRowUnsure(int grams) {
    return '$grams g · incertain, touchez pour vérifier';
  }

  @override
  String get mealScanChangeFood => 'Changer';

  @override
  String get mealScanRemove => 'Retirer';

  @override
  String get mealScanDone => 'Valider';

  @override
  String get mealScanUnavailable =>
      'L\'analyse des repas n\'est pas disponible pour le moment. Ajoutez les aliments à la main ci-dessous.';

  @override
  String get mealScanFailed =>
      'Impossible de joindre l\'analyse. Touchez le bouton d\'analyse pour réessayer.';

  @override
  String get storyCreate => 'Créer une story';

  @override
  String get storyChooseLayout => 'Choisissez une mise en page';

  @override
  String get storyChooseLayoutHint =>
      'Ensuite, ajoutez votre photo, puis déplacez et modifiez tout.';

  @override
  String get storyLayoutFullPhoto => 'Photo pleine';

  @override
  String get storyLayoutPhotoPanel => 'Photo + stats';

  @override
  String get storyTemplateBold => 'Impact';

  @override
  String get storyTemplateCentered => 'Centré';

  @override
  String get storyTemplateMinimal => 'Minimal';

  @override
  String get storyTemplatePanelBottom => 'Panneau en bas';

  @override
  String get storyTemplatePanelTop => 'Panneau en haut';

  @override
  String get storyTemplateCard => 'Carte';

  @override
  String get storyStatusCompleted => 'Séance terminée';

  @override
  String get storyStatusPlanned => 'Séance prévue';

  @override
  String get storyPlanCaption => 'Au programme';

  @override
  String get storyStatDuration => 'Durée';

  @override
  String get storyStatDurationEstimated => 'Durée estimée';

  @override
  String get storyStatCalories => 'kcal (estim.)';

  @override
  String get storyStatExercises => 'Exercices';

  @override
  String get storyStatSets => 'Séries';

  @override
  String get storyStatReps => 'Répétitions';

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
    return '+$count autres';
  }

  @override
  String get storyBrand => 'Fitness Tracker';

  @override
  String get storyNewText => 'Votre texte';

  @override
  String get storyToolPhoto => 'Photo';

  @override
  String get storyToolText => 'Texte';

  @override
  String get storyToolStats => 'Stats';

  @override
  String get storyToolStyle => 'Style';

  @override
  String get storyToolLayers => 'Calques';

  @override
  String get storyAddPhoto => 'Ajouter une photo';

  @override
  String get storyGallery => 'Galerie';

  @override
  String get storyReplacePhoto => 'Remplacer';

  @override
  String get storyCamera => 'Appareil photo';

  @override
  String get storyResetPhoto => 'Recentrer';

  @override
  String get storyPhotoHint =>
      'Pincez pour zoomer, glissez pour déplacer la photo';

  @override
  String get storyDim => 'Assombrir';

  @override
  String get storyGradient => 'Dégradé';

  @override
  String get storyAddText => 'Ajouter du texte';

  @override
  String get storyAddExercises => 'Ajouter les exercices';

  @override
  String get storyAddStats => 'Ajouter les statistiques';

  @override
  String get storyTextHint =>
      'Touchez un texte de la story pour le sélectionner, puis à nouveau pour le modifier.';

  @override
  String get storyEditText => 'Modifier le texte';

  @override
  String get storyApply => 'Appliquer';

  @override
  String get storyFontDisplay => 'Condensée';

  @override
  String get storyFontBody => 'Standard';

  @override
  String get storySize => 'Taille';

  @override
  String get storySpacing => 'Espacement';

  @override
  String get storyWeightRegular => 'Normal';

  @override
  String get storyWeightMedium => 'Moyen';

  @override
  String get storyWeightBold => 'Gras';

  @override
  String get storyWeightBlack => 'Noir';

  @override
  String get storyAlignStart => 'Aligner au début';

  @override
  String get storyAlignCenter => 'Centrer';

  @override
  String get storyAlignEnd => 'Aligner à la fin';

  @override
  String get storyColorWhite => 'Blanc';

  @override
  String get storyColorGray => 'Gris';

  @override
  String get storyColorAccent => 'Accent';

  @override
  String get storyColorDark => 'Noir';

  @override
  String get storyUppercase => 'Majuscules';

  @override
  String get storyShadow => 'Ombre';

  @override
  String get storyStatsNone =>
      'Cette séance n\'a aucune statistique à afficher.';

  @override
  String get storyStatsHint =>
      'Activez ou masquez les statistiques, et faites-les glisser pour les réordonner.';

  @override
  String get storyStatsHintPlanned =>
      'Ce sont les chiffres du programme, affichés sous « Au programme ». Activez-les ou masquez-les, et faites-les glisser pour les réordonner.';

  @override
  String get storyEstimate => 'estimation';

  @override
  String get storyAccent => 'Couleur d\'accent';

  @override
  String get storyBranding => 'Afficher le nom de l\'app';

  @override
  String get storyChangeLayout => 'Changer la mise en page';

  @override
  String get storyResetDesign => 'Réinitialiser';

  @override
  String get storyResetConfirmTitle => 'Réinitialiser la mise en page ?';

  @override
  String get storyResetConfirmBody =>
      'Les textes, statistiques et le style reviennent à la mise en page d\'origine. Votre photo est conservée.';

  @override
  String get storyReset => 'Réinitialiser';

  @override
  String get storyLayerStats => 'Statistiques';

  @override
  String get storyLayerBrand => 'Nom de l\'app';

  @override
  String get storyLayerEmpty => 'Texte vide';

  @override
  String get storyDuplicate => 'Dupliquer';

  @override
  String get storyDelete => 'Supprimer';

  @override
  String get storyLock => 'Verrouiller';

  @override
  String get storyUnlock => 'Déverrouiller';

  @override
  String get storyBringForward => 'Avancer';

  @override
  String get storySendBackward => 'Reculer';

  @override
  String get storyHide => 'Masquer';

  @override
  String get storyShow => 'Afficher';

  @override
  String get storyUndo => 'Annuler';

  @override
  String get storyRedo => 'Rétablir';

  @override
  String get storyPreview => 'Aperçu';

  @override
  String get storyClosePreview => 'Retour à l\'édition';

  @override
  String get storyNext => 'Suivant';

  @override
  String get storyDiscardTitle => 'Abandonner cette story ?';

  @override
  String get storyDiscardBody => 'Vos modifications seront perdues.';

  @override
  String get storyDiscard => 'Abandonner';

  @override
  String get storyKeepEditing => 'Continuer';

  @override
  String storyExportFailed(String error) {
    return 'Impossible de créer l\'image. $error';
  }

  @override
  String get storyExportTitle => 'Votre story';

  @override
  String get storySave => 'Enregistrer';

  @override
  String get storyShare => 'Partager';

  @override
  String get storyDone => 'Terminé';

  @override
  String get storySaved => 'Enregistrée dans votre galerie';

  @override
  String get storySaveDenied =>
      'Autorisez l\'accès aux photos dans les Réglages pour enregistrer votre story.';

  @override
  String storySaveFailed(String error) {
    return 'Impossible d\'enregistrer l\'image. $error';
  }

  @override
  String get storyNotEnoughSpace =>
      'Pas assez d\'espace de stockage pour enregistrer l\'image.';

  @override
  String storyShareFailed(String error) {
    return 'Impossible de partager l\'image. $error';
  }

  @override
  String get storyShareUnavailable =>
      'Le partage n\'est pas disponible sur cet appareil.';

  @override
  String get storyPhotoDenied =>
      'Autorisez l\'accès aux photos dans les Réglages pour choisir une photo.';

  @override
  String get storyCameraDenied =>
      'Autorisez l\'accès à l\'appareil photo dans les Réglages pour prendre une photo.';

  @override
  String get storyPhotoFailed =>
      'Impossible d\'ouvrir cette photo. Essayez-en une autre.';
}
