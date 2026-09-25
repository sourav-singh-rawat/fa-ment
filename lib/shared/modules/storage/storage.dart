import 'package:fave/shared/modules/module.dart' show Module;
import 'package:fave/shared/modules/storage/i.storage.dart' show StorageImpl;

typedef StorageEncoder<T> = String Function(T);
typedef StorageDecoder<T> = T Function(String);

abstract class Storage extends Module<void> {
  factory Storage() => StorageImpl();

  Future<void> store<T>({
    required String key,
    required T data,
    required StorageEncoder<T> encoder,
  });

  Future<void> update<T>({
    required String key,
    required T updatedData,
    required StorageEncoder<T> encoder,
  });

  Future<T?> retrieve<T>({
    required String key,
    required StorageDecoder<T> decoder,
  });

  Future<bool> exists(String key);

  Future<void> delete(String key);
}
