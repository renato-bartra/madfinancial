import 'package:sqflite/sqflite.dart';

import '../constants/storage_constants.dart';
import '../../features/movements/domain/entities/account.dart';
import '../../features/movements/domain/entities/category.dart';
import '../../features/movements/domain/entities/movement.dart';
import '../../features/movements/domain/entities/movement_type.dart';
import '../../features/movements/domain/entities/submovement.dart';
import '../../features/movements/domain/entities/tag.dart';
import 'local_storage_service.dart';

class MovementLocalDao {
  const MovementLocalDao(this._storage);

  final LocalStorageService _storage;

  Future<Database> get _db => _storage.rawDb;

  Future<List<Movement>> getMovementsByMonth(DateTime month) async {
    final db = await _db;
    final firstDay = DateTime(month.year, month.month, 1);
    final firstDayNext = DateTime(month.year, month.month + 1, 1);
    final startIso =
        '${firstDay.year.toString().padLeft(4, '0')}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}';
    final endIso =
        '${firstDayNext.year.toString().padLeft(4, '0')}-${firstDayNext.month.toString().padLeft(2, '0')}-${firstDayNext.day.toString().padLeft(2, '0')}';

    final rows = await db.query(
      StorageConstants.movementsTable,
      where: 'accounting_date >= ? AND accounting_date < ?',
      whereArgs: [startIso, endIso],
      orderBy: 'accounting_date DESC, id DESC',
    );

    final result = <Movement>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final tags = await _loadMovementTags(db, id);
      final submovements = await _loadSubmovements(db, id);
      result.add(_rowToMovement(row, tags, submovements));
    }
    return result;
  }

  Future<bool> hasMovementsForMonth(DateTime month) async {
    final db = await _db;
    final firstDay = DateTime(month.year, month.month, 1);
    final firstDayNext = DateTime(month.year, month.month + 1, 1);
    final startIso =
        '${firstDay.year.toString().padLeft(4, '0')}-${firstDay.month.toString().padLeft(2, '0')}-${firstDay.day.toString().padLeft(2, '0')}';
    final endIso =
        '${firstDayNext.year.toString().padLeft(4, '0')}-${firstDayNext.month.toString().padLeft(2, '0')}-${firstDayNext.day.toString().padLeft(2, '0')}';
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${StorageConstants.movementsTable} '
      'WHERE accounting_date >= ? AND accounting_date < ?',
      [startIso, endIso],
    );
    final count = (result.first['c'] as int?) ?? 0;
    return count > 0;
  }

  Future<void> saveMovement(Movement movement) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        StorageConstants.movementTagsTable,
        where: 'movement_id = ?',
        whereArgs: [movement.id],
      );
      await txn.delete(
        StorageConstants.submovementTagsTable,
        where: 'movement_id = ?',
        whereArgs: [movement.id],
      );
      await txn.delete(
        StorageConstants.submovementsTable,
        where: 'movement_id = ?',
        whereArgs: [movement.id],
      );
      await txn.insert(
        StorageConstants.movementsTable,
        _movementToRow(movement),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final tag in movement.tags) {
        await txn.insert(StorageConstants.movementTagsTable, {
          'movement_id': movement.id,
          'tag_id': tag.id,
          'tag_description': tag.description,
        });
      }
      for (final sub in movement.submovements) {
        await txn.insert(StorageConstants.submovementsTable, {
          'id': sub.id,
          'movement_id': movement.id,
          'description': sub.description,
          'amount': sub.amount,
          'category_id': sub.subcategory.id,
          'category_is_expense': sub.subcategory.isExpenseCategory ? 1 : 0,
          'category_description': sub.subcategory.description,
          'category_icon_name': sub.subcategory.iconName,
        });
        for (final tag in sub.tags) {
          await txn.insert(StorageConstants.submovementTagsTable, {
            'submovement_id': sub.id,
            'movement_id': movement.id,
            'tag_id': tag.id,
            'tag_description': tag.description,
          });
        }
      }
    });
  }

  Future<void> saveManyMovements(List<Movement> movements) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final movement in movements) {
        await txn.delete(
          StorageConstants.movementTagsTable,
          where: 'movement_id = ?',
          whereArgs: [movement.id],
        );
        await txn.delete(
          StorageConstants.submovementTagsTable,
          where: 'movement_id = ?',
          whereArgs: [movement.id],
        );
        await txn.delete(
          StorageConstants.submovementsTable,
          where: 'movement_id = ?',
          whereArgs: [movement.id],
        );
        await txn.insert(
          StorageConstants.movementsTable,
          _movementToRow(movement),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        for (final tag in movement.tags) {
          await txn.insert(StorageConstants.movementTagsTable, {
            'movement_id': movement.id,
            'tag_id': tag.id,
            'tag_description': tag.description,
          });
        }
        for (final sub in movement.submovements) {
          await txn.insert(StorageConstants.submovementsTable, {
            'id': sub.id,
            'movement_id': movement.id,
            'description': sub.description,
            'amount': sub.amount,
            'category_id': sub.subcategory.id,
            'category_is_expense': sub.subcategory.isExpenseCategory ? 1 : 0,
            'category_description': sub.subcategory.description,
            'category_icon_name': sub.subcategory.iconName,
          });
          for (final tag in sub.tags) {
            await txn.insert(StorageConstants.submovementTagsTable, {
              'submovement_id': sub.id,
              'movement_id': movement.id,
              'tag_id': tag.id,
              'tag_description': tag.description,
            });
          }
        }
      }
    });
  }

  Future<void> deleteMovement(int id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        StorageConstants.movementTagsTable,
        where: 'movement_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        StorageConstants.submovementTagsTable,
        where: 'movement_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        StorageConstants.submovementsTable,
        where: 'movement_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        StorageConstants.movementsTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> replaceMovement(int oldId, Movement newMovement) async {
    await deleteMovement(oldId);
    await saveMovement(newMovement);
  }

  Future<void> clearMovements() async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(StorageConstants.movementTagsTable);
      await txn.delete(StorageConstants.submovementTagsTable);
      await txn.delete(StorageConstants.submovementsTable);
      await txn.delete(StorageConstants.movementsTable);
    });
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _db;
    final rows = await db.query(
      StorageConstants.categoriesTable,
      orderBy: 'is_expense ASC, id ASC',
    );
    return rows
        .map(
          (row) => Category(
            id: row['id'] as int,
            isExpenseCategory: (row['is_expense'] as int) == 1,
            description: row['description'] as String,
            iconName: row['icon_name'] as String,
          ),
        )
        .toList();
  }

  Future<void> saveAllCategories(List<Category> categories) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(StorageConstants.categoriesTable);
      for (final cat in categories) {
        await txn.insert(StorageConstants.categoriesTable, {
          'id': cat.id,
          'is_expense': cat.isExpenseCategory ? 1 : 0,
          'description': cat.description,
          'icon_name': cat.iconName,
        });
      }
    });
  }

  Future<List<String>> getTitleSuggestionsByCategory(
    int categoryId, {
    int limit = 3,
  }) async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT title, COUNT(*) AS cnt, MAX(accounting_date) AS last_date '
      'FROM ${StorageConstants.movementsTable} '
      'WHERE category_id = ? AND title != "" '
      'GROUP BY title '
      'ORDER BY cnt DESC, last_date DESC '
      'LIMIT ?',
      [categoryId, limit],
    );
    return rows.map((r) => r['title'] as String).toList();
  }

  Future<List<Tag>> getAllTags() async {
    final db = await _db;
    final rows = await db.query(
      StorageConstants.tagsTable,
      orderBy: 'description ASC',
    );
    return rows
        .map((row) => Tag(id: row['id'] as int, description: row['description'] as String))
        .toList();
  }

  Future<void> saveTag(Tag tag) async {
    final db = await _db;
    await db.insert(
      StorageConstants.tagsTable,
      {'id': tag.id, 'description': tag.description},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAllTags(List<Tag> tags) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(StorageConstants.tagsTable);
      for (final tag in tags) {
        await txn.insert(StorageConstants.tagsTable, {
          'id': tag.id,
          'description': tag.description,
        });
      }
    });
  }

  Future<List<Tag>> _loadMovementTags(Database db, int movementId) async {
    final rows = await db.query(
      StorageConstants.movementTagsTable,
      where: 'movement_id = ?',
      whereArgs: [movementId],
    );
    return rows
        .map(
          (row) => Tag(
            id: row['tag_id'] as int,
            description: row['tag_description'] as String,
          ),
        )
        .toList();
  }

  Future<List<Submovement>> _loadSubmovements(
    Database db,
    int movementId,
  ) async {
    final rows = await db.query(
      StorageConstants.submovementsTable,
      where: 'movement_id = ?',
      whereArgs: [movementId],
    );
    final result = <Submovement>[];
    for (final row in rows) {
      final subId = row['id'] as int;
      final tagRows = await db.query(
        StorageConstants.submovementTagsTable,
        where: 'submovement_id = ? AND movement_id = ?',
        whereArgs: [subId, movementId],
      );
      final tags = tagRows
          .map(
            (tr) => Tag(
              id: tr['tag_id'] as int,
              description: tr['tag_description'] as String,
            ),
          )
          .toList();
      result.add(
        Submovement(
          id: subId,
          description: row['description'] as String,
          amount: (row['amount'] as num).toDouble(),
          subcategory: Category(
            id: row['category_id'] as int,
            isExpenseCategory: (row['category_is_expense'] as int) == 1,
            description: row['category_description'] as String,
            iconName: row['category_icon_name'] as String,
          ),
          tags: tags,
        ),
      );
    }
    return result;
  }

  Map<String, Object?> _movementToRow(Movement movement) {
    return {
      'id': movement.id,
      'user_id': movement.userId,
      'title': movement.title,
      'description': movement.description,
      'amount': movement.amount,
      'accounting_date':
          '${movement.accountingDate.year.toString().padLeft(4, '0')}-'
          '${movement.accountingDate.month.toString().padLeft(2, '0')}-'
          '${movement.accountingDate.day.toString().padLeft(2, '0')}',
      'type_id': movement.type.id,
      'type_description': movement.type.description,
      'category_id': movement.category.id,
      'category_is_expense': movement.category.isExpenseCategory ? 1 : 0,
      'category_description': movement.category.description,
      'category_icon_name': movement.category.iconName,
      'account_id': movement.account.id,
      'account_description': movement.account.description,
    };
  }

  Movement _rowToMovement(
    Map<String, Object?> row,
    List<Tag> tags,
    List<Submovement> submovements,
  ) {
    return Movement(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      description: row['description'] as String,
      amount: (row['amount'] as num).toDouble(),
      accountingDate: DateTime.parse(row['accounting_date'] as String),
      type: MovementType(
        id: row['type_id'] as int,
        description: row['type_description'] as String,
      ),
      category: Category(
        id: row['category_id'] as int,
        isExpenseCategory: (row['category_is_expense'] as int) == 1,
        description: row['category_description'] as String,
        iconName: row['category_icon_name'] as String,
      ),
      account: Account(
        id: row['account_id'] as int,
        description: row['account_description'] as String,
      ),
      tags: tags,
      submovements: submovements,
    );
  }
}
