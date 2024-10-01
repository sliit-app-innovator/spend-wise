import 'package:path/path.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  static Database? _database;

  factory UserRepository() {
    return _instance;
  }

  UserRepository._internal();

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
    print("CREATING user 3 TABLEs.......................!");
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        username TEXT,
        password TEXT
      )
    ''');
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
  Future<int> registerUser(UserDto userDto) async {
    Database db = await database;
    return await db.insert('user', userDto.toJsonSQL(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserDto> getUser(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user',
        where: 'username = ?',
        whereArgs: [userId], // Correct whereArgs as a list
        limit: 1);

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

  Future<UserDto> login(String userId, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user',
        where: '(username = ? OR email = ?) AND password = ?',
        whereArgs: [userId, userId, password], // Correct whereArgs as a list
        limit: 1);

    if (result.isNotEmpty) {
      return UserDto.fromJson(result.first);
    } else {
      throw Exception('User not found');
    }
  }
}
