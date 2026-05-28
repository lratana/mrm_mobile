import 'dart:convert';

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}

class AppNotification {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      data: _asMap(json['data']),
      readAt: _asDate(json['read_at']),
      createdAt: _asDate(json['created_at']),
    );
  }

  bool get isUnread => readAt == null;

  String get title {
    return (data['title'] ??
            data['subject'] ??
            data['notification_title'] ??
            'Notification')
        .toString();
  }

  String get message {
    return (data['message'] ??
            data['body'] ??
            data['text'] ??
            data['description'] ??
            '')
        .toString();
  }

  String get roomName {
    return (data['room_name'] ?? data['room'] ?? '').toString();
  }
}
