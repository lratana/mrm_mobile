import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanBase = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    final uri = Uri.parse('$cleanBase/$cleanPath');

    if (query == null || query.isEmpty) {
      return uri;
    }

    final params = <String, String>{};

    query.forEach((key, value) {
      if (value == null) return;

      final text = value.toString();

      if (text.isNotEmpty) {
        params[key] = text;
      }
    });

    return uri.replace(queryParameters: params);
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final decoded = _decode(response);

    String message = 'Request failed';

    if (decoded is Map && decoded['message'] != null) {
      message = decoded['message'].toString();
    } else if (decoded is Map && decoded['error'] != null) {
      message = decoded['error'].toString();
    }

    throw ApiException(message, statusCode: response.statusCode, body: decoded);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await http
          .get(_uri(path, query), headers: _headers)
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(response);

      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Request timeout. Please try again.');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(response);

      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Request timeout. Please try again.');
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .put(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(response);

      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Request timeout. Please try again.');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await http
          .delete(_uri(path), headers: _headers)
          .timeout(AppConstants.requestTimeout);

      _throwIfFailed(response);

      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Request timeout. Please try again.');
    }
  }

  Future<dynamic> multipartPost(
    String path, {
    Map<String, String>? fields,
    Map<String, String>? files,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));

      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null && _token!.isNotEmpty)
          'Authorization': 'Bearer $_token',
      });

      request.fields.addAll(fields ?? {});

      for (final entry in (files ?? {}).entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }

      final streamed = await request.send().timeout(
        AppConstants.requestTimeout,
      );

      final response = await http.Response.fromStream(streamed);

      _throwIfFailed(response);

      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Request timeout. Please try again.');
    }
  }
}
