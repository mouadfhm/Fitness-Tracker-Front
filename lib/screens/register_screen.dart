import 'package:flutter/material.dart';
import '../utils/privacy_policy.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import 'onboarding_screen.dart';
import 'widgets/app_text_field.dart';
import '../utils/friendly_error.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );
      setupFCM(_apiService);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyError(e, fallback: AppLocalizations.of(context)!.registerCouldNotCreate),
              style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.registerHeading,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.registerSubtitle,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _nameController,
                    labelText: l10n.fullNameLabel,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.fullNameRequired;
                      if (value.length < 2) return l10n.fullNameTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    labelText: l10n.emailLabel,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.emailRequired;
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value)) return l10n.emailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: l10n.passwordLabel,
                    obscureText: _obscurePassword,
                    showObscureToggle: _obscurePassword,
                    onObscureToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.registerPasswordRequired;
                      if (value.length < 8) return l10n.passwordTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    labelText: l10n.confirmPasswordLabel,
                    obscureText: _obscureConfirmPassword,
                    showObscureToggle: _obscureConfirmPassword,
                    onObscureToggle: () =>
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.confirmPasswordRequired;
                      if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : Text(
                            l10n.registerTitle,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  if (privacyPolicyUrl() != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => openPrivacyPolicy(context),
                      child: Text(
                        l10n.registerPrivacyAgreement,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l10n.loginLogIn,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
