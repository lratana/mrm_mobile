import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/check_network.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/booking_controller.dart';
import 'controllers/calendar_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/room_controller.dart';
import 'screens/auth_gate.dart';
import 'utils/constants.dart';

void main() {
  runApp(const RoomBookingApp());
}

class RoomBookingApp extends StatelessWidget {
  const RoomBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckNetwork()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthController()..initialize()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => RoomController()),
        ChangeNotifierProvider(create: (_) => BookingController()),
        ChangeNotifierProvider(create: (_) => CalendarController()),
      ],
      child: MaterialApp(
        title: 'Room Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppConstants.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primary,
            primary: AppConstants.primary,
            background: AppConstants.bg,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.bg,
            surfaceTintColor: AppConstants.bg,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
