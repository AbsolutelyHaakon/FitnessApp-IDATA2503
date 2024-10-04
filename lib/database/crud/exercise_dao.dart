import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/exercise.dart';

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
      where: 'id = ?',
      whereArgs: [exercise.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercise>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName, orderBy: 'name');
    return data.map((entry) => Exercise.fromMap(entry)).toList();
  }

  Future<Exercise> fetchById(int id) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Exercise.fromMap(data.first);
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