import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final bool isEditing;

  const OnboardingScreen({
    super.key,
    this.initialData = const {},
    this.isEditing = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'Moderate';
  String _fitnessGoal = 'weight_loss';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData.isNotEmpty) {
      _ageController.text = widget.initialData['age']?.toString() ?? '';
      _weightController.text = widget.initialData['weight']?.toString() ?? '';
      _heightController.text = widget.initialData['height']?.toString() ?? '';
      const validGenders = ['male', 'female'];
      const validActivities = ['sedentary', 'light', 'Moderate', 'active', 'very_active'];
      const validGoals = ['weight_loss', 'muscle_gain', 'maintenance'];
      final g = widget.initialData['gender'];
      final a = widget.initialData['activity_level'];
      final go = widget.initialData['fitness_goal'];
      if (validGenders.contains(g)) _gender = g;
      if (validActivities.contains(a)) _activityLevel = a;
      if (validGoals.contains(go)) _fitnessGoal = go;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  double get _bmi {
    final w = double.tryParse(_weightController.text) ?? 0;
    final h = double.tryParse(_heightController.text) ?? 0;
    if (h <= 0 || w <= 0) return 0;
    return w / ((h / 100) * (h / 100));
  }

  double get _bmr {
    final w = double.tryParse(_weightController.text) ?? 0;
    final h = double.tryParse(_heightController.text) ?? 0;
    final a = double.tryParse(_ageController.text) ?? 0;
    if (w <= 0 || h <= 0 || a <= 0) return 0;
    return _gender == 'male'
        ? (10 * w) + (6.25 * h) - (5 * a) + 5
        : (10 * w) + (6.25 * h) - (5 * a) - 161;
  }

  double get _activityMultiplier {
    const map = {
      'sedentary': 1.2,
      'light': 1.375,
      'Moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return map[_activityLevel] ?? 1.55;
  }

  double get _tdee => _bmr * _activityMultiplier;

  double get _dailyTarget {
    switch (_fitnessGoal) {
      case 'weight_loss':
        return _tdee - 500;
      case 'muscle_gain':
        return _tdee + 300;
      default:
        return _tdee;
    }
  }

  void _nextPage() => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  void _prevPage() => _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().updateProfile({
        'age': int.tryParse(_ageController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
        'gender': _gender,
        'activity_level': _activityLevel,
        'fitness_goal': _fitnessGoal,
      });
      if (!mounted) return;
      if (widget.isEditing) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save profile. Please try again.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: i <= _currentPage ? colorScheme.primary : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepShell(
      title: 'Your body stats',
      subtitle: 'We use these to calculate your daily calorie needs',
      infoCard: _buildBmiCard(),
      content: Column(
        children: [
          _buildNumberField(
            key: const Key('age_field'),
            controller: _ageController,
            label: 'Age',
            hint: 'e.g. 25',
            icon: Icons.cake_outlined,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            key: const Key('weight_field'),
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'e.g. 70',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            key: const Key('height_field'),
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'e.g. 175',
            icon: Icons.height,
          ),
        ],
      ),
      onNext: () {
        final age = int.tryParse(_ageController.text.trim());
        final weight = double.tryParse(_weightController.text.trim());
        final height = double.tryParse(_heightController.text.trim());
        if (age == null || age <= 0 || age > 120 ||
            weight == null || weight <= 0 || weight > 500 ||
            height == null || height <= 0 || height > 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter valid age, weight, and height'),
            ),
          );
          return;
        }
        _nextPage();
      },
    );
  }

  Widget _buildBmiCard() {
    final bmi = _bmi;
    String label;
    Color color;
    if (bmi <= 0) {
      label = 'Enter your stats';
      color = Theme.of(context).colorScheme.outlineVariant;
    } else if (bmi < 18.5) {
      label = 'Underweight';
      color = Colors.amber;
    } else if (bmi < 25) {
      label = 'Healthy Range';
      color = Colors.green;
    } else if (bmi < 30) {
      label = 'Overweight';
      color = Colors.orange;
    } else {
      label = 'Obese';
      color = Colors.red;
    }

    return _buildInfoCard(
      gradient: [
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.secondaryContainer,
      ],
      child: Column(
        children: [
          Text(
            'BMI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bmi > 0 ? bmi.toStringAsFixed(1) : '—',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final bmr = _bmr;
    return _buildStepShell(
      title: "What's your gender?",
      subtitle: 'Affects your metabolic rate calculation',
      infoCard: _buildInfoCard(
        gradient: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
        child: Column(children: [
          const Text(
            'Estimated Daily Calories at Rest',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
          ),
          const SizedBox(height: 4),
          Text(
            bmr > 0 ? '${bmr.toStringAsFixed(0)} kcal' : '—',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
          ),
          const Text(
            'Basal Metabolic Rate',
            style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
          ),
        ]),
      ),
      content: Column(children: [
        _buildSelectCard(
          value: 'male',
          currentValue: _gender,
          label: 'Male',
          description: 'Higher BMR on average',
          emoji: '👨',
          onTap: () => setState(() => _gender = 'male'),
        ),
        _buildSelectCard(
          value: 'female',
          currentValue: _gender,
          label: 'Female',
          description: 'Lower BMR on average',
          emoji: '👩',
          onTap: () => setState(() => _gender = 'female'),
        ),
      ]),
      onBack: _prevPage,
      onNext: _nextPage,
    );
  }

  Widget _buildStep3() {
    final tdee = _tdee;
    final activities = [
      ('sedentary', '🛋️', 'Sedentary', 'Desk job, little to no exercise'),
      ('light', '🚶', 'Light', 'Light exercise 1–3 days/week'),
      ('Moderate', '🏃', 'Moderate', 'Exercise 3–5 days/week'),
      ('active', '⚡', 'Active', 'Hard exercise 6–7 days/week'),
      ('very_active', '🔥', 'Very Active', 'Physical job or 2× daily training'),
    ];
    return _buildStepShell(
      title: 'How active are you?',
      subtitle: 'Pick what describes a typical week for you',
      infoCard: _buildInfoCard(
        gradient: [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
        child: Column(children: [
          const Text(
            'Total Daily Energy Expenditure',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
          ),
          const SizedBox(height: 4),
          Text(
            tdee > 0 ? '${tdee.toStringAsFixed(0)} kcal/day' : '—',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
          ),
          Text(
            '×${_activityMultiplier.toStringAsFixed(2)} activity multiplier',
            style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
          ),
        ]),
      ),
      content: Column(
        children: activities
            .map((a) => _buildSelectCard(
                  value: a.$1,
                  currentValue: _activityLevel,
                  label: a.$3,
                  description: a.$4,
                  emoji: a.$2,
                  onTap: () => setState(() => _activityLevel = a.$1),
                ))
            .toList(),
      ),
      onBack: _prevPage,
      onNext: _nextPage,
    );
  }

  Widget _buildStep4() {
    final target = _dailyTarget;
    final tdee = _tdee;
    final goals = [
      ('weight_loss', '🔥', 'Lose Weight', '500 kcal daily deficit'),
      ('muscle_gain', '💪', 'Build Muscle', '+300 kcal daily surplus'),
      ('maintenance', '⚖️', 'Stay Fit', 'Maintain current weight'),
    ];
    final offset = _fitnessGoal == 'weight_loss'
        ? '−500'
        : _fitnessGoal == 'muscle_gain'
            ? '+300'
            : '±0';
    return _buildStepShell(
      title: "What's your goal?",
      subtitle: "We'll adjust your daily target accordingly",
      infoCard: _buildInfoCard(
        gradient: [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
        child: Column(children: [
          const Text(
            'Your Daily Calorie Target',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
          ),
          const SizedBox(height: 4),
          Text(
            target > 0 ? '${target.toStringAsFixed(0)} kcal' : '—',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
          ),
          if (tdee > 0)
            Text(
              '$offset kcal from your TDEE',
              style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
            ),
        ]),
      ),
      content: Column(
        children: goals
            .map((g) => _buildSelectCard(
                  value: g.$1,
                  currentValue: _fitnessGoal,
                  label: g.$3,
                  description: g.$4,
                  emoji: g.$2,
                  onTap: () => setState(() => _fitnessGoal = g.$1),
                ))
            .toList(),
      ),
      onBack: _prevPage,
      onNext: _submit,
      isFinal: true,
    );
  }

  Widget _buildStepShell({
    required String title,
    required String subtitle,
    required Widget infoCard,
    required Widget content,
    required VoidCallback onNext,
    VoidCallback? onBack,
    bool isFinal = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          infoCard,
          const SizedBox(height: 20),
          content,
          const SizedBox(height: 28),
          Row(
            children: [
              if (onBack != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFinal ? Colors.green : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading && isFinal
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                        )
                      : Text(
                          isFinal ? "Let's Go!" : 'Next',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Color> gradient, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [child]),
    );
  }

  Widget _buildNumberField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSelectCard({
    required String value,
    required String currentValue,
    required String label,
    required String description,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final isSelected = value == currentValue;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
