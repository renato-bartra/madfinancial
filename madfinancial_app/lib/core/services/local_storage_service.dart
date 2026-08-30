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

    await _createAccountsSchema(db);
    await _createMovementsSchema(db);

    await db.insert(StorageConstants.accountsTable, {
      'id': StorageConstants.defaultSueldoAccountId,
      'description': 'Sueldo',
    });
    await db.insert(StorageConstants.accountsTable, {
      'id': StorageConstants.defaultAhorrosAccountId,
      'description': 'Ahorros',
    });
    await db.insert(StorageConstants.appFlagsTable, {
      'key': StorageConstants.defaultAccountIdKey,
      'value': StorageConstants.defaultSueldoAccountId.toString(),
    });
    await db.insert(StorageConstants.appFlagsTable, {
      'key': StorageConstants.homeAccountIdsKey,
      'value': StorageConstants.defaultHomeAccountIds.join(','),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createAccountsSchema(db);
      await _createMovementsSchema(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
    if (oldVersion < 5) {
      await _migrateToV5(db);
    }
  }

  Future<void> _migrateToV3(Database db) async {
    if (!(await _columnExists(
      db,
      StorageConstants.categoriesTable,
      'icon_name',
    ))) {
      await db.execute(
        'ALTER TABLE ${StorageConstants.categoriesTable} ADD COLUMN icon_name TEXT',
      );
    }
    if (!(await _columnExists(
      db,
      StorageConstants.movementsTable,
      'category_icon_name',
    ))) {
      await db.execute(
        'ALTER TABLE ${StorageConstants.movementsTable} '
        'ADD COLUMN category_icon_name TEXT',
      );
    }
    if (!(await _columnExists(
      db,
      StorageConstants.submovementsTable,
      'category_icon_name',
    ))) {
      await db.execute(
        'ALTER TABLE ${StorageConstants.submovementsTable} '
        'ADD COLUMN category_icon_name TEXT',
      );
    }
    await db.delete(StorageConstants.movementTagsTable);
    await db.delete(StorageConstants.submovementTagsTable);
    await db.delete(StorageConstants.submovementsTable);
    await db.delete(StorageConstants.movementsTable);
    await db.delete(StorageConstants.categoriesTable);
  }

  Future<void> _migrateToV5(Database db) async {
    if (!(await _tableExists(db, StorageConstants.accountsTable))) {
      await _createAccountsSchema(db);
    }
    if (!(await _accountExists(db, StorageConstants.defaultSueldoAccountId))) {
      await db.insert(StorageConstants.accountsTable, {
        'id': StorageConstants.defaultSueldoAccountId,
        'description': 'Sueldo',
      });
    }
    if (!(await _accountExists(db, StorageConstants.defaultAhorrosAccountId))) {
      await db.insert(StorageConstants.accountsTable, {
        'id': StorageConstants.defaultAhorrosAccountId,
        'description': 'Ahorros',
      });
    }

    await db.execute(
      "UPDATE ${StorageConstants.movementsTable} "
      "SET account_id = ${StorageConstants.defaultSueldoAccountId}, "
      "account_description = 'Sueldo' "
      "WHERE account_id IS NULL OR account_description = ''",
    );

    if (!(await _columnExists(
      db,
      StorageConstants.movementsTable,
      'transfer_uuid',
    ))) {
      await db.execute(
        'ALTER TABLE ${StorageConstants.movementsTable} '
        'ADD COLUMN transfer_uuid TEXT',
      );
    }

    if ((await _flagValue(db, StorageConstants.defaultAccountIdKey)) == null) {
      await db.insert(StorageConstants.appFlagsTable, {
        'key': StorageConstants.defaultAccountIdKey,
        'value': StorageConstants.defaultSueldoAccountId.toString(),
      });
    }
    if ((await _flagValue(db, StorageConstants.homeAccountIdsKey)) == null) {
      await db.insert(StorageConstants.appFlagsTable, {
        'key': StorageConstants.homeAccountIdsKey,
        'value': StorageConstants.defaultHomeAccountIds.join(','),
      });
    }
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((row) => row['name'] == column);
  }

  Future<bool> _tableExists(Database db, String table) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return rows.isNotEmpty;
  }

  Future<bool> _accountExists(Database db, int id) async {
    final rows = await db.query(
      StorageConstants.accountsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<String?> _flagValue(Database db, String key) async {
    final rows = await db.query(
      StorageConstants.appFlagsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _createAccountsSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.accountsTable} (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createMovementsSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.categoriesTable} (
        id INTEGER PRIMARY KEY,
        is_expense INTEGER NOT NULL,
        description TEXT NOT NULL,
        icon_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.tagsTable} (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.movementsTable} (
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
        category_icon_name TEXT,
        account_id INTEGER NOT NULL,
        account_description TEXT NOT NULL,
        active INTEGER,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        transfer_uuid TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_movements_accounting_date
      ON ${StorageConstants.movementsTable} (accounting_date)
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.movementTagsTable} (
        movement_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        tag_description TEXT NOT NULL,
        PRIMARY KEY (movement_id, tag_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.submovementsTable} (
        id INTEGER NOT NULL,
        movement_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        category_is_expense INTEGER NOT NULL,
        category_description TEXT NOT NULL,
        category_icon_name TEXT,
        PRIMARY KEY (id, movement_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageConstants.submovementTagsTable} (
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

  Future<int> getDefaultAccountId() async {
    final value = await getFlag(StorageConstants.defaultAccountIdKey);
    if (value == null) {
      return StorageConstants.defaultSueldoAccountId;
    }
    return int.tryParse(value) ?? StorageConstants.defaultSueldoAccountId;
  }

  Future<void> setDefaultAccountId(int id) {
    return setFlag(StorageConstants.defaultAccountIdKey, id.toString());
  }

  Future<List<int>> getHomeAccountIds() async {
    final value = await getFlag(StorageConstants.homeAccountIdsKey);
    if (value == null || value.isEmpty) {
      return List.of(StorageConstants.defaultHomeAccountIds);
    }
    final parsed = value
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    if (parsed.isEmpty) {
      return List.of(StorageConstants.defaultHomeAccountIds);
    }
    return parsed;
  }

  Future<void> setHomeAccountIds(List<int> ids) {
    return setFlag(StorageConstants.homeAccountIdsKey, ids.join(','));
  }
}
