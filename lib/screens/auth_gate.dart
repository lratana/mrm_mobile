import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/check_network.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _notificationPollingRunning = false;
  bool _syncScheduled = false;

  void _syncNotificationState({
    required bool isAuthenticated,
    required bool isOnline,
  }) {
    if (_syncScheduled) return;

    final shouldStart =
        isAuthenticated && isOnline && !_notificationPollingRunning;

    final shouldStop =
        (!isAuthenticated || !isOnline) && _notificationPollingRunning;

    if (!shouldStart && !shouldStop) return;

    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _syncScheduled = false;

      if (!mounted) return;

      final notificationController = context.read<NotificationController>();

      if (isAuthenticated && isOnline && !_notificationPollingRunning) {
        notificationController.startRealtimeNotifications();
        _notificationPollingRunning = true;
      } else if ((!isAuthenticated || !isOnline) &&
          _notificationPollingRunning) {
        notificationController.stopRealtimeNotifications();
        _notificationPollingRunning = false;

        if (!isAuthenticated) {
          await notificationController.clearNotifications();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<CheckNetwork>();
    final auth = context.watch<AuthController>();

    if (!network.initialized) {
      return const Scaffold(
        backgroundColor: AppConstants.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _syncNotificationState(
      isAuthenticated: auth.isAuthenticated,
      isOnline: network.isOnline,
    );

    if (!network.isOnline) {
      return const _NoInternetScreen();
    }

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}

class _NoInternetScreen extends StatelessWidget {
  const _NoInternetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your Wi-Fi or mobile data connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<CheckNetwork>().checkNetwork();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
