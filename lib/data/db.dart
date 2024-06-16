import 'dart:io';

import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/model/cholesterol.dart';
import 'package:healthlog/model/data.dart';
import 'package:healthlog/model/sugar.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:healthlog/model/user.dart';

class DatabaseHandler {
  static DatabaseHandler instance = DatabaseHandler._constructor();
  DatabaseHandler._constructor();
  String dbFileName = 'healthlog';
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, '$dbFileName.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE user(id INTEGER PRIMARY KEY, firstName TEXT,lastName TEXT, age INTEGER, weight INTEGER, height INTEGER)',
        );
        await database.execute(
          'CREATE TABLE data(id INTEGER PRIMARY KEY, user INTEGER NOT NULL,type TEXT NOT NULL, content TEXT NOT NULL, comments TEXT NOT NULL, date INTEGER NOT NULL)',
        );
      },
      version: 1,
    );
  }

  // void getDbpath() async {
  //   String databasePath = await getDatabasesPath();
  //   print('Database path: $databasePath');
  //   Directory? extStoragePath = await getExternalStorageDirectory();
  //   print('External Storage Path: $extStoragePath');
  // }

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
      File dbFile =
          File('/data/user/0/com.example.healthlog/databases/$dbFileName.db');
      Directory? folderPath = Directory('/storage/emulated/0/HealthLog');
      await folderPath.create();
      await dbFile.copy('/storage/emulated/0/HealthLog/$dbFileName.db');
    } catch (e) {
      // print('${e.toString()}');
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
      File savedDbFile = File('/storage/emulated/0/HealthLog/$dbFileName.db');
      await savedDbFile
          .copy('/data/user/0/com.example.healthlog/databases/$dbFileName.db');
    } catch (e) {
      // print('${e.toString()}');
    }
  }

  void deleteDB() async {
    try {
      deleteDatabase(
          '/data/user/0/com.example.healthlog/databases/$dbFileName.db');
    } catch (e) {
      // print('${e.toString()}');
    }
  }

  Future<List<Data>> allhistory(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query('data', where: 'user=($userid)', orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => Data.fromMap(e)).toList();
  }

  Future<void> deleteRecord(int id) async {
    final db = await initializeDB();
    await db.delete(
      'data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void deleteAllRows(String tableName) async {
    final db = await initializeDB();
    await db.delete(tableName);
  }

  // User Functions
  // User Start
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
    await db.delete(
      'data',
      where: 'user = ?',
      whereArgs: [id],
    );
  }

  Future getUserName(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> maps =
        await db.query('user', columns: ['firstName'], where: 'id=($userid)');
    if (maps.isNotEmpty) {
      return maps.first['firstName'] as String?;
    }
  }

  // User END

// Blood Pressure
// BP start
  Future<List<BloodPressure>> bphistory(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'bp'],
        orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => BloodPressure.fromMap(e)).toList();
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

  Future<String> bpReading(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'bp']);
    //print(queryResult);
    final result = queryResult.map((e) => BloodPressure.fromMap(e)).toList();

    return '${result.first.content.systolic}/${result.first.content.diastolic}';
  }

  Future<List<BloodPressure>> bpEntry(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'bp']);
    //print(queryResult);
    return queryResult.map((e) => BloodPressure.fromMap(e)).toList();
  }

  Future<List<BloodPressure>> bpHistoryGraph(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'bp'],
        orderBy: 'date ASC');
    //print(queryResult);
    return queryResult.map((e) => BloodPressure.fromMap(e)).toList();
  }
// BP END

// Blood Glucose (Sugar)
// SG START
  Future<List<Sugar>> sugarhistory(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'sugar'],
        orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => Sugar.fromMap(e)).toList();
  }

  Future<List<Sugar>> sgHistoryGraph(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'sugar'],
        orderBy: 'date ASC');
    //print(queryResult);
    return queryResult.map((e) => Sugar.fromMap(e)).toList();
  }

  Future<String> sgReading(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'sugar']);
    //print(queryResult);
    final result = queryResult.map((e) => Sugar.fromMap(e)).toList();

    return '${double.parse(result.first.content.reading.toString()).toStringAsFixed(2)} mg/dL, ${result.first.content.beforeAfter.toString()}';
  }

  Future<List<Sugar>> sugarEntry(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'sugar']);
    //print(queryResult);
    return queryResult.map((e) => Sugar.fromMap(e)).toList();
  }

  Future<void> insertSg(Sugar sg) async {
    final db = await initializeDB();

    try {
      await db.insert('data', sg.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }

// SG END

// Cholesterol (Sugar)
// CHLSTRL START
  Future<List<Cholesterol>> chlstrlHistory(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'chlstrl'],
        orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => Cholesterol.fromMap(e)).toList();
  }

  Future<List<Cholesterol>> chlstrlHistoryGraph(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'chlstrl'],
        orderBy: 'date ASC');
    //print(queryResult);
    return queryResult.map((e) => Cholesterol.fromMap(e)).toList();
  }

  Future<String> chlstrlReading(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'id=? AND type=?', whereArgs: [entryid, 'chlstrl']);
    //print(queryResult);
    final result = queryResult.map((e) => Cholesterol.fromMap(e)).toList();

    return 'Total/TAG/HDL/LDL : ${double.parse(result.first.content.total.toString()).toStringAsFixed(2)}/${double.parse(result.first.content.tag.toString()).toStringAsFixed(2)}/${double.parse(result.first.content.hdl.toString()).toStringAsFixed(2)}/${double.parse(result.first.content.ldl.toString()).toStringAsFixed(2)} mg/dL';
  }

  Future<List<Cholesterol>> chlstrlEntry(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'id=? AND type=?', whereArgs: [entryid, 'chlstrl']);
    //print(queryResult);
    return queryResult.map((e) => Cholesterol.fromMap(e)).toList();
  }

  Future<void> insertCh(Cholesterol ch) async {
    final db = await initializeDB();

    try {
      await db.insert('data', ch.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }
// CHLSTRL END
}
