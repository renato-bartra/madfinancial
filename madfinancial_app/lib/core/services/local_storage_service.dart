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
        onUpgrade: _onUpgrade,
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

    await _createMovementsSchema(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createMovementsSchema(db);
    }
  }

  Future<void> _createMovementsSchema(Database db) async {
    await db.execute('''
      CREATE TABLE ${StorageConstants.categoriesTable} (
        id INTEGER PRIMARY KEY,
        is_expense INTEGER NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StorageConstants.tagsTable} (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StorageConstants.movementsTable} (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        accounting_date TEXT NOT NULL,
        type_id INTEGER NOT NULL,
        type_description TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        category_is_expense INTEGER NOT NULL,
        category_description TEXT NOT NULL,
        account_id INTEGER NOT NULL,
        account_description TEXT NOT NULL,
        active INTEGER,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_movements_accounting_date
      ON ${StorageConstants.movementsTable} (accounting_date)
    ''');

    await db.execute('''
      CREATE TABLE ${StorageConstants.movementTagsTable} (
        movement_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        tag_description TEXT NOT NULL,
        PRIMARY KEY (movement_id, tag_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StorageConstants.submovementsTable} (
        id INTEGER NOT NULL,
        movement_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        category_is_expense INTEGER NOT NULL,
        category_description TEXT NOT NULL,
        PRIMARY KEY (id, movement_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StorageConstants.submovementTagsTable} (
        submovement_id INTEGER NOT NULL,
        movement_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        tag_description TEXT NOT NULL,
        PRIMARY KEY (submovement_id, movement_id, tag_id)
      )
    ''');
  }

  Future<Database> get rawDb => _db;

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
    await db.insert(
      StorageConstants.appFlagsTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  Future<bool> getCarryOverEnabled() async {
    final value = await getFlag(StorageConstants.carryOverEnabledKey);
    return value == 'true';
  }

  Future<void> setCarryOverEnabled(bool value) {
    return setFlag(StorageConstants.carryOverEnabledKey, value ? 'true' : 'false');
  }
}
