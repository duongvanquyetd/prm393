import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'local_db_service.dart';

class AuthService {
  static final List<Map<String, dynamic>> _webUsersMemory =
  <Map<String, dynamic>>[];

  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      ) async {
    if (kIsWeb) {
      return _registerWeb(name, email, password);
    }

    try {
      final normalizedName = name.trim();
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();

      if (normalizedName.isEmpty ||
          normalizedEmail.isEmpty ||
          normalizedPassword.isEmpty) {
        return {
          'ok': false,
          'body': {'error': 'Vui lòng nhập đầy đủ thông tin'},
        };
      }

      final db = await LocalDbService.instance.database;

      final existing = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [normalizedEmail],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        return {
          'ok': false,
          'body': {'error': 'Tài khoản đã tồn tại'},
        };
      }

      await db.insert(
        'users',
        {
          'name': normalizedName,
          'email': normalizedEmail,
          'password': normalizedPassword,
          'price': 12500,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return {'ok': true};
    } catch (e) {
      debugPrint('Register error: $e');
      return {
        'ok': false,
        'body': {'error': 'Đăng ký thất bại: $e'},
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    if (kIsWeb) {
      return _loginWeb(email, password);
    }

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();

      final db = await LocalDbService.instance.database;

      final users = await db.query(
        'users',
        columns: ['id', 'name', 'email', 'password', 'price'],
        where: 'email = ? AND password = ?',
        whereArgs: [normalizedEmail, normalizedPassword],
        limit: 1,
      );

      if (users.isEmpty) {
        return {
          'ok': false,
          'body': {'error': 'Tài khoản hoặc mật khẩu chưa chính xác'},
        };
      }

      final user = users.first;

      return {
        'ok': true,
        'userId': user['id'],
        'name': (user['name'] ?? user['email'] ?? normalizedEmail).toString(),
        'email': (user['email'] ?? normalizedEmail).toString(),
        'price': ((user['price'] ?? 12500) as num).toDouble(),
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'ok': false,
        'body': {'error': 'Đăng nhập thất bại: $e'},
      };
    }
  }

  static Future<Map<String, dynamic>> _registerWeb(
      String name,
      String email,
      String password,
      ) async {
    try {
      final normalizedName = name.trim();
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();

      if (normalizedName.isEmpty ||
          normalizedEmail.isEmpty ||
          normalizedPassword.isEmpty) {
        return {
          'ok': false,
          'body': {'error': 'Vui lòng nhập đầy đủ thông tin'},
        };
      }

      final existed = _webUsersMemory.any(
            (u) => (u['email'] ?? '').toString().toLowerCase() == normalizedEmail,
      );

      if (existed) {
        return {
          'ok': false,
          'body': {'error': 'Tài khoản đã tồn tại'},
        };
      }

      _webUsersMemory.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': normalizedName,
        'email': normalizedEmail,
        'password': normalizedPassword,
        'price': 12500.0,
      });

      return {'ok': true};
    } catch (e) {
      debugPrint('Register web error: $e');
      return {
        'ok': false,
        'body': {'error': 'Đăng ký thất bại: $e'},
      };
    }
  }

  static Future<Map<String, dynamic>> _loginWeb(
      String email,
      String password,
      ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();

      final matched = _webUsersMemory.cast<Map<String, dynamic>?>().firstWhere(
            (u) =>
        u != null &&
            (u['email'] ?? '').toString().toLowerCase() == normalizedEmail &&
            (u['password'] ?? '').toString() == normalizedPassword,
        orElse: () => null,
      );

      if (matched == null) {
        return {
          'ok': false,
          'body': {'error': 'Tài khoản hoặc mật khẩu chưa chính xác'},
        };
      }

      return {
        'ok': true,
        'userId': matched['id'],
        'name': (matched['name'] ?? matched['email'] ?? normalizedEmail)
            .toString(),
        'email': (matched['email'] ?? normalizedEmail).toString(),
        'price': ((matched['price'] ?? 12500) as num).toDouble(),
      };
    } catch (e) {
      debugPrint('Login web error: $e');
      return {
        'ok': false,
        'body': {'error': 'Đăng nhập thất bại: $e'},
      };
    }
  }
}