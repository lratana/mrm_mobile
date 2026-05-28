import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/room_controller.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    RoomScreen(showHomeHeader: true),
    BookingScreen(),
    CalendarScreen(),
    NotificationScreen(),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      context.read<RoomController>().fetchRooms();
      context.read<BookingController>().fetchBookings();
      context.read<NotificationController>().fetchNotifications();
      context.read<NotificationController>().startRealtimeBadge();
      context.read<CalendarController>().fetchMonth(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Consumer<NotificationController>(
        builder: (context, notificationController, _) {
          final unreadCount = notificationController.unreadCount;

          return NavigationBar(
            height: 72,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            indicatorColor: AppConstants.mint,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search, color: AppConstants.primary),
                label: 'Explore',
              ),
              const NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(
                  Icons.calendar_today,
                  color: AppConstants.primary,
                ),
                label: 'Bookings',
              ),
              const NavigationDestination(
                icon: Icon(Icons.event_available_outlined),
                selectedIcon: Icon(
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
          );
        },
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
          color: selected ? AppConstants.primary : null,
        ),
        if (count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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
