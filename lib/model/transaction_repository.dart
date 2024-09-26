import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spend_wise/dto/transaction.dart';

class TransactionRepository {
  static final TransactionRepository _instance =
      TransactionRepository._internal();
  static Database? _database;

  factory TransactionRepository() {
    return _instance;
  }

  TransactionRepository._internal();

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  // Create and open the database
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'transactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''DROP TABLE transactions''');
    await db.execute('''
      CREATE TABLE transactions(
        id INT PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        type TEXT,
        source TEXT,
        description TEXT,
        amount DOUBLE,
        attachmentUrl TEXT,
        txnTime TEXT
      )
    ''');
  }

  // Insert a new transaction
  Future<int> insertTransaction(TransactionDto transaction) async {
    print(transaction.amount);
    Database db = await database;
    return await db.insert('transactions', transaction.toJsonSQL(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve all transactions
  Future<List<TransactionDto>> getTransactions() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('transactions');
    return result.map((map) => TransactionDto.fromJson(map)).toList();
  }

  // Retrieve top transactions
  Stream<List<TransactionDto>> getRecentTransactionsStreamSQL() {
    return Stream.fromFuture(() async {
      Database db = await database;
      List<Map<String, dynamic>> result =
          await db.query('transactions', limit: 10);
      return result.map((map) => TransactionDto.fromJson(map)).toList();
    }());
  }

  Stream<List<TransactionDto>> getAllTransactionsStreamSQLLimit() {
    return Stream.fromFuture(() async {
      Database db = await database;
      List<Map<String, dynamic>> result =
          await db.query('transactions', limit: 100, orderBy: 'txnTime DESC');
      return result.map((map) => TransactionDto.fromJson(map)).toList();
    }());
  }

  // Update an existing transaction
  Future<int> updateTransaction(TransactionDto transaction) async {
    Database db = await database;
    return await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete a transaction
  Future<int> deleteTransaction(int id) async {
    Database db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
