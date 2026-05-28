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

    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }

    try {
      notifications = await _service.getNotifications();
      error = null;
    } catch (e) {
      error = _cleanError(e);

      if (notifications.isEmpty) {
        notifications = _demoNotifications();
      }
    } finally {
      _fetching = false;

      if (!silent) {
        loading = false;
      }

      notifyListeners();
    }
  }

  void startRealtimeBadge() {
    _timer?.cancel();

    fetchNotifications(silent: true);

    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchNotifications(silent: true);
    });
  }

  void stopRealtimeBadge() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);

      final index = notifications.indexWhere(
        (notification) => notification.id == id,
      );

      if (index >= 0) {
        await fetchNotifications(silent: true);
      } else {
        await fetchNotifications();
      }
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

  List<AppNotification> _demoNotifications() {
    final now = DateTime.now();

    return [
      AppNotification(
        id: '1',
        type: 'booking',
        data: {
          'title': 'Booking Confirmed',
          'message':
              'Your booking for The Executive Suite is confirmed for tomorrow.',
        },
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      AppNotification(
        id: '2',
        type: 'reminder',
        data: {
          'title': 'Meeting Reminder',
          'message':
              "Don't forget your upcoming meeting in Room 4B starting in 1 hour.",
        },
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: '3',
        type: 'checkout',
        data: {
          'title': 'Checkout Complete',
          'message':
              'Hope you enjoyed your stay. Your receipt has been sent to your email.',
        },
        readAt: now,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  void dispose() {
    stopRealtimeBadge();
    super.dispose();
  }
}
