import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool? showObscureToggle;
  final VoidCallback? onObscureToggle;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.showObscureToggle,
    this.onObscureToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: colorScheme.onSurface),
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        suffixIcon: showObscureToggle != null
            ? IconButton(
                icon: Icon(
                  showObscureToggle! ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onObscureToggle,
              )
            : null,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return 'Please enter $labelText';
            return null;
          },
    );
  }
}
