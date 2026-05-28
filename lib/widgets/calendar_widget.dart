import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';

DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

class BookingCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<Booking>> events;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused)? onPageChanged;

  const BookingCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.onDaySelected,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Booking>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 730)),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      eventLoader: (day) => events[_normalize(day)] ?? [],
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: AppConstants.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppConstants.primary.withOpacity(.35),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppConstants.primaryDark,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppConstants.primaryDark),
      ),
    );
  }
}
