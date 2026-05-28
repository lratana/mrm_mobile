import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (auth.initializing) {
          return const Scaffold(
            backgroundColor: AppConstants.bg,
            body: Center(child: CircularProgressIndicator(color: AppConstants.primary)),
          );
        }
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
