import 'dart:convert';

class WorkoutImportFormatException implements Exception {
  final String message;
  WorkoutImportFormatException(this.message);

  @override
  String toString() => message;
}

class WorkoutImportService {
  static const int supportedVersion = 1;

  static Map<String, dynamic> parseWorkoutImportJson(String jsonString) {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw WorkoutImportFormatException('That file is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw WorkoutImportFormatException('That file is not a workout program export.');
    }

    final type = decoded['type'];
    if (type != 'workout' && type != 'workout_cycle') {
      throw WorkoutImportFormatException('That file is not a workout program export.');
    }

    if (decoded['version'] != supportedVersion) {
      throw WorkoutImportFormatException(
        'This file was exported by a version of the app this import cannot read.',
      );
    }

    return decoded;
  }
}
