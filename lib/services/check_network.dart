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
    // Prevent duplicate listeners
    await _subscription?.cancel();

    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnection(results);

      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateConnection,
        onError: (_) {
          _setOffline();
        },
      );
    } catch (_) {
      _setOffline();
    }
  }

  Future<bool> checkNetwork() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnection(results);
    } catch (_) {
      _setOffline();
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

  void _setOffline() {
    final changed = !_initialized || _isOnline != false;

    _isOnline = false;
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
