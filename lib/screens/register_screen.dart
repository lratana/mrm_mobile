import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/constants.dart';
import '../widgets/auth_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _accepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    final auth = context.read<AuthController>();

    if (auth.loading) return;

    if (!_accepted) {
      _showMessage(
        message: 'Please agree to the Terms and Conditions.',
        success: false,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final ok = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!ok) {
      _showMessage(
        message: auth.error ?? 'Registration failed.',
        success: false,
      );
      return;
    }

    _showMessage(
      message: auth.successMessage ?? 'Account created successfully.',
      success: true,
    );

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  void _goToLogin() {
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
          'Sign Up',
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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.text,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Sign up for a new membership',
                      style: TextStyle(fontSize: 16, color: Color(0xFF3F4A4D)),
                    ),

                    const SizedBox(height: 28),

                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Name',
                      validator: (v) => requiredValidator(v, 'Full name'),
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: emailValidator,
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+855 000-0000',
                      keyboardType: TextInputType.phone,
                      validator: (v) => requiredValidator(v, 'Phone number'),
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: _hidePassword,
                      validator: (value) {
                        final text = value ?? '';

                        if (text.isEmpty) {
                          return 'Password is required';
                        }

                        if (text.length < 8) {
                          return 'Password must be at least 8 characters';
                        }

                        return null;
                      },
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
                          color: const Color(0xFF7A8588),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: Checkbox(
                            value: _accepted,
                            activeColor: AppConstants.primary,
                            onChanged: auth.loading
                                ? null
                                : (value) {
                                    setState(() {
                                      _accepted = value ?? false;
                                    });
                                  },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color(0xFF3F4A4D),
                                fontSize: 16,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: AppConstants.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(text: ' and\n'),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: AppConstants.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    PrimaryActionButton(
                      text: 'Sign Up',
                      loading: auth.loading,
                      onPressed: _submit,
                    ),

                    const SizedBox(height: 28),

                    const OrDivider(text: 'OR Sign In'),

                    const SizedBox(height: 62),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF3F4A4D),
                            ),
                          ),
                          GestureDetector(
                            onTap: auth.loading ? null : _goToLogin,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppConstants.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
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
