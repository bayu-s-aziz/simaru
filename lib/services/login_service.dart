import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class LoginService extends GetxService {
  Client client = Client();

  static const String _baseUrl = 'http://127.0.0.1:8001/api';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final decoded = _decodeToMap(response.body);
        if (decoded == null) {
          _log('Login succeeded but response is not a JSON object');
          return null;
        }

        final token = _extractToken(decoded);
        final existingName = _resolveName(decoded);

        if ((existingName == null || existingName.isEmpty) &&
            token != null &&
            token.isNotEmpty) {
          final profile = await _fetchCurrentUser(token);
          if (profile != null && profile.isNotEmpty) {
            decoded['user'] = profile;
          }
        }

        return decoded; // Kembalikan body jika sukses
      } else {
        // Log error dan kembalikan null atau data error jika ada
        _log('Login failed: ${response.statusCode}');
        _log('Response body: ${response.body}');
        // Coba decode body jika mungkin berisi pesan error
        return _decodeToMap(response.body);
      }
    } catch (e) {
      _log('Error during login: $e');
      // Lemparkan exception untuk ditangani controller
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  Map<String, dynamic>? _decodeToMap(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      _log('Decoded login payload is not a Map: $decoded');
      return null;
    } catch (e) {
      _log('Failed to decode login payload: $e');
      return null;
    }
  }

  String? _extractToken(Map<String, dynamic> payload) {
    const tokenKeys = [
      'accessToken',
      'access_token',
      'token',
      'api_token',
      'bearer_token',
    ];

    for (final key in tokenKeys) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _fetchCurrentUser(String token) async {
    const profilePaths = ['/user', '/me', '/profile'];

    for (final path in profilePaths) {
      try {
        final response = await client.get(
          Uri.parse('$_baseUrl$path'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final decoded = _decodeToMap(response.body);
          if (decoded != null) {
            return decoded;
          }
        } else {
          _log('Failed to fetch user profile at $path: ${response.statusCode}');
          _log('Profile response body: ${response.body}');
        }
      } catch (e) {
        _log('Error fetching user profile at $path: $e');
      }
    }

    return null;
  }

  String? _resolveName(dynamic payload) {
    if (payload == null) {
      return null;
    }

    if (payload is String) {
      final trimmed = payload.trim();
      return trimmed.isNotEmpty ? trimmed : null;
    }

    if (payload is Iterable) {
      for (final element in payload) {
        final candidate = _resolveName(element);
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
      return null;
    }

    if (payload is Map) {
      for (final entry in payload.entries) {
        final keyString = entry.key.toString().toLowerCase();
        final value = entry.value;

        if (value is String) {
          if ((keyString.contains('name') || keyString.contains('nama')) &&
              value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }

      for (final value in payload.values) {
        if (value is Map || value is Iterable) {
          final nestedName = _resolveName(value);
          if (nestedName != null && nestedName.isNotEmpty) {
            return nestedName;
          }
        }
      }
    }

    return null;
  }

  void _log(String message) {
    debugPrint('LoginService: $message');
  }
}
