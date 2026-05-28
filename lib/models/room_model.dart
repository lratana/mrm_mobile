import '../utils/constants.dart';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, {double fallback = 4.8}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

class Department {
  final int id;
  final String name;

  const Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: _asInt(json['id']),
      name: _asString(json['name']) ?? '',
    );
  }
}

class Equipment {
  final int id;
  final String name;

  const Equipment({required this.id, required this.name});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: _asInt(json['id']),
      name: _asString(json['name']) ?? '',
    );
  }
}

class RoomImage {
  final int id;
  final String imagePath;
  final bool isPrimary;
  final int sortOrder;

  const RoomImage({
    required this.id,
    required this.imagePath,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory RoomImage.fromJson(Map<String, dynamic> json) {
    return RoomImage(
      id: _asInt(json['id']),
      imagePath: _asString(json['image_url']) ??
          _asString(json['url']) ??
          _asString(json['image_path']) ??
          _asString(json['path']) ??
          '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1 || json['is_primary'] == '1',
      sortOrder: _asInt(json['sort_order']),
    );
  }

  String get url => _imageUrl(imagePath);
}

String _imageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
  return '${AppConstants.storageBaseUrl}/$cleaned';
}

class Room {
  final int id;
  final int? departmentId;
  final String name;
  final String description;
  final String location;
  final int capacity;
  final String? thumbnailPath;
  final Department? department;
  final List<Equipment> equipment;
  final List<RoomImage> images;

  /// Optional UI/API fields. If your backend later returns these fields, they are used.
  final double rating;
  final String? status;

  const Room({
    required this.id,
    this.departmentId,
    required this.name,
    required this.description,
    required this.location,
    required this.capacity,
    this.thumbnailPath,
    this.department,
    this.equipment = const [],
    this.images = const [],
    this.rating = 4.8,
    this.status,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    final equipmentJson = json['equipment'];
    final imagesJson = json['images'];

    return Room(
      id: _asInt(json['id']),
      departmentId: json['department_id'] == null ? null : _asInt(json['department_id']),
      name: _asString(json['name']) ?? 'Untitled Room',
      description: _asString(json['description']) ?? '',
      location: _asString(json['location']) ?? '',
      capacity: _asInt(json['capacity']),
      thumbnailPath: _asString(json['thumbnail_url']) ??
          _asString(json['thumbnail']) ??
          _asString(json['thumbnail_path']),
      department: json['department'] is Map<String, dynamic>
          ? Department.fromJson(json['department'])
          : null,
      equipment: equipmentJson is List
          ? equipmentJson
              .whereType<Map<String, dynamic>>()
              .map(Equipment.fromJson)
              .toList()
          : const [],
      images: imagesJson is List
          ? imagesJson
              .whereType<Map<String, dynamic>>()
              .map(RoomImage.fromJson)
              .toList()
          : const [],
      rating: _asDouble(json['rating']),
      status: _asString(json['status']),
    );
  }

  String get imageUrl {
    if (thumbnailPath != null && thumbnailPath!.isNotEmpty) {
      return _imageUrl(thumbnailPath);
    }
    if (images.isNotEmpty) return images.first.url;
    return '';
  }

  List<String> get featureNames {
    if (equipment.isNotEmpty) return equipment.map((e) => e.name).toList();
    return const ['Wi-Fi', 'Projector', 'Coffee'];
  }

  bool get isBookable {
    final s = status?.toLowerCase();
    return s == null || s == 'available';
  }

  Map<String, dynamic> toPayload() {
    return {
      'department_id': departmentId,
      'name': name,
      'description': description,
      'location': location,
      'capacity': capacity,
      'equipment': featureNames,
    };
  }
}
