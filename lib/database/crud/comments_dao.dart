import 'package:fitnessapp_idata2503/database/tables/comments.dart';
import 'package:sqflite/sqflite.dart';

import '../database_service.dart';

// DAO class for handling comments in the database
class CommentsDao {
  final tableName = 'comments'; // Name of the table in the database

  // Function to insert a new comment into the database
  Future<int> localCreate(Comments comment) async {
    final database = await DatabaseService().database; // Get the database instance
    return await database.insert(
      tableName, // Table name
      comment.toMap(), // Convert the comment object to a map
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if there's a conflict
    );
  }

  // Function to update an existing comment in the database
  Future<int> localUpdate(Comments comment) async {
    final database = await DatabaseService().database; // Get the database instance
    return await database.update(
      tableName, // Table name
      comment.toMap(), // Convert the comment object to a map
      where: 'commentId = ?', // Specify the comment to update
      whereArgs: [comment.commentId], // Arguments for the where clause
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if there's a conflict
    );
  }

  // Function to fetch all comments from the database
  Future<List<Comments>> localFetchAll() async {
    final database = await DatabaseService().database; // Get the database instance
    final data = await database.query(tableName); // Query all rows from the table
    return data.map((entry) => Comments.fromMap(entry)).toList(); // Convert each row to a Comments object and return the list
  }

  // Function to fetch a specific comment by its ID
  Future<Comments> localFetchById(int commentId) async {
    final database = await DatabaseService().database; // Get the database instance
    final data = await database.query(
      tableName, // Table name
      where: 'commentId = ?', // Specify the comment to fetch
      whereArgs: [commentId], // Arguments for the where clause
    );
    return Comments.fromMap(data.first); // Convert the first row to a Comments object and return it
  }

  // Function to delete a specific comment by its ID
  Future<void> localDelete(int commentId) async {
    final database = await DatabaseService().database; // Get the database instance
    await database.delete(
      tableName, // Table name
      where: 'commentId = ?', // Specify the comment to delete
      whereArgs: [commentId], // Arguments for the where clause
    );
  }
}