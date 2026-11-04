
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/user_account.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Local authentication service for the CEE classroom project.
/// Supports Android and Chrome Web.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _databaseName = 'cee_accounts.db';
  static const String _sessionTable = 'app_session';
  static const String _usersTable = 'users';
  static const int _databaseVersion = 1;
  static const int _saltLength = 16;

  final Random _secureRandom = Random.secure();

  final Pbkdf2 _passwordHasher = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  Database? _database;

  Future<void> initialize() async {
    if (_database != null) return;

    final String databasePath;

    if (kIsWeb) {
      databasePath = _databaseName;
    } else {
      final databaseDirectory = await getDatabasesPath();
      databasePath = path.join(databaseDirectory, _databaseName);
    }

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_usersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password_salt TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_sessionTable (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            user_id INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Database get _db {
    final database = _database;

    if (database == null) {
      throw StateError('AuthService has not been initialized.');
    }

    return database;
  }

  Future<UserAccount> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await initialize();

    final cleanName = fullName.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please complete all fields.');
    }

    if (password.length < 8) {
      throw const AuthException(
        'Your password must contain at least 8 characters.',
      );
    }

    final existingUsers = await _db.query(
      _usersTable,
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );

    if (existingUsers.isNotEmpty) {
      throw const AuthException(
        'An account with this email already exists.',
      );
    }

    final salt = List<int>.generate(
      _saltLength,
      (_) => _secureRandom.nextInt(256),
    );

    final passwordHash = await _hashPassword(password, salt);
    final createdAt = DateTime.now().toUtc();

    final userId = await _db.transaction((transaction) async {
      final newUserId = await transaction.insert(_usersTable, {
        'full_name': cleanName,
        'email': cleanEmail,
        'password_salt': _toHex(salt),
        'password_hash': _toHex(passwordHash),
        'created_at': createdAt.toIso8601String(),
      });

      await transaction.insert(
        _sessionTable,
        {'id': 1, 'user_id': newUserId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return newUserId;
    });

    return UserAccount(
      id: userId,
      fullName: cleanName,
      email: cleanEmail,
      createdAt: createdAt,
    );
  }

  Future<UserAccount> signIn({
    required String email,
    required String password,
  }) async {
    await initialize();

    final cleanEmail = email.trim().toLowerCase();

    final results = await _db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );

    if (results.isEmpty) {
      throw const AuthException(
        'Email or password is incorrect.',
      );
    }

    final row = results.first;

    final salt = _fromHex(row['password_salt'] as String);
    final storedHash = _fromHex(row['password_hash'] as String);
    final enteredHash = await _hashPassword(password, salt);

    if (!_constantTimeEquals(storedHash, enteredHash)) {
      throw const AuthException(
        'Email or password is incorrect.',
      );
    }

    final user = UserAccount.fromMap(row);

    await _saveSession(user.id);

    return user;
  }

  Future<UserAccount?> getCurrentUser() async {
    await initialize();

    final sessions = await _db.query(
      _sessionTable,
      where: 'id = 1',
      limit: 1,
    );

    if (sessions.isEmpty) return null;

    final userId = sessions.first['user_id'] as int;

    final results = await _db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) {
      await signOut();
      return null;
    }

    return UserAccount.fromMap(results.first);
  }

  Future<void> signOut() async {
    await initialize();

    await _db.delete(
      _sessionTable,
      where: 'id = 1',
    );
  }

  Future<void> _saveSession(int userId) async {
    await _db.insert(
      _sessionTable,
      {'id': 1, 'user_id': userId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<int>> _hashPassword(
    String password,
    List<int> salt,
  ) async {
    final secretKey = await _passwordHasher.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    return secretKey.extractBytes();
  }

  String _toHex(List<int> bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  List<int> _fromHex(String value) {
    return List<int>.generate(
      value.length ~/ 2,
      (index) => int.parse(
        value.substring(index * 2, index * 2 + 2),
        radix: 16,
      ),
    );
  }

  bool _constantTimeEquals(
    List<int> first,
    List<int> second,
  ) {
    if (first.length != second.length) return false;

    var difference = 0;

    for (var index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }

    return difference == 0;
  }
}
