import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/room_controller.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';
import 'booking_screen.dart';
import 'calendar_screen.dart';
import 'notification_screen.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RoomScreen(showHomeHeader: true),
    BookingScreen(),
    CalendarScreen(),
    NotificationScreen(),
  ];

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

        // Refresh notification list immediately on HomeScreen load.
        // Do not show popup alerts for items already existing at login.
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
      debugPrint('App resumed: refreshing notifications');

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

  Future<void> _changeTab(int index) async {
    setState(() {
      _currentIndex = index;
    });

    // Notifications tab index = 3.
    if (index == 3) {
      debugPrint('Notifications tab opened: refreshing notifications');

      await context.read<NotificationController>().fetchNotifications(
        silent: false,
        showAlertsForNewItems: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationController>().unreadCount;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _currentIndex,
        onDestinationSelected: _changeTab,
        backgroundColor: context.appColors.surface,
        indicatorColor: context.appColors.primarySoft,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: context.appColors.textMuted),
            selectedIcon: const Icon(Icons.home, color: AppConstants.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: context.appColors.textMuted,
            ),
            selectedIcon: const Icon(
              Icons.calendar_today,
              color: AppConstants.primary,
            ),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.event_available_outlined,
              color: context.appColors.textMuted,
            ),
            selectedIcon: const Icon(
              Icons.event_available,
              color: AppConstants.primary,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: _NotificationIconWithBadge(
              count: unreadCount,
              selected: false,
            ),
            selectedIcon: _NotificationIconWithBadge(
              count: unreadCount,
              selected: true,
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class _NotificationIconWithBadge extends StatelessWidget {
  final int count;
  final bool selected;

  const _NotificationIconWithBadge({
    required this.count,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          selected ? Icons.notifications : Icons.notifications_none,
          color: selected ? AppConstants.primary : context.appColors.textMuted,
        ),
        if (count > 0)
          Positioned(
            right: -7,
            top: -7,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: context.appColors.danger,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: context.appColors.surface,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                displayCount,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
