import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();
  static Database _db;
  final _dbFile = 'auth.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();

    return _db;
  }

  factory AuthProvider() => _instance;

  AuthProvider._internal();

  Future<Database> initDb() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _dbFile);

      return await openDatabase(path, version: 1, onCreate: _onCreate);
    } on MissingPluginException {
      return null;
    }
  }

  Future<String> deleteDb() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _dbFile);

      await deleteDatabase(path);
      _db = null;

      return path;
    } on MissingPluginException {
      return null;
    }
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Auth(id INTEGER PRIMARY KEY, access_token TEXT, refresh_token TEXT, expires_at INTEGER);');

    print('Created tables');
  }

  Future<Map<String, dynamic>> getAuth() async {
    final dbClient = await db;
    final result = await dbClient?.query('Auth', limit: 1);

    return result?.isNotEmpty == true ? result.first : null;
  }

  Future<int> saveAuth(Map<String, dynamic> auth) async {
    final dbClient = await db;

    await dbClient?.delete('Auth');

    return await dbClient?.insert('Auth', auth);
  }

  Future<void> deleteAuth() async {
    final dbClient = await db;

    await dbClient?.delete('Auth');
  }
}
