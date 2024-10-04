import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/exercise.dart';
import '../tables/workout.dart';
import '../tables/workout_exercises.dart';

class WorkoutDao {
  final tableName = 'workouts';

  Future<int> create(Workout workout) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Workout workout) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Workout>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName, orderBy: 'name');
    return data.map((entry) => Workout.fromMap(entry)).toList();
  }

  Future<Workout> fetchById(int id) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Workout.fromMap(data.first);
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Exercise>> fetchExercisesForWorkout(int workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.rawQuery('''
      SELECT exercise.* FROM exercise
      INNER JOIN workoutExercises ON exercise.id = workoutExercises.exerciseId
      WHERE workoutExercises.workoutId = ?
    ''', [workoutId]);
    return data.map((entry) => Exercise.fromMap(entry)).toList();
  }
}