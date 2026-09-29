import 'package:fave/shared/modules/storage/storage.dart' show Storage;
import 'package:sqflite/sqflite.dart'
    show Database, getDatabasesPath, openDatabase;

typedef SqlSchemaBuilder = Future<void> Function(Database db, int version);

class SqlStorageImpl implements Storage {
  SqlStorageImpl({
    required this.tableName,
    required this.version,
    this.onCreateSchema,
  });

  final String tableName;
  final SqlSchemaBuilder? onCreateSchema;
  final int version;

  Database? _databaseInstance;

  Future<Database> get _database async {
    return _databaseInstance ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/$tableName.db';
    return openDatabase(path, version: version, onCreate: onCreateSchema);
  }

  @override
  Future<List<Map<String, Object?>>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await _database;
    return db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  @override
  Future<Map<String, Object?>?> getById(String id) async {
    final db = await _database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return result.first;
  }

  @override
  Future<void> insert(Map<String, Object?> data) async {
    final db = await _database;
    await db.insert(tableName, data);
  }

  @override
  Future<void> update(
    Map<String, Object?> data, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await _database;
    await db.update(tableName, data, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> delete({
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await _database;
    await db.delete(tableName, where: where, whereArgs: whereArgs);
  }
}
