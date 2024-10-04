import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_date.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutDateDao {
  final tableName = 'workoutDates';

  Future<int> create(WorkoutDate workoutDate) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workoutDate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(WorkoutDate workoutDate) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      workoutDate.toMap(),
      where: 'workoutId = ? AND date = ?',
      whereArgs: [workoutDate.workoutId, workoutDate.date],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WorkoutDate>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => WorkoutDate.fromMap(entry)).toList();
  }

  Future<WorkoutDate> fetchById(int id) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return WorkoutDate.fromMap(data.first);
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}