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
          'body': {'error': 'Vui long nhap day du thong tin'},
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
          'body': {'error': 'Tai khoan da ton tai'},
        };
      }

      await db.insert('users', {
        'name': normalizedName,
        'email': normalizedEmail,
        'password': normalizedPassword,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      return {'ok': true};
    } catch (e) {
      debugPrint('Register error: $e');
      return {
        'ok': false,
        'body': {'error': 'Dang ky that bai: $e'},
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
        columns: ['name', 'email'],
        where: 'email = ? AND password = ?',
        whereArgs: [normalizedEmail, normalizedPassword],
        limit: 1,
      );

      if (users.isEmpty) {
        return {
          'ok': false,
          'body': {'error': 'Tai khoan hoac mat khau chua chinh xac'},
        };
      }

      final user = users.first;
      return {
        'ok': true,
        'name': (user['name'] ?? user['email'] ?? normalizedEmail).toString(),
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'ok': false,
        'body': {'error': 'Dang nhap that bai: $e'},
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
          'body': {'error': 'Vui long nhap day du thong tin'},
        };
      }

      final existed = _webUsersMemory.any(
        (u) => (u['email'] ?? '').toString().toLowerCase() == normalizedEmail,
      );
      if (existed) {
        return {
          'ok': false,
          'body': {'error': 'Tai khoan da ton tai'},
        };
      }

      _webUsersMemory.add({
        'name': normalizedName,
        'email': normalizedEmail,
        'password': normalizedPassword,
        'created_at': DateTime.now().toIso8601String(),
      });
      return {'ok': true};
    } catch (e) {
      debugPrint('Register web error: $e');
      return {
        'ok': false,
        'body': {'error': 'Dang ky that bai: $e'},
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
          'body': {'error': 'Tai khoan hoac mat khau chua chinh xac'},
        };
      }

      return {
        'ok': true,
        'name': (matched['name'] ?? matched['email'] ?? normalizedEmail)
            .toString(),
      };
    } catch (e) {
      debugPrint('Login web error: $e');
      return {
        'ok': false,
        'body': {'error': 'Dang nhap that bai: $e'},
      };
    }
  }
}
