import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_follows.dart';
import 'package:sqflite/sqflite.dart';

class UserFollowsDao {
  final tableName = 'userFollows';

  Future<int> create(UserFollows userFollows) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userFollows.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(UserFollows userFollows) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userFollows.toMap(),
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userFollows.userId, userFollows.followsId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserFollows>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserFollows.fromMap(entry)).toList();
  }

  Future<UserFollows> fetchById(int userId, int followsId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userId, followsId],
    );
    return UserFollows.fromMap(data.first);
  }

  Future<void> delete(int userId, int followsId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userId, followsId],
    );
  }
}