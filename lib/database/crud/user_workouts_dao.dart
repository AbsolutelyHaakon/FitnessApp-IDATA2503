import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:sqflite/sqflite.dart';

class UserWorkoutsDao {
  final tableName = 'userWorkouts';

  Future<int> create(UserWorkouts userWorkout) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userWorkout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(UserWorkouts userWorkout) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userWorkout.toMap(),
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userWorkout.userId, userWorkout.workoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserWorkouts>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  // Fetch all workouts for a specific user
  Future<List<UserWorkouts>> fetchByUserId(String userId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }



  Future<UserWorkouts> fetchById(String userId, String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userId, workoutId],
    );
    return UserWorkouts.fromMap(data.first);
  }

  Future<void> delete(String userId, String workoutId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userId, workoutId],
    );
  }
}