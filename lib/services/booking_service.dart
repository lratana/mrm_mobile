import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/utils/date_time_helper.dart';
import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../models/room_model.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _api = ApiService.instance;

  /// Current backend request format:
  /// yyyy-MM-dd HH:mm:ss
  ///
  /// Important:
  /// This sends local wall-clock time because the current backend appears
  /// to convert Cambodia/local submitted times into UTC before returning them.
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String apiDate(DateTime date) {
    final utc = date.toUtc();

    final formatted = utc.toIso8601String();

    debugPrint('========== TIME DEBUG ==========');
    debugPrint('Local: $date');
    debugPrint('UTC: $utc');
    debugPrint('Sent: $formatted');

    return formatted;
  }

  List<Booking> _parseBookings(dynamic response) {
    final dynamic list;

    if (response is Map && response['data'] is List) {
      list = response['data'];
    } else if (response is Map &&
        response['data'] is Map &&
        response['data']['data'] is List) {
      list = response['data']['data'];
    } else {
      list = response;
    }

    if (list is List) {
      return list
          .where((item) => item is Map)
          .map(
            (item) => Booking.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }

    return [];
  }

  List<Room> _parseRooms(dynamic response) {
    final dynamic list;

    if (response is Map && response['data'] is List) {
      list = response['data'];
    } else if (response is Map &&
        response['data'] is Map &&
        response['data']['data'] is List) {
      list = response['data']['data'];
    } else {
      list = response;
    }

    if (list is List) {
      return list
          .where((item) => item is Map)
          .map((item) => Room.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return [];
  }

  Map<String, dynamic> _parseObject(dynamic response) {
    if (response is Map && response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return <String, dynamic>{};
  }

  Future<List<Booking>> getBookings({
    int page = 1,
    int perPage = 20,
    int? roomId,
    String? status,
  }) async {
    final response = await _api.get(
      'api/bookings',
      query: {
        'page': page,
        'per_page': perPage,
        'room_id': roomId,
        'status': status,
      },
    );

    return _parseBookings(response);
  }

  Future<Booking> getBooking(int id) async {
    final response = await _api.get('api/bookings/read/$id');

    return Booking.fromJson(_parseObject(response));
  }

  Map<String, dynamic> _normalizeBookingPayload(Map<String, dynamic> payload) {
    final fixedPayload = Map<String, dynamic>.from(payload);

    fixedPayload['start_datetime'] = _toApiUtcDateTime(
      fixedPayload['start_datetime'],
    );

    fixedPayload['end_datetime'] = _toApiUtcDateTime(
      fixedPayload['end_datetime'],
    );

    if (fixedPayload['actual_start_datetime'] != null) {
      fixedPayload['actual_start_datetime'] = _toApiUtcDateTime(
        fixedPayload['actual_start_datetime'],
      );
    }

    return fixedPayload;
  }

  String _toApiUtcDateTime(dynamic value) {
    if (value == null) return '';

    // ✅ Best case: payload sends DateTime object
    if (value is DateTime) {
      return DateTimeHelper.toApiUtcString(value);
    }

    final raw = value.toString().trim();

    if (raw.isEmpty) return '';

    final hasTimezone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);

    // ✅ ISO string with timezone
    // Example: 2026-06-17T06:38:00.000Z
    // Example: 2026-06-17T13:38:00+07:00
    if (hasTimezone) {
      try {
        return DateTimeHelper.toApiUtcString(DateTime.parse(raw));
      } catch (_) {
        return raw;
      }
    }

    // ✅ Plain string from UI: 2026-06-17 13:38:00
    // Treat it as LOCAL Cambodia/device time, then convert to UTC.
    try {
      final localDateTime = DateTime.parse(raw.replaceFirst(' ', 'T'));
      return DateTimeHelper.toApiUtcString(localDateTime);
    } catch (_) {
      return raw;
    }
  }

  Future<Booking> createBooking(Map<String, dynamic> payload) async {
    final fixedPayload = _normalizeBookingPayload(payload);

    debugPrint('========== CREATE BOOKING PAYLOAD ==========');
    debugPrint('start_datetime: ${fixedPayload['start_datetime']}');
    debugPrint('end_datetime: ${fixedPayload['end_datetime']}');

    final response = await _api.post('api/bookings/create', body: fixedPayload);

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('========== CREATE BOOKING RESPONSE ==========');
    debugPrint('Parsed start UTC: ${booking.startDatetime}');
    debugPrint('Parsed end UTC: ${booking.endDatetime}');
    debugPrint('Local start: ${booking.startDatetime?.toLocal()}');
    debugPrint('Local end: ${booking.endDatetime?.toLocal()}');

    return booking;
  }

  Future<Booking> updateBooking(int id, Map<String, dynamic> payload) async {
    final fixedPayload = _normalizeBookingPayload(payload);

    debugPrint('========== UPDATE BOOKING PAYLOAD ==========');
    debugPrint('booking_id: $id');
    debugPrint('start_datetime: ${fixedPayload['start_datetime']}');
    debugPrint('end_datetime: ${fixedPayload['end_datetime']}');

    final response = await _api.put(
      'api/bookings/update/$id',
      body: fixedPayload,
    );

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('========== UPDATE BOOKING RESPONSE ==========');
    debugPrint('Parsed start UTC: ${booking.startDatetime}');
    debugPrint('Parsed end UTC: ${booking.endDatetime}');
    debugPrint('Local start: ${booking.startDatetime?.toLocal()}');
    debugPrint('Local end: ${booking.endDatetime?.toLocal()}');

    return booking;
  }

  Future<Map<String, dynamic>> availability({
    required int roomId,
    required DateTime start,
    required DateTime end,
    int? ignoreId,
  }) async {
    final startValue = DateTimeHelper.toApiUtcString(start);
    final endValue = DateTimeHelper.toApiUtcString(end);

    debugPrint('========== AVAILABILITY CHECK ==========');
    debugPrint('Local start: $start');
    debugPrint('Local end: $end');
    debugPrint('UTC start sent: $startValue');
    debugPrint('UTC end sent: $endValue');

    final query = <String, dynamic>{
      'room_id': roomId,
      'start_datetime': startValue,
      'end_datetime': endValue,
    };

    if (ignoreId != null) {
      query['ignore_id'] = ignoreId;
    }

    debugPrint('Availability query: $query');

    final response = await _api.get('api/bookings/availability', query: query);

    if (response is Map && response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return <String, dynamic>{};
  }

  Future<List<Room>> availableRooms({
    required DateTime start,
    required DateTime end,
    int? ignoreId,
    int? participants,
    List<String>? equipment,
  }) async {
    final startValue = DateTimeHelper.toApiUtcString(start);
    final endValue = DateTimeHelper.toApiUtcString(end);

    debugPrint('========== AVAILABLE ROOMS CHECK ==========');
    debugPrint('Local start: $start');
    debugPrint('Local end: $end');
    debugPrint('UTC start sent: $startValue');
    debugPrint('UTC end sent: $endValue');
    debugPrint('start isUtc: ${start.isUtc}');
    debugPrint('end isUtc: ${end.isUtc}');

    final query = <String, dynamic>{
      'start_datetime': startValue,
      'end_datetime': endValue,
    };

    if (ignoreId != null) {
      query['ignore_id'] = ignoreId;
    }

    if (participants != null && participants > 0) {
      query['participants'] = participants;
    }

    final hasAnyEquipment =
        equipment?.map((e) => e.toLowerCase().trim()).contains('any') ?? false;

    if (equipment != null && equipment.isNotEmpty && !hasAnyEquipment) {
      query['equipment'] = equipment
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join(',');
    }

    debugPrint('Available rooms query: $query');

    final response = await _api.get(
      'api/bookings/available-rooms',
      query: query,
    );

    debugPrint('Available rooms response: $response');

    return _parseRooms(response);
  }

  Future<List<Booking>> calendar({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _api.get(
      'api/bookings/calendar',
      query: {'start': apiDate(start), 'end': apiDate(end)},
    );

    return _parseBookings(response);
  }

  Future<Booking> requestCancel(int id, String reason) async {
    final response = await _api.put(
      'api/bookings/request-cancel/$id',
      body: {'reason': reason},
    );

    return Booking.fromJson(_parseObject(response));
  }

  Future<Booking> approve(int id) async {
    final response = await _api.put('api/bookings/approve/$id');

    return Booking.fromJson(_parseObject(response));
  }

  Future<Booking> reject(int id, String reason) async {
    final response = await _api.put(
      'api/bookings/reject/$id',
      body: {'reason': reason},
    );

    return Booking.fromJson(_parseObject(response));
  }

  Future<Booking> confirmCancel(int id) async {
    final response = await _api.put('api/bookings/confirm-cancel/$id');

    return Booking.fromJson(_parseObject(response));
  }

  Future<Booking> adminCancel(int id) async {
    final response = await _api.put('api/bookings/admin-cancel/$id');

    return Booking.fromJson(_parseObject(response));
  }

  Future<Booking> startMeeting(int id) async {
    final response = await _api.post(
      'api/bookings/start/$id', // backend route for starting meeting
    );

    final booking = Booking.fromJson(_parseObject(response));

    return booking;
  }

  Future<Booking> leaveMeeting(int id) async {
    final response = await _api.post(
      'api/bookings/leave/$id', // backend route for leaving meeting
    );

    final booking = Booking.fromJson(_parseObject(response));

    return booking;
  }

  Future<Booking> addExtraTime({
    required int id,
    required int extraHours,
  }) async {
    final response = await _api.put(
      'api/bookings/extend-time/$id',
      body: {'extra_hours': extraHours},
    );

    final booking = Booking.fromJson(_parseObject(response));

    return booking;
  }

  Future<void> deleteBooking(int id) async {
    await _api.delete('api/bookings/delete/$id');
  }

  Future<Map<String, dynamic>> fetchBookingReport({
    required String type,
    DateTime? selectedDate,
  }) async {
    final date = selectedDate ?? DateTime.now();
    final query = <String, dynamic>{
      'type': type,
    }; // No DateTime timezone conversion here.
    // Only send date parts to backend.
    switch (type) {
      case 'daily':
      case 'weekly':
        query['date'] = DateFormat('yyyy-MM-dd').format(date);
        break;
      case 'monthly':
        query['month'] = date.month;
        query['year'] = date.year;
        break;
      case 'yearly':
        query['year'] = date.year;
        break;
    }
    final response = await _api.get(
      AppConstants.bookingReportsPath,
      query: query,
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception('Invalid analytics response.');
  }
}
