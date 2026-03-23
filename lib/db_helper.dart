import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async{
    if(_db != null) return _db!;

    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');


    return openDatabase(
      path,
      version: 1,
      onCreate:(db, version){
        return db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      }

    );
  }


  static Future<List<String>> getAllDates() async{
    final db = await database;

    final result = await db.rawQuery(
      'SELECT DISTINCT date FROM expenses ORDER BY date DESC',
    );

    return result.map((e) => e['date'] as String).toList();
  }
}