import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('water_consumption.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE water_consumption(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        amount INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertWaterConsumption(int amount) async {
    final db = await database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return await db.insert(
      'water_consumption',
      {
        'timestamp': timestamp,
        'amount': amount,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getWaterConsumptionHistory() async {
    final db = await database;
    return await db.query(
      'water_consumption',
      orderBy: 'timestamp DESC',
    );
  }

  // Optional: Get data for a specific time range
  Future<List<Map<String, dynamic>>> getWaterConsumptionRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return await db.query(
      'water_consumption',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp ASC',
    );
  }

  // clear the whole database
  Future<int> clearDatabase() async {
    final db = await database;
    return await db.delete('water_consumption');
  }
}
