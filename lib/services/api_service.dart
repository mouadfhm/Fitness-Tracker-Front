import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'token_service.dart';
import 'navigation_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['BASE_URL']!;
  final storage = FlutterSecureStorage();

  void _redirectToLogin() {
    TokenService.deleteToken();
    // Use addPostFrameCallback so this works even during app startup
    // before the navigator is attached.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NavigationService.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (_) => false);
    });
  }

  /// Returns the stored token, or redirects to login and throws if missing.
  Future<String> _requireToken() async {
    final String? token = await TokenService.getToken();
    if (token == null) {
      _redirectToLogin();
      throw Exception('No authentication token. Please log in.');
    }
    return token;
  }

  /// Throws a clean error if the response body is HTML (misconfigured server/wrong URL).
  void _checkNotHtml(http.Response response) {
    final ct = response.headers['content-type'] ?? '';
    if (ct.contains('text/html') || response.body.trimLeft().startsWith('<!DOCTYPE')) {
      throw Exception(
        'Server returned an unexpected page (HTTP ${response.statusCode}). '
        'Check that BASE_URL in your .env file points to the API root, not the web root.',
      );
    }
  }

  /// Checks for a 401 Unauthorized response and redirects to login.
  /// Also catches HTML responses from a misconfigured server URL.
  void _checkUnauthorized(http.Response response) {
    _checkNotHtml(response);
    if (response.statusCode == 401) {
      _redirectToLogin();
      throw Exception('Session expired. Please log in again.');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": confirmPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Save token using TokenService
      if (data.containsKey('access_token')) {
        await TokenService.saveToken(data['access_token']);
      }
      return data;
    } else {
      throw Exception("Failed to register: ${response.body}");
    }
  }

  // POST request for login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save token using TokenService
      if (data.containsKey('access_token')) {
        await TokenService.saveToken(data['access_token']);
      }
      return data;
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }

  /// Optional: clear token on logout
  Future<void> logout() async {
    await TokenService.deleteToken();
  }

  Future<void> registerFcmToken(String token) async {
    try {
      final authToken = await _requireToken();
      final timezone = await _deviceTimezone();
      final response = await http.post(
        Uri.parse("$baseUrl/save-device-token"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          "device_token": token,
          // Rides along on token registration rather than getting an endpoint
          // of its own: this call already happens on login and on every token
          // refresh, which are exactly the moments the timezone can have
          // changed. The backend validates it and ignores anything it does not
          // recognise, so a bad value costs the reminder schedule nothing.
          if (timezone != null) "timezone": timezone,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'FCM token registration rejected (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  /// The device's IANA timezone, e.g. `Europe/Paris`, or null if the platform
  /// will not say.
  ///
  /// Null is a normal answer here, not an error: the backend falls back to
  /// Africa/Casablanca for users it has no timezone for, which is exactly what
  /// every user got before this existed. Failing to read it must never cost the
  /// device its push token, so it is caught here rather than left to abort the
  /// registration above.
  Future<String?> _deviceTimezone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return info.identifier;
    } catch (e) {
      debugPrint('Could not read device timezone: $e');
      return null;
    }
  }

  /// Reports that the user tapped the notification logged as [logId].
  ///
  /// Fire-and-forget: open tracking is analytics, so a failure here must never
  /// surface to the user or block the screen the tap is opening.
  Future<void> markNotificationOpened(String logId) async {
    try {
      final authToken = await _requireToken();
      final response = await http.post(
        Uri.parse("$baseUrl/notifications/$logId/opened"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Notification open report rejected (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Notification open report failed: $e');
    }
  }

  /// The user's notification settings as the server holds them.
  ///
  /// Server-side rather than in shared_preferences, and not only so the choices
  /// survive a logout or a reinstall: the sender is the backend, so a toggle it
  /// cannot see stops nothing. A local-only switch would look like it worked
  /// and change no behaviour at all.
  ///
  /// A user who has never saved gets the defaults back rather than a 404, so
  /// there is no empty state to handle here.
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/notification-preferences'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load notification settings: ${response.body}');
    }
  }

  /// Saves only the keys present in [changes]; anything omitted is left alone.
  ///
  /// Partial on purpose — flipping one switch should not resend, and so risk
  /// overwriting, the five settings the user did not touch. Sending
  /// `quiet_from` and `quiet_to` as null is how quiet hours are switched off.
  ///
  /// Returns the full saved settings, so the caller can adopt the server's
  /// version of the truth rather than assume its own optimistic one stuck.
  Future<Map<String, dynamic>> updateNotificationPreferences(
    Map<String, dynamic> changes,
  ) async {
    final token = await _requireToken();
    final response = await http.put(
      Uri.parse('$baseUrl/notification-preferences'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(changes),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to save notification settings: ${response.body}');
    }
  }

// delete account
  Future<void> deleteAccount() async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/profile"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      await TokenService.deleteToken();
    }
  }

  // Example: GET profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }

  // update profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await _requireToken();

    final response = await http.put(
      Uri.parse('$baseUrl/profile'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  //Update goal
  Future<Map<String, dynamic>> updateGoal(Map<String, dynamic> data) async {
    final token = await _requireToken();

    final response = await http.post(
      Uri.parse('$baseUrl/goals/'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store goal: ${response.body}');
    }
  }

  // get Goal
  Future<Map<String, dynamic>> getGoal() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/goals/search'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get goal: ${response.body}');
    }
  }

  // get Macros
  Future<Map<String, dynamic>> getMacros() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/meals/macros'), // Adjust the endpoint if needed
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get meals: ${response.body}');
    }
  }

  //get calories burned
  Future<double> getCalories(String date) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workouts/calories-burned'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'workout_date': date}),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      // Parse the direct number response
      final dynamic decodedResponse = jsonDecode(response.body);
      // Convert to double, regardless of whether it's returned as int or double
      return (decodedResponse as num).toDouble();
    } else {
      throw Exception('Failed to get calories: ${response.body}');
    }
  }

  // get foods
  Future<List<dynamic>> getFoods() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/foods/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load foods');
    }
  }

  // add food
  Future<Map<String, dynamic>> addFood(
    String name,
    double calories,
    double protein,
    double carbs,
    double fat,
  ) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/foods/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'protein': protein,
        'carbs': carbs,
        'fats': fat,
        'calories': calories,
      }),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add food: ${response.body}');
    }
  }

  // add favorite food
  Future<Map<String, dynamic>> addFavoriteFood(int foodId) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/foods/favorite/$foodId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add favorite food: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> removeFavoriteFood(int foodId) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/foods/remove-favorite/$foodId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add favorite food: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> storeMeal(
    String name,
    double quantity,
    String? mealTime,
    String date,
  ) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/meals/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'date': date,
        'meal_time': mealTime,
        'foods': [
          {'name': name, 'quantity': quantity},
        ],
      }),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store meal: ${response.body}');
    }
  }

  Future<List<dynamic>> getMeals() async {
    final token = await _requireToken();
    // If a date is provided, you can include it as a query parameter for filtering.
    final uri = Uri.parse('$baseUrl/meals/search');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load meals by date');
    }
  }

  //updateFoodInMeal
  Future<Map<String, dynamic>> updateFoodInMeal(
    int mealId,
    DateTime date,
    String mealTime,
    int foodId,
    double quantity,
  ) async {
    final token = await _requireToken();
    final response = await http.put(
      Uri.parse('$baseUrl/meals/$mealId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'meal_time': mealTime,
        'date': date,
        'foods': [
          {'food_id': foodId, 'quantity': quantity},
        ],
      }),
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update food in meal: ${response.body}');
    }
  }

  // removeFoodFromMeal
  Future<Map<String, dynamic>> removeFoodFromMeal(int mealId) async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/meals/$mealId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to remove food from meal: ${response.body}');
    }
  }

  //get exercice
  Future<List<dynamic>> getExercices() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workouts/exercises'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  //store workout
  Future<Map<String, dynamic>> storeWorkout(
    String activityType,
    int duration,
    String date,
  ) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workouts/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'workout_date': date,
        'activity_type': activityType,
        'duration': duration,
      }),
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store workout: ${response.body}');
    }
  }

  // Fetch progress entries
  Future<List<dynamic>> getProgress() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/progress'),
      headers: {'Authorization': 'Bearer $token'},
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      return decoded['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load progress: ${response.body}');
    }
  }

  // Add a progress entry
  Future<void> addProgress(String date, double weight) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/progress/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'date': date, 'weight': weight}),
    );

    _checkUnauthorized(response);
    if (response.statusCode != 201) {
      throw Exception('Failed to add progress: ${response.body}');
    }
  }

  Future<String?> getToken() async {
    return await TokenService.getToken();
  }

  //get achievements
  Future<List<dynamic>> getAchievements() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/achievements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load achievements: ${response.body}');
    }
  }

  Future<List<dynamic>> getUserAchievements() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/achievements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load achievements: ${response.body}');
    }
  }

  Future<List<dynamic>> getGymExercises() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/exercises/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['gym_exercises'] as List<dynamic>;
    } else {
      throw Exception('Failed to load exercises: ${response.body}');
    }
  }

