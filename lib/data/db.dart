import 'dart:io';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/model/cholesterol.dart';
import 'package:healthlog/model/data.dart';
import 'package:healthlog/model/kidney.dart';
import 'package:healthlog/model/notes.dart';
import 'package:healthlog/model/sugar.dart';
import 'package:healthlog/view/theme/globals.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:healthlog/model/user.dart';

class DatabaseHandler {
  static DatabaseHandler instance = DatabaseHandler._constructor();
  DatabaseHandler._constructor();
  String dbFileName = 'healthlog';
  SharedPreferences? _prefs;
  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<Database> initializeDB() async {
    _initPrefs();
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
          File('/data/user/0/com.jucktion.healthlog/databases/$dbFileName.db');
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
          .copy('/data/user/0/com.jucktion.healthlog/databases/$dbFileName.db');
    } catch (e) {
      // print('${e.toString()}');
    }
  }

  void deleteDB() async {
    try {
      deleteDatabase(
          '/data/user/0/com.jucktion.healthlog/databases/$dbFileName.db');
    } catch (e) {
      // print('${e.toString()}');
    }
  }

  Future<List<Data>> allhistory(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user = ?  AND type != ?',
        whereArgs: [userid, 'note'],
        orderBy: 'date DESC');
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
    if (_prefs?.getBool('alwaysbackupDB') == true) {
      backupDB();
    }
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
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }

  Future<void> updateBp(BloodPressure bp, int userid, int entryid) async {
    final db = await initializeDB();

    try {
      await db.update('data', bp.toMap(),
          where: 'id=? AND user=?',
          whereArgs: [entryid, userid],
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
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
        orderBy: 'date DESC',
        limit: 30);
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
        orderBy: 'date DESC',
        limit: 30);
    //print(queryResult);
    return queryResult.map((e) => Sugar.fromMap(e)).toList();
  }

  Future<String> sgReading(int entryid, String unit) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'sugar']);
    //print(queryResult);
    final result = queryResult.map((e) => Sugar.fromMap(e)).toList();
    String reading = GlobalMethods.convertUnit(
            result.first.content.unit, result.first.content.reading, unit)
        .toStringAsFixed(2);
    return '$reading $unit, ${result.first.content.beforeAfter.toString()}';
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
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }

  Future<void> updateSg(Sugar sg, int userid, int entryid) async {
    final db = await initializeDB();

    try {
      await db.update('data', sg.toMap(),
          where: 'id=? AND user=?',
          whereArgs: [entryid, userid],
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
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
        orderBy: 'date DESC',
        limit: 30);
    //print(queryResult);
    return queryResult
        .map((e) => Cholesterol.fromMap(e))
        .toList()
        .reversed
        .toList();
  }

  Future<String> chlstrlReading(int entryid, String unit) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'id=? AND type=?', whereArgs: [entryid, 'chlstrl']);
    //print(queryResult);
    final result = queryResult.map((e) => Cholesterol.fromMap(e)).toList();

    String fromUnit = result.first.content.unit;
    String total =
        GlobalMethods.convertUnit(fromUnit, result.first.content.total, unit)
            .toStringAsFixed(2);
    String hdl =
        GlobalMethods.convertUnit(fromUnit, result.first.content.hdl, unit)
            .toStringAsFixed(2);
    String ldl =
        GlobalMethods.convertUnit(fromUnit, result.first.content.ldl, unit)
            .toStringAsFixed(2);

    return 'Total/HDL/LDL : $total/$hdl/$ldl $unit';
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
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }

  Future<void> updateCh(Cholesterol ch, int userid, int entryid) async {
    final db = await initializeDB();

    try {
      await db.update('data', ch.toMap(),
          where: 'id=? AND user=?',
          whereArgs: [entryid, userid],
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }
// CHLSTRL END

// RFT (Kidney/Renal Function Test)
// RFT START
  Future<List<RenalFunction>> rftHistory(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'rft'],
        orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => RenalFunction.fromMap(e)).toList();
  }

  Future<List<RenalFunction>> rftGraph(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'rft'],
        orderBy: 'date DESC',
        limit: 30);
    //print(queryResult);
    return queryResult
        .map((e) => RenalFunction.fromMap(e))
        .toList()
        .reversed
        .toList();
  }

  Future<String> rftReading(int entryid, String unit) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'rft']);
    //print(queryResult);
    final result = queryResult.map((e) => RenalFunction.fromMap(e)).toList();

    String fromUnit = result.first.content.unit;
    String bun = GlobalMethods.convertUnit(
      fromUnit,
      result.first.content.bun,
      unit,
    ).toStringAsFixed(2);
    String urea = GlobalMethods.convertUnit(
      fromUnit,
      result.first.content.urea,
      unit,
    ).toStringAsFixed(2);
    String creatinine = GlobalMethods.convertUnit(
      fromUnit,
      result.first.content.creatinine,
      unit,
    ).toStringAsFixed(2);
    String sodium = GlobalMethods.convertUnit(
      fromUnit,
      result.first.content.elements.sodium,
      unit,
    ).toStringAsFixed(2);
    String potassium = GlobalMethods.convertUnit(
      fromUnit,
      result.first.content.elements.potassium,
      unit,
    ).toStringAsFixed(2);

    return 'Bun/Urea/Creatinine/Sodium/Potassium:\n$bun/$urea/$creatinine/$sodium/$potassium $unit';
  }

  Future<List<RenalFunction>> rftEntry(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'rft']);
    //print(queryResult);
    return queryResult.map((e) => RenalFunction.fromMap(e)).toList();
  }

  Future<void> insertRf(RenalFunction rf) async {
    final db = await initializeDB();
    //print(rf.toString());
    try {
      await db.insert('data', rf.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      print('Error while inserting data: $e');
    }
  }

  Future<void> updateRf(RenalFunction ch, int userid, int entryid) async {
    final db = await initializeDB();

    try {
      await db.update('data', ch.toMap(),
          where: 'id=? AND user=?',
          whereArgs: [entryid, userid],
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }
// RFT END

// Note
// Note
  Future<List<Notes>> getnotes(int userid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('data',
        where: 'user=? AND type=?',
        whereArgs: [userid, 'note'],
        orderBy: 'date DESC');
    //print(queryResult);
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  Future<void> insertNote(Notes note) async {
    final db = await initializeDB();

    try {
      await db.insert('data', note.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }

  Future<void> updateNote(Notes nt, int userid, int entryid) async {
    final db = await initializeDB();

    try {
      await db.update('data', nt.toMap(),
          where: 'id=? AND user=?',
          whereArgs: [entryid, userid],
          conflictAlgorithm: ConflictAlgorithm.replace);
      if (_prefs?.getBool('alwaysbackupDB') == true) {
        backupDB();
      }
    } catch (e) {
      //print('Error while inserting data: $e');
    }
  }

  Future<List<Notes>> noteEntry(int entryid) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db
        .query('data', where: 'id=? AND type=?', whereArgs: [entryid, 'note']);
    //print(queryResult);
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }
}
