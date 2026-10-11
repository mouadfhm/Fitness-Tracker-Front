import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'widgets/app_text_field.dart';
import '../utils/friendly_error.dart';
import '../l10n/app_localizations.dart';

/// "Forgot password": ask for the email, then for the 6-digit code it
/// receives and a new password. Pops back to login on success.
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(Object e, String Function(AppLocalizations l10n) fallback) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendlyError(e, fallback: fallback(AppLocalizations.of(context)!))),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _sendCode() async {
    // When resending, the email was already checked and the code fields
    // below may be empty, so don't validate the form again.
    if (!_codeSent && !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _codeSent = true);
    } catch (e) {
      _showError(e, (l10n) => l10n.forgotPasswordSendFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.resetPassword(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.forgotPasswordChanged)),
      );
      Navigator.pop(context, _emailController.text.trim());
    } catch (e) {
      _showError(e, (l10n) => l10n.forgotPasswordChangeFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    _codeSent
                        ? l10n.forgotPasswordCodeSentIntro(_emailController.text.trim())
                        : l10n.forgotPasswordIntro,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!_codeSent)
                    AppTextField(
                      controller: _emailController,
                      labelText: l10n.emailLabel,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return l10n.emailRequired;
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return l10n.emailInvalid;
                        }
                        return null;
                      },
                    )
                  else ...[
                    AppTextField(
                      controller: _codeController,
                      labelText: l10n.forgotPasswordCodeLabel,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().length != 6) {
                          return l10n.forgotPasswordCodeInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      labelText: l10n.forgotPasswordNewPasswordLabel,
                      obscureText: _obscurePassword,
                      showObscureToggle: _obscurePassword,
                      onObscureToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (value) {
                        if (value == null || value.isEmpty) return l10n.registerPasswordRequired;
                        if (value.length < 8) return l10n.passwordTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmPasswordController,
                      labelText: l10n.forgotPasswordConfirmNewPasswordLabel,
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
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : (_codeSent ? _resetPassword : _sendCode),
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
                            _codeSent ? l10n.forgotPasswordChangeButton : l10n.forgotPasswordSendCode,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _sendCode,
                      child: Text(l10n.forgotPasswordResend),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
