import 'package:fitnessapp_idata2503/database/tables/comments.dart';
import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

class CommentsDao {
  final tableName = 'comments';

  Future<int> localCreate(Comments comment) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> localUpdate(Comments comment) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      comment.toMap(),
      where: 'commentId = ?',
      whereArgs: [comment.commentId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Comments>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Comments.fromMap(entry)).toList();
  }

  Future<Comments> localFetchById(int commentId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'commentId = ?',
      whereArgs: [commentId],
    );
    return Comments.fromMap(data.first);
  }

  Future<void> localDelete(int commentId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'commentId = ?',
      whereArgs: [commentId],
    );
  }

}