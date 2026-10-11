import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/friendly_error.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'main_shell.dart';
import '../l10n/app_localizations.dart';

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
  // Used instead of _heightController when entering feet and inches.
  final _heightFtController = TextEditingController();
  final _heightInController = TextEditingController();

  /// Lets people enter lb / ft-in. Values are always saved as kg / cm.
  bool _imperial = false;

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
    _heightFtController.dispose();
    _heightInController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  /// Weight in kg, whatever unit was typed.
  double get _weightKg {
    final w = _parse(_weightController) ?? 0;
    return _imperial ? w * 0.45359237 : w;
  }

  /// Height in cm, whatever unit was typed.
  double get _heightCm {
    if (!_imperial) return _parse(_heightController) ?? 0;
    final ft = _parse(_heightFtController) ?? 0;
    final inches = _parse(_heightInController) ?? 0;
    return (ft * 12 + inches) * 2.54;
  }

  void _setUnits(bool imperial) {
    if (imperial == _imperial) return;
    final kg = _weightKg;
    final cm = _heightCm;
    setState(() {
      _imperial = imperial;
      if (imperial) {
        _weightController.text = kg > 0 ? (kg / 0.45359237).round().toString() : '';
        final totalIn = cm / 2.54;
        _heightFtController.text = cm > 0 ? (totalIn ~/ 12).toString() : '';
        _heightInController.text = cm > 0 ? (totalIn % 12).round().toString() : '';
      } else {
        _weightController.text = kg > 0 ? kg.toStringAsFixed(1).replaceAll('.0', '') : '';
        _heightController.text = cm > 0 ? cm.round().toString() : '';
      }
    });
  }

  double get _bmi {
    final w = _weightKg;
    final h = _heightCm;
    if (h <= 0 || w <= 0) return 0;
    return w / ((h / 100) * (h / 100));
  }

  double get _bmr {
    final w = _weightKg;
    final h = _heightCm;
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
        'weight': double.parse(_weightKg.toStringAsFixed(1)),
        'height': double.parse(_heightCm.toStringAsFixed(1)),
        'gender': _gender,
        'activity_level': _activityLevel,
        'fitness_goal': _fitnessGoal,
      });
      if (!mounted) return;
      if (widget.isEditing) {
        // Back to the Me tab it was opened from, with the saved values.
        Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
        Navigator.pop(context);
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.onboardingSaveFailed(friendlyError(e)),
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
    final l10n = AppLocalizations.of(context)!;
    return _buildStepShell(
      title: l10n.onboardingStep1Title,
      subtitle: l10n.onboardingBodyStatsSubtitle,
      infoCard: _buildBmiCard(),
      content: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.onboardingUnitsMetric)),
                ButtonSegment(value: true, label: Text(l10n.onboardingUnitsImperial)),
              ],
              selected: {_imperial},
              onSelectionChanged: (v) => _setUnits(v.first),
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            key: const Key('age_field'),
            controller: _ageController,
            label: l10n.onboardingAgeLabel,
            hint: l10n.onboardingAgeHint,
            icon: Icons.cake_outlined,
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            key: const Key('weight_field'),
            controller: _weightController,
            label: _imperial ? l10n.onboardingWeightLbLabel : l10n.onboardingWeightLabel,
            hint: _imperial ? l10n.onboardingWeightLbHint : l10n.onboardingWeightHint,
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 12),
          if (_imperial)
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    key: const Key('height_ft_field'),
                    controller: _heightFtController,
                    label: l10n.onboardingHeightFtLabel,
                    hint: l10n.onboardingHeightFtHint,
                    icon: Icons.height,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    key: const Key('height_in_field'),
                    controller: _heightInController,
                    label: l10n.onboardingHeightInLabel,
                    hint: l10n.onboardingHeightInHint,
                    icon: Icons.straighten,
                  ),
                ),
              ],
            )
          else
            _buildNumberField(
              key: const Key('height_field'),
              controller: _heightController,
              label: l10n.onboardingHeightLabel,
              hint: l10n.onboardingHeightHint,
              icon: Icons.height,
            ),
        ],
      ),
      onNext: () {
        final age = int.tryParse(_ageController.text.trim());
        final weight = _weightKg;
        final height = _heightCm;
        if (age == null || age <= 0 || age > 120 ||
            weight <= 0 || weight > 500 ||
            height <= 0 || height > 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.onboardingFillStats),
            ),
          );
          return;
        }
        _nextPage();
      },
    );
  }

  Widget _buildBmiCard() {
    final l10n = AppLocalizations.of(context)!;
    final bmi = _bmi;
    String label;
    Color color;
    if (bmi <= 0) {
      label = l10n.onboardingBmiEnterStats;
      color = Theme.of(context).colorScheme.outlineVariant;
    } else if (bmi < 18.5) {
      label = l10n.onboardingBmiUnderweight;
      color = Colors.amber;
    } else if (bmi < 25) {
      label = l10n.onboardingBmiHealthy;
      color = Colors.green;
    } else if (bmi < 30) {
      label = l10n.onboardingBmiOverweight;
      color = Colors.orange;
    } else {
      label = l10n.onboardingBmiObese;
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
            l10n.onboardingBmiCardLabel,
            style: TextStyle(
              fontSize: 13,
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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final l10n = AppLocalizations.of(context)!;
    final bmr = _bmr;
    return _buildStepShell(
      title: l10n.onboardingStep2Title,
      subtitle: l10n.onboardingGenderSubtitle,
      infoCard: _buildInfoCard(
        gradient: [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
        child: Column(children: [
          Text(
            l10n.onboardingBmrCaption,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
          ),
          const SizedBox(height: 4),
          Text(
            bmr > 0 ? l10n.onboardingKcalValue(bmr.toStringAsFixed(0)) : '—',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
          ),
          Text(
            l10n.onboardingBmrFootnote,
            style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
          ),
        ]),
      ),
      content: Column(children: [
        _buildSelectCard(
          value: 'male',
          currentValue: _gender,
          label: l10n.onboardingGenderMaleLabel,
          description: '',
          emoji: '👨',
          onTap: () => setState(() => _gender = 'male'),
        ),
        _buildSelectCard(
          value: 'female',
          currentValue: _gender,
          label: l10n.onboardingGenderFemaleLabel,
          description: '',
          emoji: '👩',
          onTap: () => setState(() => _gender = 'female'),
        ),
      ]),
      onBack: _prevPage,
      onNext: _nextPage,
    );
  }

  Widget _buildStep3() {
    final l10n = AppLocalizations.of(context)!;
    final tdee = _tdee;
    final activities = [
      ('sedentary', '🛋️', l10n.onboardingActMostlySitting, l10n.onboardingActMostlySittingDesc),
      ('light', '🚶', l10n.onboardingActLightlyActive, l10n.onboardingActLightlyActiveDesc),
      ('Moderate', '🏃', l10n.onboardingActModeratelyActive, l10n.onboardingActModeratelyActiveDesc),
      ('active', '⚡', l10n.onboardingActivityActive, l10n.onboardingActActiveDesc),
      ('very_active', '🔥', l10n.onboardingActVeryActive, l10n.onboardingActVeryActiveDesc),
    ];
    return _buildStepShell(
      title: l10n.onboardingStep3Title,
      subtitle: l10n.onboardingStep3Subtitle,
      infoCard: _buildInfoCard(
        gradient: [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
        child: Column(children: [
          Text(
            l10n.onboardingTdeeCaption,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
          ),
          const SizedBox(height: 4),
          Text(
            tdee > 0 ? l10n.onboardingKcalPerDayValue(tdee.toStringAsFixed(0)) : '—',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
          ),
          Text(
            l10n.onboardingTdeeFootnote,
            style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
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
    final l10n = AppLocalizations.of(context)!;
    final target = _dailyTarget;
    final tdee = _tdee;
    final goals = [
      ('weight_loss', '🔥', l10n.onboardingGoalLoseWeightLabel, l10n.onboardingGoalLoseWeightDetail),
      ('muscle_gain', '💪', l10n.onboardingGoalBuildMuscleLabel, l10n.onboardingGoalBuildMuscleDetail),
      ('maintenance', '⚖️', l10n.onboardingGoalStayLabel, l10n.onboardingGoalStayDetail),
    ];
    final offset = _fitnessGoal == 'weight_loss'
        ? l10n.onboardingOffsetLose
        : _fitnessGoal == 'muscle_gain'
            ? l10n.onboardingOffsetGain
            : l10n.onboardingOffsetSame;
    return _buildStepShell(
      title: l10n.onboardingStep4Title,
      subtitle: l10n.onboardingStep4Subtitle,
      infoCard: _buildInfoCard(
        gradient: [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
        child: Column(children: [
          Text(
            l10n.onboardingDailyGoalCaption,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
          ),
          const SizedBox(height: 4),
          Text(
            target > 0 ? l10n.onboardingKcalValue(target.toStringAsFixed(0)) : '—',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
          ),
          if (tdee > 0)
            Text(
              offset,
              style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
              textAlign: TextAlign.center,
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
    final l10n = AppLocalizations.of(context)!;
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
                    child: Text(l10n.onboardingBack),
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
                          isFinal ? l10n.onboardingLetsGo : l10n.onboardingNext,
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
    return Semantics(
      button: true,
      selected: isSelected,
      label: description.isEmpty ? label : '$label. $description',
      excludeSemantics: true,
      child: GestureDetector(
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
      ),
    );
  }
}
