import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show
        PaymentStatus,
        PaymentSuccess,
        PaymentFailed,
        PaymentPending,
        PaymentUnresolved;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:fave/shared/modules/storage/storage.dart' show Storage;
import 'package:sqflite/sqflite.dart' show Database;

part 'mapper/payment_sql_mapper.dart';
part 'mapper/payment_status_sql_mapper.dart';

class LocalPaymentRepositoryImpl implements PaymentRepository {
  LocalPaymentRepositoryImpl._(this._storage);

  static LocalPaymentRepositoryImpl? _instance;

  factory LocalPaymentRepositoryImpl({Storage? storage}) {
    return _instance ??= LocalPaymentRepositoryImpl._(
      storage ??
          Storage.sql(
            tableName: _PaymentCharacters.tableName,
            version: 1,
            onCreateSchema: _createSchema,
          ),
    );
  }

  final Storage _storage;

  static Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
        CREATE TABLE ${_PaymentCharacters.tableName} (
          ${_PaymentCharacters.id} TEXT PRIMARY KEY,
          ${_PaymentCharacters.serverId} TEXT,
          ${_PaymentCharacters.recipientId} TEXT NOT NULL,
          ${_PaymentCharacters.amount} INTEGER NOT NULL,
          ${_PaymentCharacters.note} TEXT,
          ${_PaymentCharacters.status} TEXT NOT NULL,
          ${_PaymentCharacters.updatedAt} TEXT NOT NULL,
          ${_PaymentCharacters.createdAt} TEXT NOT NULL
        )
      ''');
  }

  @override
  Future<List<Payment>> loadRecent() async {
    final result = await _storage.query(
      orderBy: '${_PaymentCharacters.createdAt} DESC',
    );
    return result.map(_PaymentSqlMapper.fromData).toList();
  }

  @override
  Future<void> save(Payment payment) async {
    await _storage.insert(_PaymentSqlMapper.toData(payment));
  }

  @override
  Future<Payment?> get(String key) async {
    final result = await _storage.getById(key);
    if (result == null) return null;
    return _PaymentSqlMapper.fromData(result);
  }

  @override
  Future<void> update(Payment payment) async {
    await _storage.update(
      _PaymentSqlMapper.toData(payment),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }
}

class _PaymentCharacters {
  const _PaymentCharacters._();
  static const tableName = "PaymentsFave";
  static const id = "id";
  static const serverId = "serverId";
  static const recipientId = "recipientId";
  static const amount = "amount";
  static const note = "note";
  static const status = "status";
  static const updatedAt = "updatedAt";
  static const createdAt = "createdAt";
}
