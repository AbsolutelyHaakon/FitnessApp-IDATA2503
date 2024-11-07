import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:sqflite/sqflite.dart';

class PostsDao {
  final tableName = 'posts';

  Future<int> LocalCreate(Posts post) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> localUpdate(Posts post) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      post.toMap(),
      where: 'postId = ?',
      whereArgs: [post.postId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Posts>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Posts.fromMap(entry)).toList();
  }

  Future<Posts> localFetchById(int postId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'postId = ?',
      whereArgs: [postId],
    );
    return Posts.fromMap(data.first);
  }

  Future<void> localDelete(int postId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'postId = ?',
      whereArgs: [postId],
    );
  }
}