Future<Map<String, dynamic>> storeCustomWorkout(
  String name,
  String description,
  List<Map<String, dynamic>> gymExercises,
) async {
  final token = await TokenService.getToken();
  final response = await http.post(
    Uri.parse('$baseUrl/v2/workouts/custom-workouts'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': name,
      'description': description,
      'gym_exercises': gymExercises,
    }),
  );

  _checkUnauthorized(response);
  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to store custom workout: ${response.body}');
  }
}  // update customWorkout
  Future<Map<String, dynamic>> updateCustomWorkout(
    int workoutId,
    String name,
    String description,
    List<Map<String, dynamic>> gymExercises,
  ) async {
    final token = await _requireToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts/$workoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'gym_exercises': gymExercises,
      }),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update custom workout: ${response.body}');
    }
  }

  // delete customWorkout
  Future<void> deleteCustomWorkout(int workoutId) async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts/$workoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete custom workout: ${response.body}');
    }
  }

  // fetch customWorkout
  Future<Map<String, dynamic>> fetchCustomWorkout(int workoutId) async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts/$workoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // output:        {
    //     "id": 1,
    //     "user_id": 2,
    //     "name": "chest Workout",
    //     "description": "A custom workout routine focusing on chest and triceps.",
    //     "created_at": "2025-03-29T21:08:45.000000Z",
    //     "updated_at": "2025-03-29T21:08:45.000000Z",
    //     "gym_exercises": [
    //         {
    //             "id": 941,
    //             "name": "TBS Close-Grip Bench Press",
    //             "description": "The close-grip bench pressis a compound exercise targeting the triceps and chest. The main difference between this exercise and the standard bench press is that the hands and elbows are placed closer together.",
    //             "type": "Strength",
    //             "body_part": "Chest",
    //             "equipment": "Barbell",
    //             "level": "Intermediate",
    //             "created_at": "2025-03-29T21:08:14.000000Z",
    //             "updated_at": "2025-03-29T21:08:14.000000Z",
    //             "pivot": {
    //                 "custom_workout_id": 1,
    //                 "gym_exercise_id": 941,
    //                 "sets": 3,
    //                 "reps": 12,
    //                 "duration": null,
    //                 "rest": 60,
    //                 "created_at": "2025-03-29T21:08:45.000000Z",
    //                 "updated_at": "2025-03-29T21:08:45.000000Z"
    //             }
    //         },
    //         {
    //             "id": 2838,
    //             "name": "TBS Rope Cable Push-Down",
    //             "description": "The cable rope push-down is a popular exercise targeting the triceps muscles. It's easy to learn and perform, making it a favorite for everyone from beginners to advanced lifters. It is usually performed for moderate to high reps, such as 8-12 reps or more per set, as part of an upper-body or arm-focused workout.",
    //             "type": "Strength",
    //             "body_part": "Triceps",
    //             "equipment": "Cable",
    //             "level": "Intermediate",
    //             "created_at": "2025-03-29T21:08:35.000000Z",
    //             "updated_at": "2025-03-29T21:08:35.000000Z",
    //             "pivot": {
    //                 "custom_workout_id": 1,
    //                 "gym_exercise_id": 2838,
    //                 "sets": 4,
    //                 "reps": 10,
    //                 "duration": null,
    //                 "rest": 90,
    //                 "created_at": "2025-03-29T21:08:45.000000Z",
    //                 "updated_at": "2025-03-29T21:08:45.000000Z"
    //             }
    //         }
    //     ]
    // },
    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch custom workout: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchWorkout() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/custom-workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch custom workout: ${response.body}');
    }
  }

  // store schedule workout
  Future<Map<String, dynamic>> storeScheduleWorkout(
    int workoutId,
    String scheduledAt,
  ) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'workout_id': workoutId, 'scheduled_at': scheduledAt}),
    );
    // {
    //   "workout_id": 1,
    //   "scheduled_at": "2025-03-23 08:00:00"
    // }

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store schedule workout: ${response.body}');
    }
  }

  //update schedule workout
  Future<Map<String, dynamic>> updateScheduleWorkout(
    int scheduleWorkoutId,
    String scheduledAt,
  ) async {
    final token = await _requireToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'scheduled_at': scheduledAt}),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update schedule workout: ${response.body}');
    }
  }
