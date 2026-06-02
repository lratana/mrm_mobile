import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static const int _systemNotificationId = 1001;

  static const String _channelId = 'unread_notifications_channel';
  static const String _channelName = 'Unread Notifications';
  static const String _channelDescription =
      'Shows the number of unread room booking notifications';

  List<AppNotification> notifications = [];

  bool loading = false;
  bool _fetching = false;
  bool _pluginInitialized = false;
  bool _notificationPermissionGranted = false;

  String? error;

  Timer? _timer;

  // Prevents a request started before logout from restoring old data.
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

  bool get notificationPermissionGranted {
    return _notificationPermissionGranted;
  }

  Future<void> initializeSystemNotifications() async {
    if (_pluginInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: false,
      defaultPresentBadge: true,
      defaultPresentSound: false,
      defaultPresentBanner: false,
      defaultPresentList: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notificationPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification selected: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );

      await _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    }

    _pluginInitialized = true;
  }

  Future<bool> requestNotificationPermission() async {
    await initializeSystemNotifications();

    if (Platform.isAndroid) {
      final androidPlugin = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final result = await androidPlugin?.requestNotificationsPermission();

      // On Android versions before runtime notification permission,
      // the plugin may return null.
      _notificationPermissionGranted = result ?? true;
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final result = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: false,
      );

      _notificationPermissionGranted = result ?? false;
    } else if (Platform.isMacOS) {
      final macPlugin = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();

      final result = await macPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: false,
      );

      _notificationPermissionGranted = result ?? false;
    } else {
      _notificationPermissionGranted = true;
    }

    notifyListeners();
    return _notificationPermissionGranted;
  }

  Future<void> _updateSystemBadge() async {
    await initializeSystemNotifications();

    final count = unreadCount;

    if (count <= 0) {
      await _clearSystemBadge();
      return;
    }

    if (!_notificationPermissionGranted) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        channelShowBadge: true,
        number: count,
        silent: true,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
        autoCancel: false,
        ongoing: false,
      ),
      iOS: DarwinNotificationDetails(
        badgeNumber: count,
        presentAlert: false,
        presentBadge: true,
        presentSound: false,
        presentBanner: false,
        presentList: false,
      ),
      macOS: DarwinNotificationDetails(
        badgeNumber: count,
        presentAlert: false,
        presentBadge: true,
        presentSound: false,
        presentBanner: false,
        presentList: false,
      ),
    );

    await _notificationPlugin.show(
      id: _systemNotificationId,
      title: 'Room Booking',
      body: 'You have $count unread notification${count == 1 ? '' : 's'}.',
      notificationDetails: details,
      payload: 'notifications',
    );
  }

  Future<void> _clearSystemBadge() async {
    await initializeSystemNotifications();

    await _notificationPlugin.cancel(id: _systemNotificationId);

    if (!_notificationPermissionGranted) {
      return;
    }

    // iOS/macOS badge clearing requires applying badgeNumber: 0.
    if (Platform.isIOS || Platform.isMacOS) {
      const details = NotificationDetails(
        iOS: DarwinNotificationDetails(
          badgeNumber: 0,
          presentAlert: false,
          presentBadge: true,
          presentSound: false,
          presentBanner: false,
          presentList: false,
        ),
        macOS: DarwinNotificationDetails(
          badgeNumber: 0,
          presentAlert: false,
          presentBadge: true,
          presentSound: false,
          presentBanner: false,
          presentList: false,
        ),
      );

      await _notificationPlugin.show(
        id: _systemNotificationId,
        title: null,
        body: null,
        notificationDetails: details,
      );

      await _notificationPlugin.cancel(id: _systemNotificationId);
    }
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (_fetching) return;

    _fetching = true;
    final requestGeneration = _requestGeneration;

    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }

    try {
      final result = await _service.getNotifications();

      if (requestGeneration != _requestGeneration) {
        return;
      }

      notifications = result;
      error = null;

      await _updateSystemBadge();
    } catch (e) {
      if (requestGeneration != _requestGeneration) {
        return;
      }

      error = _cleanError(e);
    } finally {
      _fetching = false;

      if (requestGeneration == _requestGeneration) {
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

      await _updateSystemBadge();
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

    await _clearSystemBadge();

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
    _notificationPlugin.cancel(id: _systemNotificationId);
    super.dispose();
  }
}
