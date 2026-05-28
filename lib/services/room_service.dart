import '../models/room_model.dart';
import 'api_service.dart';

class RoomService {
  final ApiService _api = ApiService.instance;

  List<Room> _parseRooms(dynamic response) {
    final dynamic list = response is Map ? response['data'] : response;

    if (list is List) {
      return list
          .where((item) => item is Map)
          .map((item) => Room.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return [];
  }

  Future<List<Room>> getRooms({
    String? q,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _api.get(
      'api/rooms',
      query: {'q': q, 'page': page, 'per_page': perPage},
    );

    return _parseRooms(response);
  }

  Future<Room> getRoom(int id) async {
    final response = await _api.get('api/rooms/read/$id');

    return Room.fromJson(
      Map<String, dynamic>.from(response['data'] ?? response),
    );
  }

  Future<Room> createRoom(Map<String, dynamic> payload) async {
    final response = await _api.post('api/rooms/create', body: payload);

    return Room.fromJson(
      Map<String, dynamic>.from(response['data'] ?? response),
    );
  }

  /// Laravel route: POST /api/rooms/update/{room}
  Future<Room> updateRoom(int id, Map<String, dynamic> payload) async {
    final response = await _api.post('api/rooms/update/$id', body: payload);

    return Room.fromJson(
      Map<String, dynamic>.from(response['data'] ?? response),
    );
  }

  Future<void> deleteRoom(int id) async {
    await _api.delete('api/rooms/delete/$id');
  }

  Future<void> deleteRoomImage(int roomId, int imageId) async {
    await _api.delete('api/rooms/delete-image/$roomId/$imageId');
  }

  Future<RoomImage> uploadRoomImage({
    required int roomId,
    required String imageFilePath,
    bool isPrimary = false,
  }) async {
    final response = await _api.multipartPost(
      'api/room-images/upload/$roomId',
      fields: {'is_primary': isPrimary ? '1' : '0'},
      files: {'image': imageFilePath},
    );

    return RoomImage.fromJson(
      Map<String, dynamic>.from(response['data'] ?? response),
    );
  }

  Future<void> deleteImage(int imageId) async {
    await _api.delete('api/room-images/delete/$imageId');
  }
}
