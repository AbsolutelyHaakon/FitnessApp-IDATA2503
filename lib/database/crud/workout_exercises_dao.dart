import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/workout_exercises.dart';

class WorkoutExercisesDao {
  final tableName = 'workoutExercises';

  Future<int> create(WorkoutExercises workoutExercises) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workoutExercises.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(WorkoutExercises workoutExercises) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      workoutExercises.toMap(),
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutExercises.workoutId, workoutExercises.exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WorkoutExercises>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => WorkoutExercises.fromMap(entry)).toList();
  }

  Future<List<WorkoutExercises>> fetchByWorkoutId(int workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    return data.map((entry) => WorkoutExercises.fromMap(entry)).toList();
  }

  Future<WorkoutExercises> fetchById(int workoutId, int exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
    return WorkoutExercises.fromMap(data.first);
  }

  Future<void> delete(int workoutId, int exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
  }
}