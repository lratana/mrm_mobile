import 'package:flutter/foundation.dart';
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
    final utcDate = date.toUtc();
    final formatted = _apiFormat.format(utcDate);

    debugPrint('========== BOOKING REQUEST DATETIME ==========');
    debugPrint('Input DateTime: $date');
    debugPrint('Input isUtc: ${date.isUtc}');
    debugPrint('UTC DateTime: $utcDate');
    debugPrint('Request UTC Value: $formatted');

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

  Future<Booking> createBooking(Map<String, dynamic> payload) async {
    debugPrint('========== CREATE BOOKING PAYLOAD ==========');
    debugPrint('start_datetime: ${payload['start_datetime']}');
    debugPrint('end_datetime: ${payload['end_datetime']}');

    final response = await _api.post('api/bookings/create', body: payload);

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('========== CREATE BOOKING RESPONSE ==========');
    debugPrint('Parsed start: ${booking.startDatetime}');
    debugPrint('Parsed end: ${booking.endDatetime}');
    debugPrint('Local start: ${booking.startDatetime?.toLocal()}');
    debugPrint('Local end: ${booking.endDatetime?.toLocal()}');

    return booking;
  }

  Future<Booking> updateBooking(int id, Map<String, dynamic> payload) async {
    debugPrint('========== UPDATE BOOKING PAYLOAD ==========');
    debugPrint('Booking ID: $id');
    debugPrint('start_datetime: ${payload['start_datetime']}');
    debugPrint('end_datetime: ${payload['end_datetime']}');

    final response = await _api.put('api/bookings/update/$id', body: payload);

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('========== UPDATE BOOKING RESPONSE ==========');
    debugPrint('Parsed start: ${booking.startDatetime}');
    debugPrint('Parsed end: ${booking.endDatetime}');
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
    final startValue = apiDate(start);
    final endValue = apiDate(end);

    final response = await _api.get(
      'api/bookings/availability',
      query: {
        'room_id': roomId,
        'start_datetime': startValue,
        'end_datetime': endValue,
        'ignore_id': ignoreId,
      },
    );

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
  }) async {
    final startValue = apiDate(start);
    final endValue = apiDate(end);

    final response = await _api.get(
      'api/bookings/available-rooms',
      query: {
        'start_datetime': startValue,
        'end_datetime': endValue,
        'ignore_id': ignoreId,
      },
    );

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
    debugPrint('========== START MEETING ==========');
    debugPrint('Booking ID: $id');

    final response = await _api.post(
      'api/bookings/start/$id', // backend route for starting meeting
    );

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('Meeting started: ${booking.actualStartDatetime}');
    return booking;
  }

  Future<Booking> leaveMeeting(int id) async {
    debugPrint('========== LEAVE MEETING ==========');
    debugPrint('Booking ID: $id');

    final response = await _api.post(
      'api/bookings/leave/$id', // backend route for leaving meeting
    );

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('Meeting ended: ${booking.actualEndDatetime}');
    return booking;
  }

  Future<Booking> addExtraTime({
    required int id,
    required int extraHours,
  }) async {
    debugPrint('========== EXTEND BOOKING ==========');
    debugPrint('Booking ID: $id');
    debugPrint('Extra hours: $extraHours');

    final response = await _api.put(
      'api/bookings/extend-time/$id',
      body: {'extra_hours': extraHours},
    );

    final booking = Booking.fromJson(_parseObject(response));

    debugPrint('Updated raw end: ${booking.endDatetime}');
    debugPrint('Updated local end: ${booking.endDatetime?.toLocal()}');

    return booking;
  }

  Future<void> deleteBooking(int id) async {
    await _api.delete('api/bookings/delete/$id');
  }
}
