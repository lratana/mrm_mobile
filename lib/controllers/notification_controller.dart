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

  // One silent system notification used to maintain unread badge count.
  static const int _badgeNotificationId = 1001;

  // Existing silent badge channel.
  static const String _badgeChannelId = 'unread_notifications_channel';
  static const String _badgeChannelName = 'Unread Notifications';
  static const String _badgeChannelDescription =
      'Shows the number of unread room booking notifications';

  // New visible alert channel.
  // Keep a new channel ID because an old Android low-importance channel
  // cannot be changed into a high-priority sound/vibration channel.
  static const String _alertChannelId = 'room_booking_alerts_v1';
  static const String _alertChannelName = 'Room Booking Alerts';
  static const String _alertChannelDescription =
      'Shows alerts for new room booking notifications';

  List<AppNotification> notifications = [];

  bool loading = false;
  bool _fetching = false;
  bool _pluginInitialized = false;
  bool _notificationPermissionGranted = false;
  bool _hasLoadedInitialNotifications = false;

  String? error;

  Timer? _timer;

  // Prevents requests started before logout from restoring old data.
  int _requestGeneration = 0;

  // Stores unread notification IDs already seen by this app session.
  final Set<String> _knownUnreadIds = <String>{};

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
      '@mipmap/launcher_icon',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: false,
      defaultPresentBadge: false,
      defaultPresentSound: false,
      defaultPresentBanner: false,
      defaultPresentList: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {},
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      const badgeChannel = AndroidNotificationChannel(
        _badgeChannelId,
        _badgeChannelName,
        description: _badgeChannelDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );

      const alertChannel = AndroidNotificationChannel(
        _alertChannelId,
        _alertChannelName,
        description: _alertChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidPlugin?.createNotificationChannel(badgeChannel);
      await androidPlugin?.createNotificationChannel(alertChannel);
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

      // Android versions before Android 13 may return null because
      // runtime notification permission is not required.
      _notificationPermissionGranted = result ?? true;
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final result = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
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
        sound: true,
      );

      _notificationPermissionGranted = result ?? false;
    } else {
      _notificationPermissionGranted = true;
    }

    notifyListeners();

    return _notificationPermissionGranted;
  }

  Future<void> _showVisibleAlert(AppNotification notification) async {
    await initializeSystemNotifications();

    if (!_notificationPermissionGranted) return;

    final notificationId = notification.id.hashCode & 0x7fffffff;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _alertChannelId,
        _alertChannelName,
        channelDescription: _alertChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        channelShowBadge: true,
        number: unreadCount,
        playSound: true,
        enableVibration: true,
        silent: false,
        onlyAlertOnce: false,
        autoCancel: true,
        ongoing: false,
      ),
      iOS: DarwinNotificationDetails(
        badgeNumber: unreadCount,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      ),
      macOS: DarwinNotificationDetails(
        badgeNumber: unreadCount,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      ),
    );

    await _notificationPlugin.show(
      id: notificationId,
      title: notification.title.trim().isEmpty
          ? 'Room Booking'
          : notification.title,
      body: notification.message.trim().isEmpty
          ? 'You have a new notification.'
          : notification.message,
      notificationDetails: details,
      payload: 'notification:${notification.id}',
    );
  }

  Future<void> _updateSystemBadge() async {
    await initializeSystemNotifications();

    final count = unreadCount;

    if (count <= 0) {
      await _clearSystemBadge();
      return;
    }

    if (!_notificationPermissionGranted) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _badgeChannelId,
        _badgeChannelName,
        channelDescription: _badgeChannelDescription,
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
      id: _badgeNotificationId,
      title: 'Room Booking',
      body: 'You have $count unread notification${count == 1 ? '' : 's'}.',
      notificationDetails: details,
      payload: 'notifications',
    );
  }

  Future<void> _clearSystemBadge() async {
    await initializeSystemNotifications();

    await _notificationPlugin.cancel(id: _badgeNotificationId);

    if (!_notificationPermissionGranted) return;

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
        id: _badgeNotificationId,
        title: null,
        body: null,
        notificationDetails: details,
      );

      await _notificationPlugin.cancel(id: _badgeNotificationId);
    }
  }

  Future<void> fetchNotifications({
    bool silent = false,
    bool showAlertsForNewItems = true,
  }) async {
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

      if (requestGeneration != _requestGeneration) return;

      final unreadItems = result
          .where((notification) => notification.isUnread)
          .toList();

      final unreadIds = unreadItems
          .map((notification) => notification.id)
          .toSet();

      final newUnreadItems =
          _hasLoadedInitialNotifications && showAlertsForNewItems
          ? unreadItems
                .where(
                  (notification) => !_knownUnreadIds.contains(notification.id),
                )
                .toList()
          : <AppNotification>[];

      notifications = result;

      _knownUnreadIds
        ..clear()
        ..addAll(unreadIds);

      _hasLoadedInitialNotifications = true;
      error = null;

      await _updateSystemBadge();

      for (final notification in newUnreadItems) {
        await _showVisibleAlert(notification);
      }
    } catch (e) {
      if (requestGeneration != _requestGeneration) return;

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

    // Initial load creates the badge/list only, not alerts for old unread items.
    fetchNotifications(silent: true, showAlertsForNewItems: false);

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchNotifications(silent: true, showAlertsForNewItems: true),
    );
  }

  void stopRealtimeNotifications() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);

      await fetchNotifications(silent: true, showAlertsForNewItems: false);
    } catch (e) {
      error = _cleanError(e);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();

      await fetchNotifications(silent: true, showAlertsForNewItems: false);
    } catch (e) {
      error = _cleanError(e);
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);

      notifications.removeWhere((notification) => notification.id == id);

      _knownUnreadIds.remove(id);

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
    _knownUnreadIds.clear();
    _hasLoadedInitialNotifications = false;

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

    _notificationPlugin.cancel(id: _badgeNotificationId);

    super.dispose();
  }
}
