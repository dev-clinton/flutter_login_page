import 'package:flutter/material.dart';

import '../theme/cee_theme.dart';

class CeeLogo extends StatelessWidget {
  const CeeLogo({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/cee_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'CEE logo',
    );
  }
}

class CeeTextField extends StatelessWidget {
  const CeeTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixTap,
                icon: Icon(suffixIcon),
                color: CeeTheme.secondaryText,
              ),
      ),
    );
  }
}

class CeePrimaryButton extends StatelessWidget {
  const CeePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CeeTheme.accent,
          foregroundColor: const Color(0xFF10110E),
          disabledBackgroundColor: CeeTheme.accent.withValues(alpha: 0.55),
          disabledForegroundColor: const Color(0xFF10110E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Color(0xFF10110E),
                ),
              )
            : Text(label),
      ),
    );
  }
}

class CeeScreenHeading extends StatelessWidget {
  const CeeScreenHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CeeTheme.secondaryText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
