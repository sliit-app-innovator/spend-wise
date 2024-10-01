import 'package:path/path.dart';
import 'package:spend_wise/dto/user%20configs.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:sqflite/sqflite.dart';

class UserConfigsRepository {
  static final UserConfigsRepository _instance =
      UserConfigsRepository._internal();
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
      version: 5,
      onCreate: _onCreate,
    );
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    print("CREATING user_configs TABLE.......................!");
    await db.execute('''
      CREATE TABLE user_configs (
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
    configs.forEach((item) {
      db.insert('user_configs', item.toJsonSQL(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return 1;
  }

  Future<UserDto> getUserConfigs(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db
        .query('user_configs', where: 'username = ?', whereArgs: [userId]);

    if (result.isNotEmpty) {
      // Assuming you have a method to convert a Map<String, dynamic> to a UserDto
      return UserDto.fromJson(result.first);
    } else {
      throw Exception('User not found');
    }
  }

  Future<UserDto> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user',
        where: 'email = ?',
        whereArgs: [email], // Correct whereArgs as a list
        limit: 1);

    if (result.isNotEmpty) {
      // Assuming you have a method to convert a Map<String, dynamic> to a UserDto
      return UserDto.fromJson(result.first);
    } else {
      throw Exception('Email not found');
    }
  }
}
