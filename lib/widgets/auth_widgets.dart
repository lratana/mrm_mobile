import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AuthHeroImage extends StatelessWidget {
  final String asset;
  final double height;
  final BorderRadius borderRadius;

  const AuthHeroImage({
    super.key,
    required this.asset,
    this.height = 220,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
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
              colors: [Color(0xFFE9F5F6), Color(0xFFB8DEE2), Color(0xFF0A5F64)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.meeting_room_rounded,
            size: 54,
            color: AppConstants.primary,
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
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF3F4A4D),
              fontSize: 13,
              height: 1.1,
            ),
          ),
        ),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            color: AppConstants.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: const Color(0xFF7A8588), size: 21),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 46,
              minHeight: 46,
            ),
            suffixIcon: suffixIcon,
            suffixIconColor: const Color(0xFF7A8588),
            hintStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF9AA5A8),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFD8E1E3),
                width: 1.1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFD8E1E3),
                width: 1.1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppConstants.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primary,
          disabledBackgroundColor: AppConstants.primary.withOpacity(.55),
          elevation: 4,
          shadowColor: AppConstants.primary.withOpacity(.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    Icon(trailingIcon, color: Colors.white, size: 21),
                  ],
                ],
              ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider({super.key, this.text = 'OR'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppConstants.border, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8A9699),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppConstants.border, thickness: 1),
        ),
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
        height: 50,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFF6F8FB),
            side: const BorderSide(color: Color(0xFFDDE4EA), width: 1.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 22, height: 22, child: Center(child: icon)),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppConstants.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? requiredValidator(String? value, String field) {
  if (value == null || value.trim().isEmpty) {
    return '$field is required';
  }
  return null;
}

String? emailValidator(String? value) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) {
    return 'Email is required';
  }

  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);

  return ok ? null : 'Enter a valid email';
}
