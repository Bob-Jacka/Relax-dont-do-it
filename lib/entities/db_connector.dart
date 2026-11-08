import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:relax_dont_do_it/data/measure_model.dart';
import 'package:sqflite/sqflite.dart';

typedef Void_db_res = Future<void>;
typedef Delete_db_res = Future<int>;
typedef Select_db_res = Future<List<Map<String, Object?>>>;

//Database connector for saving data in sqlite
final class DbConnector {
  late final Future<Database> database;
  static const String _dbName = 'measure';

  DbConnector() {
    createDatabase();
  }

  Future<Database> createDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), '$_dbName.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE IF NOT EXISTS $_dbName(id INTEGER PRIMARY KEY AUTOINCREMENT, data REAL, date TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  //Select and return query results
  Select_db_res selectMeasures() async {
    final db = await database;
    return await db.query(_dbName);
  }

  Void_db_res deleteMeasure({required int id}) async {
    final db = await database;
    await db.delete(_dbName, where: 'id = $id');
  }

  Delete_db_res updateMeasure(MeasureModel value_to_update, {int? id}) async {
    final db = await database;
    return await db.update(
      _dbName,
      value_to_update.toMap(),
      where: 'id = $id',
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Void_db_res insertMeasure(MeasureModel measure) async {
    try {
      final db = await database;

      await db.insert(
        _dbName,
        measure.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Database insert exception: $e');
    }
  }
}
