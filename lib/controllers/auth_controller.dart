import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool initializing = true;
  bool loading = false;

  String? error;
  String? successMessage;
  String? token;

  AppUser? user;

  /// Check authentication status
  bool get isAuthenticated => token?.isNotEmpty ?? false;

  /// Initialize app session
  Future<void> initialize() async {
    initializing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      token = prefs.getString('auth_token');

      final userJson = prefs.getString('auth_user');

      if (userJson != null && userJson.isNotEmpty) {
        try {
          user = AppUser.fromJson(
            Map<String, dynamic>.from(jsonDecode(userJson)),
          );
        } catch (_) {
          user = null;
        }
      }

      if (token != null && token!.isNotEmpty) {
        ApiService.instance.setToken(token!);
      }
    } catch (e) {
      error = _cleanError(e);
    } finally {
      initializing = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? imagePath,
  }) async {
    loading = true;
    error = null;
    successMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _service.updateProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        imagePath: imagePath,
      );

      if (updatedUser != null) {
        user = updatedUser;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user', jsonEncode(updatedUser.toJson()));
      }

      successMessage = 'Profile updated successfully.';
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Login
  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    successMessage = null;

    notifyListeners();

    try {
      final result = await _service.login(email: email, password: password);

      await _saveSession(result.token, result.user);

      successMessage = result.message ?? 'Signed in successfully.';

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    loading = true;
    error = null;
    successMessage = null;

    notifyListeners();

    try {
      final result = await _service.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (result.token.isNotEmpty) {
        await _saveSession(result.token, result.user);
      }

      successMessage =
          result.message ?? 'Account created successfully. Please sign in.';

      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Forgot password
  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    loading = true;
    error = null;
    successMessage = null;

    notifyListeners();

    try {
      successMessage = await _service.forgotPassword(email.trim());
      return true;
    } catch (e) {
      error = _cleanError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    loading = true;
    error = null;
    successMessage = null;
    notifyListeners();

    try {
      final response = await _service.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      successMessage =
          response['message']?.toString() ?? 'Password reset successfully.';

      loading = false;
      notifyListeners();

      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();

      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    loading = true;
    notifyListeners();

    try {
      await _service.logout();
    } catch (_) {
      // Ignore server logout errors
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('auth_user');

    ApiService.instance.clearToken();

    token = null;
    user = null;
    error = null;
    successMessage = null;

    loading = false;

    notifyListeners();
  }

  /// Save user session
  Future<void> _saveSession(String newToken, AppUser? newUser) async {
    token = newToken;
    user = newUser;

    ApiService.instance.setToken(newToken);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', newToken);

    if (newUser != null) {
      await prefs.setString('auth_user', jsonEncode(newUser.toJson()));
    } else {
      await prefs.remove('auth_user');
    }
  }

  /// Clean error message
  String _cleanError(Object e) {
    final text = e.toString();

    return text
        .replaceFirst('Exception: ', '')
        .replaceFirst(RegExp(r'ApiException\(\d+\):\s*'), '');
  }
}
