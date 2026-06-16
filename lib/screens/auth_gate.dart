import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/check_network.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../utils/app_palette.dart';
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
  bool _notificationSyncInProgress = false;

  void _syncNotificationState({
    required bool isAuthenticated,
    required bool isOnline,
  }) {
    if (_notificationSyncInProgress) return;

    final shouldStart =
        isAuthenticated && isOnline && !_notificationPollingRunning;

    final shouldStop =
        (!isAuthenticated || !isOnline) && _notificationPollingRunning;

    if (!shouldStart && !shouldStop) return;

    _notificationSyncInProgress = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (!mounted) return;

        final notificationController = context.read<NotificationController>();

        if (shouldStart) {
          /*
            This initializes flutter_local_notifications and requests
            Android 13+/iOS notification permission.

            Even if permission is denied, polling should still start so
            your in-app NotificationScreen and bottom navigation count
            continue to update.
          */
          await notificationController.requestNotificationPermission();

          if (!mounted) return;

          final currentAuth = context.read<AuthController>();
          final currentNetwork = context.read<CheckNetwork>();

          /*
            The user may log out or lose internet while the permission
            dialog is open. Check the latest state before starting polling.
          */
          if (currentAuth.isAuthenticated &&
              currentNetwork.isOnline &&
              !_notificationPollingRunning) {
            notificationController.startRealtimeNotifications();
            _notificationPollingRunning = true;
          }
        }

        if (shouldStop && _notificationPollingRunning) {
          notificationController.stopRealtimeNotifications();
          _notificationPollingRunning = false;

          /*
            Offline: keep the last loaded notification data and badge.
            Logout: clear user-specific notification data and system badge.
          */
          if (!isAuthenticated) {
            await notificationController.clearNotifications();
          }
        }
      } finally {
        _notificationSyncInProgress = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNotificationState(
        isAuthenticated: context.read<AuthController>().isAuthenticated,
        isOnline: context.read<CheckNetwork>().isOnline,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<CheckNetwork>();
    final auth = context.watch<AuthController>();

    if (!network.initialized) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppConstants.primary),
        ),
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
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 56,
                    color: context.appColors.textMuted,
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: context.appText.titleLarge?.copyWith(
                    color: context.appColors.text,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Please check your Wi-Fi or mobile data connection.',
                  textAlign: TextAlign.center,
                  style: context.appText.bodyMedium?.copyWith(
                    color: context.appColors.textMuted,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<CheckNetwork>().checkNetwork();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
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
