import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:healthlog/model/user.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'health.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY, firstName TEXT,lastName TEXT, age INTEGER, weight INTEGER, height INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertUser(User user) async {
    final db = await initializeDB();
    await db.insert('user', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<User>> users() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('user');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await initializeDB();
    await db.delete(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
