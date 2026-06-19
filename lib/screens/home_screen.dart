import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/room_controller.dart';
import '../utils/app_palette.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Future.wait([
        context.read<RoomController>().fetchRooms(),
        context.read<BookingController>().fetchBookings(),
        context.read<CalendarController>().fetchMonth(DateTime.now()),

        context.read<NotificationController>().fetchNotifications(
          silent: true,
          showAlertsForNewItems: false,
        ),
      ]);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && mounted) {
      context.read<NotificationController>().fetchNotifications(
        silent: true,
        showAlertsForNewItems: true,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: const RoomScreen(showHomeHeader: true),
    );
  }
}
