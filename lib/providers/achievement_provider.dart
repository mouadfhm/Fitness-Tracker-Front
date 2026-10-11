import 'package:flutter/material.dart';
import '../utils/friendly_error.dart';
import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../utils/l10n.dart';
import 'package:intl/intl.dart';

class AchievementsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _achievements = [];
  Map<int, dynamic> _userAchievements = {};
  bool _isLoading = false;
  String? _error;

  List<dynamic> get achievements => _achievements;
  Map<int, dynamic> get userAchievements => _userAchievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isAchievementUnlocked(int achievementId) => _userAchievements.containsKey(achievementId);

  Future<void> loadAchievements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allAchievements = await _apiService.getAchievements();
      final userAchievements = await _apiService.getUserAchievements();

      _achievements = allAchievements;
      _userAchievements = {for (var achievement in userAchievements) achievement['achievement_id']: achievement};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = friendlyError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadAchievements() async => loadAchievements();

  Color getColorForType(String type) {
    switch (type) {
      case 'meals':
        return Colors.green;
      case 'streak':
        return Colors.orange;
      case 'calories':
        return Colors.red;
      case 'workouts':
        return Colors.blue;
      case 'cardio':
        return Colors.purple;
      case 'progress':
        return Colors.teal;
      case 'weight':
        return Colors.indigo;
      case 'muscle':
        return Colors.brown;
      default:
        return Colors.amber;
    }
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'meals':
        return Icons.restaurant;
      case 'streak':
        return Icons.local_fire_department;
      case 'calories':
        return Icons.monitor_weight;
      case 'workouts':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'progress':
        return Icons.trending_up;
      case 'weight':
        return Icons.scale;
      case 'muscle':
        return Icons.sports_gymnastics;
      default:
        return Icons.emoji_events;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM y', LocaleService.languageCode).format(date);
    } catch (e) {
      return dateString.substring(0, 10); // Fallback to simple substring
    }
  }

  String getTargetDescription(String type, int target) {
    final l = appL10n;
    switch (type) {
      case 'meals':
        return l.achievementTargetMeals(target);
      case 'streak':
        return l.achievementTargetStreak(target);
      case 'calories':
        return target > 1000
            ? l.achievementTargetCaloriesK('${target / 1000}')
            : l.achievementTargetCalories(target);
      case 'workouts':
        return l.achievementTargetWorkouts(target);
      case 'cardio':
        return l.achievementTargetCardio(target);
      case 'progress':
        return l.achievementTargetProgress(target);
      case 'weight':
        return l.achievementTargetWeight(target);
      case 'muscle':
        return l.achievementTargetMuscle(target);
      default:
        return l.achievementTargetTasks(target);
    }
  }
}
