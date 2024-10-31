import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_health_data.dart';
import 'package:sqflite/sqflite.dart';

class UserHealthDataDao {
  final tableName = 'userHealthData';

  Future<int> create(UserHealthData userHealthData) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userHealthData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(UserHealthData userHealthData) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userHealthData.toMap(),
      where: 'userId = ? AND date = ?',
      whereArgs: [userHealthData.userId, userHealthData.date.toIso8601String()],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserHealthData>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserHealthData.fromMap(entry)).toList();
  }

  Future<UserHealthData> fetchById(int userId, DateTime date) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );
    return UserHealthData.fromMap(data.first);
  }

  Future<void> delete(int userId, DateTime date) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );
  }
}