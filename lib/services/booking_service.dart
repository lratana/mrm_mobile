import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../models/room_model.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _api = ApiService.instance;
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  String apiDate(DateTime date) {
    return _apiFormat.format(date);
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
    final response = await _api.post('api/bookings/create', body: payload);

    return Booking.fromJson(_parseObject(response));
  }

  Future<Booking> updateBooking(int id, Map<String, dynamic> payload) async {
    final response = await _api.put('api/bookings/update/$id', body: payload);

    return Booking.fromJson(_parseObject(response));
  }

  Future<Map<String, dynamic>> availability({
    required int roomId,
    required DateTime start,
    required DateTime end,
    int? ignoreId,
  }) async {
    final response = await _api.get(
      'api/bookings/availability',
      query: {
        'room_id': roomId,
        'start_datetime': apiDate(start),
        'end_datetime': apiDate(end),
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
    final response = await _api.get(
      'api/bookings/available-rooms',
      query: {
        'start_datetime': apiDate(start),
        'end_datetime': apiDate(end),
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

  Future<void> deleteBooking(int id) async {
    await _api.delete('api/bookings/delete/$id');
  }
}
