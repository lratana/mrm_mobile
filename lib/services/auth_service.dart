import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthResult {
  final String token;
  final AppUser? user;
  final String? message;

  const AuthResult({required this.token, this.user, this.message});
}

class AuthService {
  final ApiService _api = ApiService.instance;

  // ---------------------------
  // LOGIN (FIXED)
  // ---------------------------
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      AppConstants.loginPath,
      body: {'email': email.trim(), 'password': password},
    );

    final map = _asMap(response);
    final token = _extractToken(map);

    if (token == null || token.isEmpty) {
      throw const ApiException('Login succeeded but token is missing');
    }

    // ✅ FIX #1: SAVE TOKEN TO STORAGE
    await _api.setToken(token);

    final userMap = _extractUserMap(map);

    return AuthResult(
      token: token,
      user: _safeUser(userMap),
      message: map['message']?.toString(),
    );
  }

  // ---------------------------
  // REGISTER (FIXED)
  // ---------------------------
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _api.post(
      AppConstants.registerPath,
      body: {
        'name': name.trim(),
        'full_name': name.trim(),
        'email': email.trim(),
        'phone': phoneNumber.trim(),
        'password': password,
        'password_confirmation': password,
      },
    );

    final map = _asMap(response);
    final token = _extractToken(map);

    final userMap = _extractUserMap(map);

    // ✅ FIX #2: IF TOKEN EXISTS SAVE IT
    if (token != null && token.isNotEmpty) {
      await _api.setToken(token);
    }

    return AuthResult(
      token: token ?? '',
      user: _safeUser(userMap),
      message: map['message']?.toString() ?? 'Success',
    );
  }

  // ---------------------------
  // UPDATE PROFILE (SAFE FIX)
  // ---------------------------
  Future<AppUser?> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    String? imagePath,
  }) async {
    final response = await _api.multipartPost(
      AppConstants.updateProfilePath,
      fields: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': email.trim(),
        'password': phoneNumber.trim(),
      },
      files: imagePath == null || imagePath.isEmpty
          ? null
          : {'photo': imagePath},
    );

    final map = _asMap(response);
    final userMap = _extractUserMap(map);

    return _safeUser(userMap);
  }

  // ---------------------------
  // FORGOT PASSWORD
  // ---------------------------
  Future<String> forgotPassword(String email) async {
    final response = await _api.post(
      AppConstants.forgotPasswordPath,
      body: {'email': email.trim()},
    );

    if (response is Map && response['message'] != null) {
      return response['message'].toString();
    }

    return 'Password reset link sent to your email.';
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _api.post(
      AppConstants.resetPasswordPath,
      body: {
        'email': email.trim(),
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return <String, dynamic>{};
  }

  // ---------------------------
  // LOGOUT (FIXED)
  // ---------------------------
  Future<void> logout() async {
    try {
      await _api.post(AppConstants.logoutPath);
    } catch (_) {}

    // ✅ always clear token locally
    await _api.clearToken();
  }

  // ---------------------------
  // SAFE HELPERS
  // ---------------------------
  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  AppUser? _safeUser(dynamic value) {
    try {
      if (value is Map) {
        return AppUser.fromJson(Map<String, dynamic>.from(value));
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic>? _extractUserMap(Map<String, dynamic> map) {
    final data = map['data'];

    final candidates = [
      map['user'],
      data is Map ? data['user'] : null,
      data is Map ? data['data'] : null,
      data is Map ? data['profile'] : null,
    ];

    for (final item in candidates) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
    }

    return null;
  }

  String? _extractToken(Map<String, dynamic> map) {
    final data = map['data'];

    final candidates = [
      map['token'],
      map['access_token'],
      map['plainTextToken'],
      map['plain_text_token'],
      data is Map ? data['token'] : null,
      data is Map ? data['access_token'] : null,
      data is Map ? data['plainTextToken'] : null,
      data is Map ? data['plain_text_token'] : null,
    ];

    for (final item in candidates) {
      final text = item?.toString();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }
}
