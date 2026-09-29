import "package:fave/shared/modules/storage/i.sql_storage.dart"
    show SqlStorageImpl, SqlSchemaBuilder;

abstract class Storage {
  const Storage();

  factory Storage.sql({
    required String tableName,
    required int version,
    SqlSchemaBuilder? onCreateSchema,
  }) = SqlStorageImpl;

  Future<List<Map<String, Object?>>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  });

  Future<Map<String, Object?>?> getById(String id);

  Future<void> insert(Map<String, Object?> data);

  Future<void> update(
    Map<String, Object?> data, {
    required String where,
    required List<Object?> whereArgs,
  });

  Future<void> delete({
    required String where,
    required List<Object?> whereArgs,
  });
}
