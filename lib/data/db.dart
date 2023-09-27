import 'package:healthlog/model/bloodpressure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:healthlog/model/user.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'healthlog2.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT,lastName TEXT, age INTEGER, weight INTEGER, height INTEGER)',
        );
        await database.execute(
          'CREATE TABLE bloodpressure(id INTEGER PRIMARY KEY AUTOINCREMENT, user INTEGER NOT NULL, systolic INTEGER NOT NULL, diastolic INTEGER NOT NULL, heartrate INTEGER NOT NULL, arm TEXT NOT NULL, date INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE data(id INTEGER PRIMARY KEY AUTOINCREMENT, user INTEGER NOT NULL,type TEXT NOT NULL, content TEXT NOT NULL, comments TEXT NOT NULL, date INTEGER NOT NULL)',
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

  Future<void> insertBp(BloodPressure bp) async {
    final db = await initializeDB();

    try {
      await db.insert('data', bp.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error while inserting data: $e');
    }
  }

  Future<List<BloodPressure>> bphistory(userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query('data', where: 'user=($userid)');
    print(queryResult);
    return queryResult.map((e) => BloodPressure.fromMap(e)).toList();
  }

  void deleteAllRows(String tableName) async {
    final db = await initializeDB();
    await db.delete(tableName);
  }
}
