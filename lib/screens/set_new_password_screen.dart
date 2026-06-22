import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/constants.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _passwordValidator(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Password is required';
    }

    if (text.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[0-9]').hasMatch(text)) {
      return 'Password must include at least 1 number';
    }

    if (!RegExp(r'[!@#\$%^&*]').hasMatch(text)) {
      return 'Password must include at least 1 symbol';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Please confirm your password';
    }

    if (text != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _showMessage({required String message, required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: success
              ? Colors.green.shade700
              : Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final auth = context.read<AuthController>();

    final ok = await auth.resetPassword(
      email: widget.email,
      token: widget.token,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (!ok) {
      _showMessage(
        message: auth.error ?? 'Failed to reset password.',
        success: false,
      );
      return;
    }

    _showMessage(
      message: auth.successMessage ?? 'Password reset successfully.',
      success: true,
    );

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _backToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        elevation: 0,
        foregroundColor: AppConstants.primary,
        title: const Text(
          'Set New Password',
          style: TextStyle(
            color: AppConstants.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(22, 34, 22, 34),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secure Your Account',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.text,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Your new password must be different from previous passwords to ensure maximum security for your StaySelect bookings.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F4A4D),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const _SecureHeroCard(),

                    const SizedBox(height: 28),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'New Password',
                      hint: 'Enter new password',
                      obscureText: _hidePassword,
                      validator: _passwordValidator,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      hint: 'Re-enter new password',
                      obscureText: _hideConfirmPassword,
                      validator: _confirmPasswordValidator,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _hideConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const _PasswordRequirementCard(),

                    const SizedBox(height: 28),

                    PrimaryActionButton(
                      text: 'Reset Password',
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: auth.loading,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: TextButton.icon(
                        onPressed: auth.loading ? null : _backToLogin,
                        icon: const Icon(
                          Icons.login_rounded,
                          size: 18,
                          color: AppConstants.primary,
                        ),
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: AppConstants.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SecureHeroCard extends StatelessWidget {
  const _SecureHeroCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/security_banner.png',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF062E33),
                      Color(0xFF0A5F64),
                      Color(0xFFB8DEE2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              );
            },
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.28)),
          ),

          Positioned(
            left: 28,
            bottom: 26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: AppConstants.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'STAYSELECT SECURE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRequirementCard extends StatelessWidget {
  const _PasswordRequirementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE6F4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppConstants.primary,
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Password Strength Requirements',
                  style: TextStyle(
                    color: AppConstants.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          _RequirementRow(text: 'At least 8 characters'),
          SizedBox(height: 12),
          _RequirementRow(text: 'Includes 1 number'),
          SizedBox(height: 12),
          _RequirementRow(text: 'Includes 1 symbol (!@#\$%^&*)'),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String text;

  const _RequirementRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFF3F4A4D),
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF3F4A4D),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
