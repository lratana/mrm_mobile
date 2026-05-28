class AppUser {
  final int? id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? level;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.level,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _asInt(json['id']),
      name: _asString(json['name']) ?? _asString(json['full_name']) ?? '',
      email: _asString(json['email']) ?? '',
      phoneNumber: _asString(json['phone_number']) ?? _asString(json['phone']),
      level: _asString(json['level']) ?? _asString(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'level': level,
    };
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}
