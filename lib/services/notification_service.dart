import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _api = ApiService.instance;

  List<AppNotification> _parse(dynamic response) {
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
            (item) => AppNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('api/notifications');
    return _parse(response);
  }

  Future<List<AppNotification>> getUnread() async {
    final response = await _api.get('api/notifications/unread');
    return _parse(response);
  }

  Future<void> markAsRead(String id) async {
    await _api.post('api/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.post('api/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _api.delete('api/notifications/$id');
  }
}
