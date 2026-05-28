import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomController extends ChangeNotifier {
  final RoomService _service = RoomService();

  List<Room> rooms = [];
  Room? selectedRoom;
  bool loading = false;
  String? error;
  String search = '';

  List<Room> get featuredRooms => rooms.take(5).toList();
  List<Room> get availableRooms => rooms.where((room) => room.isBookable).toList();

  Future<void> fetchRooms({String? q, bool refresh = false}) async {
    loading = true;
    error = null;
    if (q != null) search = q;
    notifyListeners();

    try {
      rooms = await _service.getRooms(q: search.isEmpty ? null : search, perPage: 50);
    } catch (e) {
      error = e.toString();
      // Demo fallback keeps UI runnable before API/token setup.
      if (rooms.isEmpty) rooms = _demoRooms();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadRoom(int id) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      selectedRoom = await _service.getRoom(id);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRoom(int id) async {
    try {
      await _service.deleteRoom(id);
      rooms.removeWhere((room) => room.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Room> _demoRooms() {
    return const [
      Room(
        id: 1,
        name: 'The Executive Suite',
        location: 'Financial District, NY',
        capacity: 12,
        description: 'Premium executive meeting room.',
        rating: 4.9,
      ),
      Room(
        id: 2,
        name: 'Skyline Boardroom',
        location: 'Midtown Manhattan, NY',
        capacity: 20,
        description: 'Bright boardroom with city view.',
        rating: 4.7,
        status: 'busy',
      ),
      Room(
        id: 3,
        name: 'The Library Suite',
        location: 'Upper East Side, NY',
        capacity: 4,
        description: 'Quiet private room.',
        rating: 5.0,
      ),
      Room(
        id: 4,
        name: 'Tech Hub Station',
        location: 'Brooklyn Tech Center, NY',
        capacity: 8,
        description: 'Modern tech-enabled workspace.',
        rating: 4.8,
        status: 'booked',
      ),
    ];
  }
}
