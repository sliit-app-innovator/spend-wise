import 'package:path/path.dart';
import 'package:spend_wise/dto/user%20configs.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:sqflite/sqflite.dart';

class UserConfigsRepository {
  static final UserConfigsRepository _instance = UserConfigsRepository._internal();
  static Database? _database;

  factory UserConfigsRepository() {
    return _instance;
  }

  UserConfigsRepository._internal();

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
      version: 6,
      onCreate: _onCreate,
    );
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    print("CREATING user_configs TABLE.......................!");
    await db.execute('''
      CREATE TABLE user_configs1 (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        name TEXT,
        value TEXT,
        UNIQUE(userId, name) 
      )
    ''');
  }

  // Insert a new transaction
  Future<int> insertConfigs(List<UserConfigs> configs) async {
    Database db = await database;
    int i = await db.delete("user_configs", where: 'userId = ?', whereArgs: [configs[0].userId]);
    print("Deleting........................." + i.toString());
    configs.forEach((item) {
      db.insert('user_configs', item.toJsonSQL(), conflictAlgorithm: ConflictAlgorithm.replace);
      print("Inserting.........................");
    });
    return 1;
  }

  Future<List<UserConfigs>> getUserConfigs(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user_configs', where: 'userId = ?', whereArgs: [userId]);
    List<UserConfigs> userConfigs = result.isNotEmpty ? result.map((config) => UserConfigs.fromJson(config)).toList() : [];
    return userConfigs;
  }

  void deleteUserConfigs(String userId) async {
    Database db = await database;
    int i = await db.delete("user_configs", where: 'userId = ?', whereArgs: [userId]);
    print("DEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEL" + i.toString());
  }
}
