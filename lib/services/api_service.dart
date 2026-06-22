import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;

  const ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _token;

  // -------------------------------
  // TOKEN MANAGEMENT (FIX #1)
  // -------------------------------
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // -------------------------------
  // HEADERS
  // -------------------------------
  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // -------------------------------
  // URI BUILDER (FIXED SAFE QUERY)
  // -------------------------------
  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = AppConstants.baseUrl.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.replaceAll(RegExp(r'^/'), '');

    final uri = Uri.parse('$base/$cleanPath');

    if (query == null || query.isEmpty) return uri;

    final params = <String, String>{};

    query.forEach((key, value) {
      if (value == null) return;

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        params[key] = text;
      }
    });

    return uri.replace(queryParameters: params);
  }

  // -------------------------------
  // RESPONSE DECODER
  // -------------------------------
  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  // -------------------------------
  // ERROR HANDLING (IMPROVED DEBUG)
  // -------------------------------
  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final decoded = _decode(response);

    String message = 'Request failed';

    if (decoded is Map) {
      message =
          decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          message;
    }

    // 🔥 IMPORTANT: debug output for production issue
    print('❌ API ERROR: ${response.statusCode}');
    print('❌ BODY: $decoded');

    throw ApiException(message, statusCode: response.statusCode, body: decoded);
  }

  // -------------------------------
  // GET
  // -------------------------------
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await http
          .get(_uri(path, query), headers: _headers)
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(res);
      return _decode(res);
    } on TimeoutException {
      throw const ApiException('Request timeout');
    }
  }

  // -------------------------------
  // POST
  // -------------------------------
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(res);
      return _decode(res);
    } on TimeoutException {
      throw const ApiException('Request timeout');
    }
  }

  // -------------------------------
  // PUT
  // -------------------------------
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .put(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(res);
      return _decode(res);
    } on TimeoutException {
      throw const ApiException('Request timeout');
    }
  }

  // PUT
  // -------------------------------
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .patch(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(res);
      return _decode(res);
    } on TimeoutException {
      throw const ApiException('Request timeout');
    }
  }

  // -------------------------------
  // DELETE
  // -------------------------------
  Future<dynamic> delete(String path) async {
    try {
      final res = await http
          .delete(_uri(path), headers: _headers)
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(res);
      return _decode(res);
    } on TimeoutException {
      throw const ApiException('Request timeout');
    }
  }

  // -------------------------------
  // MULTIPART
  // -------------------------------
  Future<dynamic> multipartPost(
    String path, {
    Map<String, String>? fields,
    Map<String, String>? files,
  }) async {
    try {
      final request = http.MultipartRequest('PATCH', _uri(path));

      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

      request.fields.addAll(fields ?? {});

      for (final e in (files ?? {}).entries) {
        request.files.add(await http.MultipartFile.fromPath(e.key, e.value));
      }

      final streamed = await request.send().timeout(
        AppConstants.requestTimeout,
      );

      final res = await http.Response.fromStream(streamed);

      _throwIfFailed(res);
      return _decode(res);
    } on TimeoutException {
      throw const ApiException('Request timeout');
    }
  }
}
