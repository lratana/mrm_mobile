import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class CheckNetwork extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool _initialized = false;

  bool get isOnline => _isOnline;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnection(results);

      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateConnection,
      );
    } catch (e) {
      _isOnline = false;
      _initialized = true;
      notifyListeners();

      debugPrint('Network initialization error: $e');
    }
  }

  Future<bool> checkNetwork() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnection(results);
    } catch (e) {
      _isOnline = false;
      _initialized = true;
      notifyListeners();

      debugPrint('Network check error: $e');
    }

    return _isOnline;
  }

  void _updateConnection(List<ConnectivityResult> results) {
    final online =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    final changed = !_initialized || _isOnline != online;

    _isOnline = online;
    _initialized = true;

    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
