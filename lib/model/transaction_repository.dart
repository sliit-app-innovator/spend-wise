import 'package:path/path.dart';
import 'package:spend_wise/dto/mothly_transaction_summary_view.dart';
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
      version: 5,
      onCreate: _onCreate,
    );
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    print("CREATING transactions TABLE.......................!");
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    Database db = await database;
    return await db.insert('transactions', transaction.toJsonSQL(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve all transactions
  Future<List<TransactionDto>> getTransactions() async {
    DateTime now = DateTime.now();
    String startOfMonth = DateTime(now.year, now.month, 1).toString();
    String endOfMonth = DateTime(now.year, now.month + 1, 0).toString();

    Database db = await database;
    //db.delete('transactions');
    List<Map<String, dynamic>> result = await db.query('transactions',
        // where: 'txnTime >= ? AND txnTime <= ?',
        //  whereArgs: [startOfMonth, endOfMonth],
        orderBy: 'txnTime DESC',
        limit: 10);
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
    DateTime now = DateTime.now();
    String startOfMonth = DateTime(now.year, now.month, 1).toString();
    String endOfMonth = DateTime(now.year, now.month + 1, 0).toString();

    return Stream.fromFuture(() async {
      Database db = await database;
      List<Map<String, dynamic>> result = await db.query('transactions',
          //  where: 'txnTime >= ? AND txnTime <= ?',
          //   whereArgs: [startOfMonth, endOfMonth],
          orderBy: 'txnTime DESC',
          limit: 1000);
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

  Future<MonthlyTransactionSummary> getMonthlyTransactionSummary() async {
    MonthlyTransactionSummary summary;
    // Initialize an empty list to hold transactions
    List<TransactionDto> transactions = [];
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;

    Map<String, double> sampleMap = {};

    // Get the stream of transactions
    Stream<List<TransactionDto>> transactionStream =
        getAllTransactionsStreamSQLLimit();

    // Use await for to process the stream asynchronously
    await for (List<TransactionDto> transactionBatch in transactionStream) {
      //transactions.addAll(transactionBatch); // Add all transactions to the list
      transactionBatch.forEach((txn) {
        transactions.add(txn);
        if (txn.type == 'Income') {
          _totalIncome = _totalIncome + txn.amount;
        } else {
          _totalExpense = _totalExpense + txn.amount;
        }
        if (sampleMap.containsKey(txn.source)) {
          // If it exists, add the amount to the existing value
          sampleMap[txn.source] =
              sampleMap[txn.source]! + txn.amount; // Use '!' to assert non-null
        } else {
          // If it doesn't exist, add the new key and amount
          sampleMap[txn.source] = txn.amount;
        }
      });
    }
    // Now all the transactions have been added to the list
    print("Final transactions count: ${transactions.length}");

    // Create the summary with the full transaction list
    summary = MonthlyTransactionSummary(
      trasactions: transactions, // Full transaction list
      totalIncome: _totalIncome,
      totalExpense: _totalExpense,
      expensesMap: sampleMap,
    );
    print("Summary transactions count: ${summary.trasactions.length}");
    return summary; // Return the fully constructed summary
  }
}
