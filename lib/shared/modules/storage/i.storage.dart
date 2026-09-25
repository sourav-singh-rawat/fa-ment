import 'package:fave/shared/modules/storage/storage.dart'
    show Storage, StorageEncoder, StorageDecoder;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

class StorageImpl implements Storage {
  SharedPreferences? _instance;

  @override
  Future<void> store<T>({
    required String key,
    required T data,
    required StorageEncoder<T> encoder,
  }) async {
    final database = await getInstance();

    final encodedData = encoder(data);
    await database.setString(key, encodedData);
  }

  @override
  Future<void> update<T>({
    required String key,
    required T updatedData,
    required StorageEncoder<T> encoder,
  }) async {
    return store<T>(key: key, data: updatedData, encoder: encoder);
  }

  @override
  Future<T?> retrieve<T>({
    required String key,
    required StorageDecoder<T> decoder,
  }) async {
    final database = await getInstance();

    final retrievedData = database.getString(key);

    if (retrievedData == null) return null;

    final decodedData = decoder(retrievedData);

    return decodedData;
  }

  @override
  Future<bool> exists(String key) async {
    final database = await getInstance();

    final exists = database.containsKey(key);

    return exists;
  }

  @override
  Future<void> delete(String key) async {
    final exists = await this.exists(key);
    if (!exists) return;

    final database = await getInstance();

    await database.remove(key);
  }

  Future<SharedPreferences> getInstance() async {
    return _instance ??= await SharedPreferences.getInstance();
  }
}
