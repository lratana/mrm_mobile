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
      throw const ApiException(
        'Login succeeded, but no token was returned by the API.',
      );
    }

    final userMap = _extractUserMap(map);

    return AuthResult(
      token: token,
      user: userMap == null ? null : AppUser.fromJson(userMap),
      message: map['message']?.toString(),
    );
  }

  Future<AuthResult?> register({
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
        'phone_number': phoneNumber.trim(),
        'password': password,
        'password_confirmation': password,
      },
    );

    final map = _asMap(response);
    final token = _extractToken(map);
    final userMap = _extractUserMap(map);

    if (token == null || token.isEmpty) {
      return AuthResult(
        token: '',
        user: userMap == null ? null : AppUser.fromJson(userMap),
        message:
            map['message']?.toString() ??
            'Account created successfully. Please sign in.',
      );
    }

    return AuthResult(
      token: token,
      user: userMap == null ? null : AppUser.fromJson(userMap),
      message: map['message']?.toString(),
    );
  }

  Future<String> forgotPassword(String email) async {
    final response = await _api.post(
      AppConstants.forgotPasswordPath,
      body: {'email': email.trim()},
    );

    final map = _asMap(response);

    return map['message']?.toString() ?? 'Password reset link has been sent.';
  }

  Future<void> logout() async {
    try {
      await _api.post(AppConstants.logoutPath);
    } catch (_) {
      // Ignore logout API error.
      // Controller will clear local token and user data.
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
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
      if (item is Map<String, dynamic>) {
        return item;
      }

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
      final text = item?.toString() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }
}
