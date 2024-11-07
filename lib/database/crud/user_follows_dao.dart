import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_follows.dart';
import 'package:sqflite/sqflite.dart';

class UserFollowsDao {
  final tableName = 'userFollows';

  Future<int> localCreate(UserFollows userFollows) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userFollows.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> localUpdate(UserFollows userFollows) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userFollows.toMap(),
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userFollows.userId, userFollows.followsId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserFollows>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserFollows.fromMap(entry)).toList();
  }

  Future<UserFollows> localFetchById(int userId, int followsId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userId, followsId],
    );
    return UserFollows.fromMap(data.first);
  }

  Future<void> localDelete(int userId, int followsId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userId, followsId],
    );
  }
}