import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/utils/date_time_helper.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import '../services/booking_service.dart';

class BookingController extends ChangeNotifier {
  final BookingService _service = BookingService();

  List<Booking> bookings = [];
  List<Room> availableRooms = [];

  bool loading = false;
  bool submitting = false;

  String? error;

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst(RegExp(r'ApiException\(\d+\):\s*'), '');
  }

  Future<void> fetchBookings({String? status}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      bookings = await _service.getBookings(status: status, perPage: 50);
    } catch (e) {
      error = _cleanError(e);

      // if (bookings.isEmpty) {
      //   bookings = _demoBookings();
      // }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(Map<String, dynamic> payload) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final booking = await _service.createBooking(payload);

      bookings.insert(0, booking);

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateBooking(int id, Map<String, dynamic> payload) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.updateBooking(id, payload);

      final index = bookings.indexWhere((booking) => booking.bookingId == id);

      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  // Helpers to parse API responses that may have different structures
  Future<bool> requestCancel(int id, String reason) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.requestCancel(id, reason);

      final index = bookings.indexWhere((booking) => booking.bookingId == id);

      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  // Admin actions
  Future<bool> rejectBooking(int id, String reason) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.reject(id, reason);

      final index = bookings.indexWhere((booking) => booking.bookingId == id);

      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst(RegExp(r'ApiException\(\d+\):\s*'), '');
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  /// Admin actions
  Future<bool> approveBooking(int id) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.approve(id);

      final index = bookings.indexWhere((booking) => booking.bookingId == id);

      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst(RegExp(r'ApiException\(\d+\):\s*'), '');
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  // Admin actions
  Future<bool> addExtraTime({required int id, required int extraHours}) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.addExtraTime(
        id: id,
        extraHours: extraHours,
      );

      final index = bookings.indexWhere((booking) => booking.bookingId == id);

      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<bool> startMeeting(int bookingId) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.startMeeting(bookingId);

      final index = bookings.indexWhere(
        (booking) => booking.bookingId == bookingId,
      );
      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<bool> leaveMeeting(int bookingId) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      final updated = await _service.leaveMeeting(bookingId);

      final index = bookings.indexWhere(
        (booking) => booking.bookingId == bookingId,
      );
      if (index >= 0) {
        bookings[index] = updated;
      }

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBooking(int id) async {
    submitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.deleteBooking(id);

      bookings.removeWhere((booking) => booking.bookingId == id);

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<bool> checkAvailability({
    required int roomId,
    required DateTime start,
    required DateTime end,
    int? ignoreId,
  }) async {
    error = null;

    try {
      // ✅ FIX 1: normalize to UTC before sending
      final result = await _service.availability(
        roomId: roomId,
        start: start,
        end: end,
        ignoreId: ignoreId,
      );

      // ✅ FIX 2: strict boolean parsing (clean API contract)
      final available = result['available'];

      if (available is bool) return available;
      if (available is int) return available == 1;
      if (available is String) {
        return available.toLowerCase() == 'true' || available == '1';
      }

      return false;
    } catch (e) {
      error = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAvailableRooms({
    required DateTime start,
    required DateTime end,
    int? ignoreId,
    int? participants,
    List<String>? equipment,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      availableRooms = await _service.availableRooms(
        start: start,
        end: end,
        ignoreId: ignoreId,
        participants: participants,
        equipment: equipment,
      );
    } catch (e) {
      error = _cleanError(e);
      availableRooms = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void clearBookings() {
    bookings = [];
    notifyListeners();
  }

  Map<String, dynamic>? analyticsReport;
  bool analyticsLoading = false;
  String? analyticsError;

  Future<bool> fetchBookingReport({
    required String type,
    DateTime? selectedDate,
  }) async {
    analyticsLoading = true;
    analyticsError = null;
    notifyListeners();
    try {
      analyticsReport = await _service.fetchBookingReport(
        type: type,
        selectedDate: selectedDate,
      );
      return true;
    } catch (e) {
      analyticsError = _cleanError(e);
      return false;
    } finally {
      analyticsLoading = false;
      notifyListeners();
    }
  }

  // List<Booking> _demoBookings() {
  //   final now = DateTime.now();

  //   return [
  //     Booking(
  //       id: 'demo-1',
  //       bookingId: 1,
  //       roomId: 1,
  //       userId: 1,
  //       meetingTitle: 'Quarterly Strategy Sync',
  //       meetingChairman: 'Chairman',
  //       startDatetime: now.add(const Duration(days: 1, hours: 2)),
  //       endDatetime: now.add(const Duration(days: 1, hours: 4)),
  //       status: 'approved',
  //       room: const Room(
  //         id: 1,
  //         name: 'The Executive Suite',
  //         location: 'Financial District, NY',
  //         capacity: 12,
  //         description: '',
  //       ),
  //     ),
  //   ];
  // }
}
