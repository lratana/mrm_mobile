import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/calendar_controller.dart';
import '../utils/constants.dart';
import '../widgets/booking_card.dart';
import '../widgets/calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<CalendarController>().fetchMonth(DateTime.now());
    });
  }

  Future<void> _refreshCalendar(BuildContext context) async {
    final controller = context.read<CalendarController>();
    await controller.fetchMonth(controller.focusedDay);
  }

  Future<void> _goToday(BuildContext context) async {
    final today = DateTime.now();
    final controller = context.read<CalendarController>();

    controller.selectDay(today, today);
    await controller.fetchMonth(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        foregroundColor: AppConstants.primaryDark,
        elevation: 0,
        title: const Text(
          'Google Calendar',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: () => _goToday(context),
            child: const Text(
              'Today',
              style: TextStyle(
                color: AppConstants.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshCalendar(context),
          ),
        ],
      ),
      body: Consumer<CalendarController>(
        builder: (context, controller, _) {
          final selectedDateText = DateFormat(
            'EEEE, dd MMMM yyyy',
          ).format(controller.selectedDay);

          return RefreshIndicator(
            color: AppConstants.primary,
            onRefresh: () => _refreshCalendar(context),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppConstants.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: BookingCalendarWidget(
                    focusedDay: controller.focusedDay,
                    selectedDay: controller.selectedDay,
                    events: controller.events,
                    onDaySelected: controller.selectDay,
                    onPageChanged: (focusedDay) {
                      controller.fetchMonth(focusedDay);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Icons.event_note, color: AppConstants.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDateText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppConstants.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (controller.loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primary,
                      ),
                    ),
                  )
                else if (controller.selectedEvents.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConstants.border),
                    ),
                    child: const Center(
                      child: Text(
                        'No bookings for this date',
                        style: TextStyle(
                          color: AppConstants.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.selectedEvents.map(
                    (booking) => BookingCard(booking: booking),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
