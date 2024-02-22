import 'dart:io';

import 'package:healthlog/model/bloodpressure.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:healthlog/model/user.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'healthlog3.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT,lastName TEXT, age INTEGER, weight INTEGER, height INTEGER)',
        );
        await database.execute(
          'CREATE TABLE data(id INTEGER PRIMARY KEY AUTOINCREMENT, user INTEGER NOT NULL,type TEXT NOT NULL, content TEXT NOT NULL, comments TEXT NOT NULL, date INTEGER NOT NULL)',
        );
      },
      version: 1,
    );
  }

  void getDbpath() async {
    String databasePath = await getDatabasesPath();
    print('Database path: $databasePath');
    Directory? extStoragePath = await getExternalStorageDirectory();
    print('External Storage Path: $extStoragePath');
  }

  void backupDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      String dbFileName = 'healthlog3';
      File dbFile =
          File('/data/user/0/com.example.healthlog/databases/healthlog3.db');
      Directory? folderPath = Directory('/storage/emulated/0/HealthLog');
      await folderPath.create();
      await dbFile.copy('/storage/emulated/0/HealthLog/healthlog3.db');
    } catch (e) {
      print('${e.toString()}');
    }
  }

  void restoreDb() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      String dbFileName = 'healthlog3';
      File savedDbFile = File('/storage/emulated/0/HealthLog/healthlog3.db');
      await savedDbFile
          .copy('/data/user/0/com.example.healthlog/databases/healthlog3.db');
    } catch (e) {
      print('${e.toString()}');
    }
  }

  void deleteDB() async {
    try {
      deleteDatabase(
          '/data/user/0/com.example.healthlog/databases/healthlog3.db');
    } catch (e) {}
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
      //print('Error while inserting data: $e');
    }
  }

  Future<void> deleteBP(int id) async {
    final db = await initializeDB();
    await db.delete(
      'data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BloodPressure>> bphistory(userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query('data', where: 'user=($userid)', orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => BloodPressure.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> bpdata(userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query('data', where: 'user=($userid)', orderBy: 'date ASC');
    //print(queryResult);
    return queryResult;
  }

  void deleteAllRows(String tableName) async {
    final db = await initializeDB();
    await db.delete(tableName);
  }
}
