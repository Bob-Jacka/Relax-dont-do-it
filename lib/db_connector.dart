import 'package:path/path.dart';
import 'package:relax_dont_do_it/measure_model.dart';
import 'package:sqflite/sqflite.dart';

typedef Db_res = Future<void>;
typedef Select_db_res = Future<List<Map<String, Object?>>>;

//Database connector for saving data in sqlite
final class DbConnector {
  late final Future<Database> database;
  static const String _dbName = 'measure';

  DbConnector() {
    createDatabase();
  }

  Future<Database> createDatabase() async {
    try {
      database = openDatabase(
        join(await getDatabasesPath(), '$_dbName.db'),
        onCreate: (db, version) {
          // Run the CREATE TABLE statement on the database.
          return db.execute(
            'CREATE IF NOT EXISTS TABLE $_dbName(id INTEGER PRIMARY KEY, data Real, date DateTime)',
          );
        },
        version: 1,
      );
    } catch (e) {}
  }

  Select_db_res selectMeasures() async {
    final db = await database;
    return db.query(_dbName);
  }

  Db_res deleteMeasure() async {
    final db = await database;
    await db.delete(_dbName); //TODO continue add logic
  }

  Db_res insertMeasure(MeasureModel measure) async {
    final db = await database;

    await db.insert(
      _dbName,
      measure.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
