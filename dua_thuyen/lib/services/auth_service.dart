import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Allow overriding API base URL at runtime:
  // flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000
  static const String _baseFromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  // Fallback to the current machine LAN IP observed in this workspace session.
  // If your Wi-Fi IP changes, pass API_BASE_URL explicitly.
  static const String _lanBase = 'http://192.168.0.172:3000';

  static List<String> get _baseCandidates {
    if (_baseFromDefine.isNotEmpty) return <String>[_baseFromDefine];
    if (kIsWeb) return <String>['http://localhost:3000'];
    // Android emulator default: 10.0.2.2
    // Genymotion emulator host: 10.0.3.2
    return <String>[
      _lanBase,
      'http://10.0.2.2:3000',
      'http://10.0.3.2:3000',
    ];
  }

  static Future<http.Response> _postWithFallback(String path, Map<String, dynamic> payload) async {
    Object? lastError;
    for (final base in _baseCandidates) {
      try {
        return await http
            .post(Uri.parse('$base$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 6));
      } catch (e) {
        lastError = e;
        debugPrint('Request failed on $base$path: $e');
      }
    }
    throw lastError ?? Exception('No API endpoint reachable');
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final res = await _postWithFallback('/register', {'name': name, 'email': email, 'password': password});
      if (res.statusCode == 200) {
        try {
          return jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {
          return {'ok': true};
        }
      }
      // Try parse body for structured error
      try {
        final parsed = jsonDecode(res.body);
        debugPrint('Register failed: ${res.statusCode} $parsed');
        return {'ok': false, 'status': res.statusCode, 'body': parsed};
      } catch (_) {
        debugPrint('Register failed: ${res.statusCode} ${res.body}');
        return {'ok': false, 'status': res.statusCode, 'body': res.body};
      }
    } on TimeoutException {
      debugPrint('Register request timeout');
      return {
        'ok': false,
        'status': 0,
        'body': {
          'error': 'Ket noi server qua lau (timeout). Neu dung Genymotion, thu host 10.0.3.2 hoac dung --dart-define=API_BASE_URL=http://IP_MAY:3000'
        }
      };
    } catch (e) {
      debugPrint('Register request error: $e');
      return {
        'ok': false,
        'status': 0,
        'body': {
          'error': 'Khong ket noi duoc server. Neu dung dien thoai that, hay dung --dart-define=API_BASE_URL=http://IP_MAY_TINH:3000'
        }
      };
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _postWithFallback('/login', {'email': email, 'password': password});
      if (res.statusCode == 200) {
        try {
          return jsonDecode(res.body) as Map<String, dynamic>;
        } catch (_) {
          return {'ok': true};
        }
      }
      try {
        final parsed = jsonDecode(res.body);
        debugPrint('Login failed: ${res.statusCode} $parsed');
        return {'ok': false, 'status': res.statusCode, 'body': parsed};
      } catch (_) {
        debugPrint('Login failed: ${res.statusCode} ${res.body}');
        return {'ok': false, 'status': res.statusCode, 'body': res.body};
      }
    } on TimeoutException {
      debugPrint('Login request timeout');
      return {
        'ok': false,
        'status': 0,
        'body': {
          'error': 'Ket noi server qua lau (timeout). Neu dung Genymotion, thu host 10.0.3.2 hoac dung --dart-define=API_BASE_URL=http://IP_MAY:3000'
        }
      };
    } catch (e) {
      debugPrint('Login request error: $e');
      return {
        'ok': false,
        'status': 0,
        'body': {
          'error': 'Khong ket noi duoc server. Neu dung dien thoai that, hay dung --dart-define=API_BASE_URL=http://IP_MAY_TINH:3000'
        }
      };
    }
  }
}
