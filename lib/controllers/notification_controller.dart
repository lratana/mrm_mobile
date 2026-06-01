import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> notifications = [];

  bool loading = false;
  bool _fetching = false;

  String? error;

  Timer? _timer;

  // Prevents an old request from restoring notifications after logout.
  int _requestGeneration = 0;

  int get unreadCount {
    return notifications.where((notification) => notification.isUnread).length;
  }

  List<AppNotification> get unread {
    return notifications
        .where((notification) => notification.isUnread)
        .toList();
  }

  List<AppNotification> get earlier {
    return notifications
        .where((notification) => !notification.isUnread)
        .toList();
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (_fetching) return;

    _fetching = true;
    final currentGeneration = _requestGeneration;

    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }

    try {
      final result = await _service.getNotifications();

      if (currentGeneration != _requestGeneration) {
        return;
      }

      notifications = result;
      error = null;
    } catch (e) {
      if (currentGeneration != _requestGeneration) {
        return;
      }

      error = _cleanError(e);
    } finally {
      _fetching = false;

      if (currentGeneration == _requestGeneration) {
        if (!silent) {
          loading = false;
        }

        notifyListeners();
      }
    }
  }

  void startRealtimeNotifications() {
    _timer?.cancel();

    fetchNotifications(silent: true);

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchNotifications(silent: true),
    );
  }

  void stopRealtimeNotifications() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      await fetchNotifications(silent: true);
    } catch (e) {
      error = _cleanError(e);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      await fetchNotifications(silent: true);
    } catch (e) {
      error = _cleanError(e);
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);

      notifications.removeWhere((notification) => notification.id == id);

      notifyListeners();
    } catch (e) {
      error = _cleanError(e);
      notifyListeners();
    }
  }

  Future<void> clearNotifications() async {
    _requestGeneration++;

    notifications.clear();
    error = null;
    loading = false;

    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst(RegExp(r'ApiException\(\d+\):\s*'), '');
  }

  @override
  void dispose() {
    stopRealtimeNotifications();
    super.dispose();
  }
}
