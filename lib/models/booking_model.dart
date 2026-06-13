import 'room_model.dart';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final v = value?.toString().toLowerCase();
  return v == 'true' || v == '1' || v == 'yes';
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
    return DateTime.tryParse(raw);
  }
  final normalized = raw.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

List<String> _asStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [];
}

class BookingUser {
  final int id;
  final String name;
  final String email;

  const BookingUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      id: _asInt(json['id']),
      name: _asString(json['name'], fallback: 'User'),
      email: _asString(json['email']),
    );
  }
}

class Booking {
  final String id;
  final int bookingId;
  final int roomId;
  final int userId;

  final DateTime? startDatetime;
  final DateTime? endDatetime;

  // ✅ New fields for actual start/end
  final DateTime? actualStartDatetime;
  final DateTime? actualEndDatetime;

  final String recurrenceType;
  final List<String> recurrenceDays;
  final int? recurrencePeriod;
  final DateTime? recurrenceUntil;

  final String meetingTitle;
  final String meetingChairman;

  final bool snackRequired;
  final String snackNote;

  final bool technicianRequired;
  final String technicianNote;

  final String status;
  final String cancelReason;
  final String rejectReason;

  final Room? room;
  final BookingUser? user;

  final bool isGenerated;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.bookingId,
    required this.roomId,
    required this.userId,
    this.startDatetime,
    this.endDatetime,
    this.actualStartDatetime,
    this.actualEndDatetime,
    this.recurrenceType = 'none',
    this.recurrenceDays = const [],
    this.recurrencePeriod,
    this.recurrenceUntil,
    this.meetingTitle = '',
    this.meetingChairman = '',
    this.snackRequired = false,
    this.snackNote = '',
    this.technicianRequired = false,
    this.technicianNote = '',
    this.status = 'pending',
    this.cancelReason = '',
    this.rejectReason = '',
    this.room,
    this.user,
    this.isGenerated = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'] ?? json['booking_id'] ?? '';

    return Booking(
      id: rawId.toString(),
      bookingId: _asInt(json['booking_id'] ?? json['id']),
      roomId: _asInt(json['room_id']),
      userId: _asInt(json['user_id']),
      startDatetime: _asDate(json['start_datetime']),
      endDatetime: _asDate(json['end_datetime']),
      actualStartDatetime: _asDate(json['actual_start_datetime']),
      actualEndDatetime: _asDate(json['actual_end_datetime']),
      recurrenceType: _asString(json['recurrence_type'], fallback: 'none'),
      recurrenceDays: _asStringList(json['recurrence_days']),
      recurrencePeriod: json['recurrence_period'] == null
          ? null
          : _asInt(json['recurrence_period']),
      recurrenceUntil: _asDate(json['recurrence_until']),
      meetingTitle: _asString(json['meeting_title']),
      meetingChairman: _asString(json['meeting_chairman']),
      snackRequired: _asBool(json['snack_required']),
      snackNote: _asString(json['snack_note']),
      technicianRequired: _asBool(json['technician_required']),
      technicianNote: _asString(json['technician_note']),
      status: _asString(json['status'], fallback: 'pending'),
      cancelReason: _asString(json['cancel_reason']),
      rejectReason: _asString(json['reject_reason']),
      room: json['room'] is Map
          ? Room.fromJson(Map<String, dynamic>.from(json['room'] as Map))
          : null,
      user: json['user'] is Map
          ? BookingUser.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      isGenerated: _asBool(json['is_generated']),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }

  String get title {
    if (meetingTitle.trim().isNotEmpty) return meetingTitle;
    return room?.name ?? 'Room Booking';
  }

  bool get canEdit => status == 'pending' || status == 'approved';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';

  Map<String, dynamic> toPayload() {
    return {
      'room_id': roomId,
      'start_datetime': startDatetime?.toIso8601String(),
      'end_datetime': endDatetime?.toIso8601String(),
      'actual_start_datetime': actualStartDatetime?.toIso8601String(),
      'actual_end_datetime': actualEndDatetime?.toIso8601String(),
      'recurrence_type': recurrenceType,
      'recurrence_days': recurrenceDays,
      'recurrence_period': recurrencePeriod,
      'recurrence_until': recurrenceUntil?.toIso8601String(),
      'meeting_title': meetingTitle,
      'meeting_chairman': meetingChairman,
      'snack_required': snackRequired,
      'snack_note': snackNote,
      'technician_required': technicianRequired,
      'technician_note': technicianNote,
      'status': status,
      'cancel_reason': cancelReason,
      'reject_reason': rejectReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
