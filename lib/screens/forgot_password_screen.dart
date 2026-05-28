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

    final ok = await context.read<AuthController>().forgotPassword(_emailController.text.trim());
    if (!mounted) return;
    final auth = context.read<AuthController>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? (auth.successMessage ?? 'Reset link sent') : (auth.error ?? 'Failed to send reset link'))),
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
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 22, 40, 36),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppConstants.primary, size: 34),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 112),
                    const AuthHeroImage(asset: AppConstants.resetHeroAsset, height: 392),
                    const SizedBox(height: 84),
                    const Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: AppConstants.text),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enter your email to receive a password\nreset link',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, color: Color(0xFF252A31), height: 1.25),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 25, offset: const Offset(0, 16))],
                      ),
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Email',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: emailValidator,
                          ),
                          const SizedBox(height: 30),
                          PrimaryActionButton(
                            text: 'Send Link',
                            trailingIcon: Icons.send,
                            loading: auth.loading,
                            onPressed: _sendLink,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    TextButton.icon(
                      onPressed: _backToLogin,
                      icon: const Icon(Icons.login, color: AppConstants.primary, size: 34),
                      label: const Text('Back to Login', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppConstants.primary)),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text(
                        "Don't have an account? Register a new\nmembership",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppConstants.primary, height: 1.3),
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
