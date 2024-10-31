import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseDao {
  final tableName = 'exercise';

  Future<int> create(Exercise exercise) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Exercise exercise) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      exercise.toMap(),
      where: 'exerciseId = ?',
      whereArgs: [exercise.exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercise>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Exercise.fromMap(entry)).toList();
  }

  Future<Exercise> fetchById(int exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return Exercise.fromMap(data.first);
  }

  Future<void> delete(int exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllAsMap() async {
    final database = await DatabaseService().database;
    return await database.query(tableName);
  }
}