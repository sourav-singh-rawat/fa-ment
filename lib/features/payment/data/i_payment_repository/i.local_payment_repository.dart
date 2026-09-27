import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment, PaymentCharacters;
import 'package:fave/features/payment/domain/entities/payment_status.dart'
    show
        PaymentStatus,
        PaymentSuccess,
        PaymentFailed,
        PaymentPending,
        PaymentUnresolved;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:sqflite/sqflite.dart'
    show Database, getDatabasesPath, openDatabase;

part 'mapper/payment_sql_mapper.dart';
part 'mapper/payment_status_sql_mapper.dart';

//TODO: Create separate implementation of Sqlite
class LocalPaymentRepositoryImpl implements PaymentRepository {
  const LocalPaymentRepositoryImpl._();

  static final LocalPaymentRepositoryImpl _instance =
      LocalPaymentRepositoryImpl._();

  factory LocalPaymentRepositoryImpl() => _instance;

  static Database? _databaseInstance;

  @override
  Future<List<Payment>> loadRecent() async {
    final db = await database;
    const orderBy = '${_PaymentCharacters.createdAt} DESC';
    final result = await db.query(
      _PaymentCharacters.tableName,
      orderBy: orderBy,
    );
    return result.map((json) => _PaymentSqlMapper.fromData(json)).toList();
  }

  @override
  Future<void> save(Payment payment) async {
    final db = await database;
    await db.insert(
      _PaymentCharacters.tableName,
      _PaymentSqlMapper.toData(payment),
    );
  }

  @override
  Future<Payment?> get(String key) async {
    final db = await database;
    final result = await db.query(
      _PaymentCharacters.tableName,
      where: "id = ?",
      whereArgs: [key],
    );
    if (result.isEmpty) return null;
    return _PaymentSqlMapper.fromData(result.first);
  }

  @override
  Future<void> update(Payment payment) async {
    final db = await database;
    await db.update(
      _PaymentCharacters.tableName,
      _PaymentSqlMapper.toData(payment),
      where: "id = ?",
      whereArgs: [payment.id],
    );
  }

  Future<Database> get database async {
    return _databaseInstance ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/${_PaymentCharacters.tableName}.db';
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
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

    // await db.execute('''
    //     CREATE TRIGGER rotate_two_rows
    //     AFTER INSERT ON ${PaymentCharacters.tableName}
    //     WHEN (SELECT COUNT(*) FROM ${PaymentCharacters.tableName}) > 2
    //     BEGIN
    //       DELETE FROM ${PaymentCharacters.tableName}
    //       WHERE id = (SELECT MIN(sn) FROM ${PaymentCharacters.tableName});
    //     END
    // ''');
  }
}

class _PaymentCharacters {
  const _PaymentCharacters._();
  static const tableName = "Payments-fave";
  static const id = "id";
  static const serverId = "serverId";
  static const recipientId = "recipientId";
  static const amount = "amount";
  static const note = "note";
  static const status = "status";
  static const updatedAt = "updatedAt";
  static const createdAt = "createdAt";
}
