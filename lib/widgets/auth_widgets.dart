import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AuthHeroImage extends StatelessWidget {
  final String asset;
  final double height;
  final BorderRadius borderRadius;

  const AuthHeroImage({
    super.key,
    required this.asset,
    this.height = 250,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        asset,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: const LinearGradient(
              colors: [Color(0xFFDDEEF1), Color(0xFF91C5CB), Color(0xFF0A5F64)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF3F4A4D),
              fontSize: 16,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, color: const Color(0xFF7A8588), size: 30),
            suffixIcon: suffixIcon,
            hintStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppConstants.text),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFBAC6C8), width: 1.4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFBAC6C8), width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppConstants.primary, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final bool loading;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.trailingIcon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primary,
          disabledBackgroundColor: AppConstants.primary.withOpacity(.55),
          elevation: 7,
          shadowColor: AppConstants.primary.withOpacity(.25),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 14),
                    Icon(trailingIcon, color: Colors.white, size: 28),
                  ],
                ],
              ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider({super.key, this.text = 'OR CONTINUE\nWITH'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppConstants.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7A8588), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: .5),
          ),
        ),
        const Expanded(child: Divider(color: AppConstants.border)),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 62,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F4FC),
            side: const BorderSide(color: Color(0xFFD2D9E8), width: 1.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: AppConstants.text, fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

String? requiredValidator(String? value, String field) {
  if (value == null || value.trim().isEmpty) return '$field is required';
  return null;
}

String? emailValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Email is required';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  return ok ? null : 'Enter a valid email';
}
