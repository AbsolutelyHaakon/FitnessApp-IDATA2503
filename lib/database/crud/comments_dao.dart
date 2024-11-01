import 'package:fitnessapp_idata2503/database/tables/comments.dart';
import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

class CommentsDao {
  final tableName = 'comments';

  Future<int> create(Comments comment) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Comments comment) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      comment.toMap(),
      where: 'commentId = ?',
      whereArgs: [comment.commentId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Comments>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Comments.fromMap(entry)).toList();
  }

  Future<Comments> fetchById(int commentId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'commentId = ?',
      whereArgs: [commentId],
    );
    return Comments.fromMap(data.first);
  }

  Future<void> delete(int commentId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'commentId = ?',
      whereArgs: [commentId],
    );
  }

}