// delete schedule workout
  Future<void> deleteScheduleWorkout(int scheduleWorkoutId) async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete schedule workout: ${response.body}');
    }
}
  //fetch schedule workout
  Future<Map<String, dynamic>> fetchScheduleWorkout(
    int scheduleWorkoutId,
  ) async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/scheduled-workouts/$scheduleWorkoutId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch schedule workout: ${response.body}');
    }
  }

  //store weekly workouts
  Future<Map<String, dynamic>> storeWeeklyWorkouts(
    String name,
    String startDate,
    int weeks,
    Map<String, int?> daysPattern, {
    String? description,
  }) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'start_date': startDate,
        'weeks': weeks,
        'days_pattern': daysPattern,
      }),
    );
    // {
    //   "start_date": "2025-03-30",
    //   "weeks": 4,
    //   "days_pattern": {
    //     "mon": 1,
    //     "tue": 2,
    //     "wed": null,
    //     "thu": 1,
    //     "fri": 2,
    //     "sat": null,
    //     "sun": null
    //   }
    // }

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store weekly workouts: ${response.body}');
    }
  }

  // fetch weekly workouts
  Future<Map<String, dynamic>> fetchWeeklyWorkouts() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // output:
    // "weeks": {
    //     "13": {
    //         "mon": [
    //             {
    //                 "id": 1,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-24 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "tue": [
    //             {
    //                 "id": 2,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-03-25 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "wed": [],
    //         "thu": [
    //             {
    //                 "id": 3,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-27 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "fri": [
    //             {
    //                 "id": 4,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-03-28 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "sat": [],
    //         "sun": []
    //     },
    //     "14": {
    //         "mon": [
    //             {
    //                 "id": 17,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-31 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 5,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-03-31 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "tue": [
    //             {
    //                 "id": 18,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-01 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 6,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-01 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "wed": [],
    //         "thu": [
    //             {
    //                 "id": 7,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-04-03 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 19,
    //                 "user_id": 2,
    //                 "workout_id": 1,
    //                 "scheduled_at": "2025-04-03 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 1,
    //                     "user_id": 2,
    //                     "name": "chest Workout",
    //                     "description": "A custom workout routine focusing on chest and triceps.",
    //                     "created_at": "2025-03-29T21:08:45.000000Z",
    //                     "updated_at": "2025-03-29T21:08:45.000000Z"
    //                 }
    //             }
    //         ],
    //         "fri": [
    //             {
    //                 "id": 20,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-04 00:00:00",
    //                 "created_at": "2025-03-29T22:03:55.000000Z",
    //                 "updated_at": "2025-03-29T22:03:55.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             },
    //             {
    //                 "id": 8,
    //                 "user_id": 2,
    //                 "workout_id": 2,
    //                 "scheduled_at": "2025-04-04 00:00:00",
    //                 "created_at": "2025-03-29T22:00:52.000000Z",
    //                 "updated_at": "2025-03-29T22:00:52.000000Z",
    //                 "workout": {
    //                     "id": 2,
    //                     "user_id": 2,
    //                     "name": "back Workout",
    //                     "description": "A custom workout routine focusing on back and biceps.",
    //                     "created_at": "2025-03-29T21:10:21.000000Z",
    //                     "updated_at": "2025-03-29T21:10:21.000000Z"
    //                 }
    //             }
    //         ],
    //         "sat": [],
    //         "sun": []
    //     },
    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weekly workouts: ${response.body}');
    }
  }

  // fetch saved cycle plans (reusable templates), separate from the
  // derived calendar view returned by fetchWeeklyWorkouts
  Future<List<dynamic>> fetchSavedCyclePlans() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans/saved'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['cycle_plans'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch saved cycle plans: ${response.body}');
    }
  }

  // delete a saved cycle plan
  Future<void> deleteCyclePlan(int id) async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkUnauthorized(response);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete cycle plan: ${response.body}');
    }
  }

  // reuse a saved cycle plan starting on a new date, without rebuilding
  // the day-by-day pattern
  Future<Map<String, dynamic>> reuseCyclePlan(
    int id,
    String startDate, {
    int? weeks,
  }) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v2/workouts/weekly-cycle-plans/$id/reuse'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'start_date': startDate,
        if (weeks != null) 'weeks': weeks,
      }),
    );

    _checkUnauthorized(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to reuse cycle plan: ${response.body}');
    }
  }
}
