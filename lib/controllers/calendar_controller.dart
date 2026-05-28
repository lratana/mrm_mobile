import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

class CalendarController extends ChangeNotifier {
  final BookingService _service = BookingService();

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  Map<DateTime, List<Booking>> events = {};
  bool loading = false;
  String? error;

  List<Booking> get selectedEvents => events[normalizeDate(selectedDay)] ?? [];

  void selectDay(DateTime selected, DateTime focused) {
    selectedDay = selected;
    focusedDay = focused;
    notifyListeners();
  }

  Future<void> fetchMonth(DateTime month) async {
    loading = true;
    error = null;
    notifyListeners();

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    try {
      final bookings = await _service.calendar(start: start, end: end);
      events = {};
      for (final booking in bookings) {
        final startDate = booking.startDatetime;
        if (startDate == null) continue;
        final key = normalizeDate(startDate);
        events.putIfAbsent(key, () => []).add(booking);
      }
    } catch (e) {
      error = e.toString();
      if (events.isEmpty) _loadDemo();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _loadDemo() {
    final today = normalizeDate(DateTime.now());
    events = {
      today: [
        Booking(
          id: 'cal-demo',
          bookingId: 1,
          roomId: 1,
          userId: 1,
          meetingTitle: 'Demo Meeting',
          startDatetime: DateTime.now().add(const Duration(hours: 2)),
          endDatetime: DateTime.now().add(const Duration(hours: 3)),
          status: 'approved',
        ),
      ],
    };
  }
}
