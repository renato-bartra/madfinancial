import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../constants/storage_constants.dart';
import '../errors/exceptions.dart';
import 'auth_session.dart';

class LocalStorageService {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    try {
      final dbPath = await getDatabasesPath();
      final fullPath = path.join(dbPath, StorageConstants.databaseName);
      _database = await openDatabase(
        fullPath,
        version: StorageConstants.databaseVersion,
        onCreate: _onCreate,
      );
      return _database!;
    } catch (error) {
      throw CacheException('No se pudo abrir la base local: $error');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${StorageConstants.authSessionsTable} (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        email TEXT NOT NULL,
        token TEXT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        login_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StorageConstants.appFlagsTable} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveSession(AuthSession session) async {
    final db = await _db;
    await db.insert(
      StorageConstants.authSessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AuthSession?> getSession() async {
    final db = await _db;
    final result = await db.query(StorageConstants.authSessionsTable, limit: 1);

    if (result.isEmpty) return null;
    return AuthSession.fromMap(result.first);
  }

  Future<void> clearSession() async {
    final db = await _db;
    await db.delete(StorageConstants.authSessionsTable);
  }

  Future<void> setFlag(String key, String value) async {
    final db = await _db;
    await db.insert(StorageConstants.appFlagsTable, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getFlag(String key) async {
    final db = await _db;
    final result = await db.query(
      StorageConstants.appFlagsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }
}
