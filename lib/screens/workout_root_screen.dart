import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_screen.dart';
import 'workout/workout_calendar_screen.dart';

class WorkoutRootScreen extends StatefulWidget {
  const WorkoutRootScreen({super.key});

  @override
  State<WorkoutRootScreen> createState() => _WorkoutRootScreenState();
}

class _WorkoutRootScreenState extends State<WorkoutRootScreen> {
  bool _isSimple = true;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('workout_mode') ?? 'simple';
    if (mounted) {
      setState(() {
        _isSimple = mode == 'simple';
        _ready = true;
      });
    }
  }

  Future<void> _toggleMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = _isSimple ? 'advanced' : 'simple';
    await prefs.setString('workout_mode', newMode);
    if (mounted) setState(() => _isSimple = !_isSimple);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isSimple
        ? WorkoutScreen(onModeToggle: _toggleMode)
        : WorkoutCalendarScreen(onModeToggle: _toggleMode);
  }
}
