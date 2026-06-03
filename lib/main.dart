import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/booking_controller.dart';
import 'controllers/calendar_controller.dart';
import 'controllers/display_settings_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/room_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/auth_gate.dart';
import 'services/check_network.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoomBookingApp());
}

class RoomBookingApp extends StatelessWidget {
  const RoomBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..initialize()),
        ChangeNotifierProvider(
          create: (_) => DisplaySettingsController()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => CheckNetwork()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthController()..initialize()),
        ChangeNotifierProvider(create: (_) => RoomController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
        ChangeNotifierProvider(create: (_) => CalendarController()),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationController()..initializeSystemNotifications(),
        ),
      ],
      child: Consumer2<ThemeController, DisplaySettingsController>(
        builder: (context, themeController, displayController, _) {
          return MaterialApp(
            title: 'Room Booking',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeController.themeMode,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);

              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(
                    displayController.textScaleFactor,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
