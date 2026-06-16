import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/constants.dart';
import '../widgets/auth_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();

    final ok = await auth.forgotPassword(_emailController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ok
                      ? auth.successMessage ?? 'Reset link sent successfully'
                      : auth.error ?? 'Failed to send reset link',
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

  void _backToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallHeight = constraints.maxHeight < 740;
                final horizontalPadding = constraints.maxWidth > 420
                    ? 32.0
                    : 20.0;

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        22,
                      ),
                      child: Column(
                        children: [
                          _TopBackBar(onBack: _backToLogin),

                          SizedBox(height: isSmallHeight ? 14 : 22),

                          const _ForgotPasswordHeader(),

                          SizedBox(height: isSmallHeight ? 22 : 30),

                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 430),
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFE8EFF1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reset your password',
                                    style: TextStyle(
                                      fontSize: 22,
                                      height: 1.12,
                                      fontWeight: FontWeight.w900,
                                      color: AppConstants.text,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  const Text(
                                    'Enter your registered email address. We will send you a password reset link.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A8588),
                                    ),
                                  ),

                                  const SizedBox(height: 22),

                                  AuthTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'Enter your email',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: emailValidator,
                                  ),

                                  const SizedBox(height: 18),

                                  PrimaryActionButton(
                                    text: 'Send Reset Link',
                                    trailingIcon: Icons.send_rounded,
                                    loading: auth.loading,
                                    onPressed: _sendLink,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          TextButton.icon(
                            onPressed: _backToLogin,
                            icon: const Icon(
                              Icons.login_rounded,
                              color: AppConstants.primary,
                              size: 18,
                            ),
                            label: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppConstants.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3F4A4D),
                                ),
                              ),
                              GestureDetector(
                                onTap: _goToRegister,
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppConstants.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TopBackBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBackBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1EAEC)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppConstants.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
  const _ForgotPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppConstants.primary.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primary.withOpacity(0.14),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 46,
            color: AppConstants.primary,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            height: 1.08,
            letterSpacing: -0.4,
            fontWeight: FontWeight.w900,
            color: AppConstants.text,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'No worries, we will help you reset it',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6F7A7D),
          ),
        ),
      ],
    );
  }
}
