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
      where: 'userId = ? AND workoutId = ? AND date = ?',
      whereArgs: [workoutDate.userId, workoutDate.workoutId, workoutDate.date.toIso8601String()],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WorkoutDate>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => WorkoutDate.fromMap(entry)).toList();
  }

  Future<WorkoutDate> fetchById(int userId, int workoutId, DateTime date) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND workoutId = ? AND date = ?',
      whereArgs: [userId, workoutId, date.toIso8601String()],
    );
    return WorkoutDate.fromMap(data.first);
  }

  Future<void> delete(int userId, int workoutId, DateTime date) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND workoutId = ? AND date = ?',
      whereArgs: [userId, workoutId, date.toIso8601String()],
    );
  }
}