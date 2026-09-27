import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment, PaymentCharacters;
import 'package:fave/features/payment/domain/payment_repository.dart'
    show PaymentRepository;
import 'package:sqflite/sqflite.dart'
    show Database, getDatabasesPath, openDatabase;

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
    const orderBy = '${PaymentCharacters.createdAt} DESC';
    final result = await db.query(
      PaymentCharacters.tableName,
      orderBy: orderBy,
    );
    return result.map((json) => Payment.fromSqlJson(json)).toList();
  }

  @override
  Future<void> save(Payment payment) async {
    final db = await database;
    await db.insert(PaymentCharacters.tableName, payment.toSqlJson());
  }

  @override
  Future<void> update(Payment payment) async {
    final db = await database;
    await db.update(
      PaymentCharacters.tableName,
      payment.toSqlJson(),
      where: "id = ?",
      whereArgs: [payment.id],
    );
  }

  Future<Database> get database async {
    return _databaseInstance ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/${PaymentCharacters.tableName}.db';
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
        CREATE TABLE ${PaymentCharacters.tableName} (
          sn INTEGER PRIMARY KEY autoincrement,
          ${PaymentCharacters.id} TEXT NOT NULL,
          ${PaymentCharacters.serverId} TEXT,
          ${PaymentCharacters.recipientId} TEXT NOT NULL,
          ${PaymentCharacters.amount} INTEGER NOT NULL,
          ${PaymentCharacters.note} TEXT,
          ${PaymentCharacters.status} TEXT NOT NULL,
          ${PaymentCharacters.updatedAt} TEXT NOT NULL,
          ${PaymentCharacters.createdAt} TEXT NOT NULL
        )
      ''');

    await db.execute('''
        CREATE TRIGGER rotate_two_rows
        AFTER INSERT ON ${PaymentCharacters.tableName}
        WHEN (SELECT COUNT(*) FROM ${PaymentCharacters.tableName}) > 2
        BEGIN
          DELETE FROM ${PaymentCharacters.tableName} 
          WHERE id = (SELECT MIN(sn) FROM ${PaymentCharacters.tableName});
        END
    ''');
  }
}
