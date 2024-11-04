import 'package:fitnessapp_idata2503/database/database_service.dart';

class SocialFeed {
  Future<List<Map<String, dynamic>>> fetchSocialFeed(int userId) async {
    final database = await DatabaseService().database;
    final data = await database.rawQuery('''
      SELECT p.postId, p.userId, u.username, p.postContent, p.postDate
      FROM posts p
      JOIN userFollows f ON p.userId = f.followsId
      JOIN users u ON p.userId = u.userId
      WHERE f.userId = ?
      ORDER BY p.postDate DESC
    ''', [userId]);

    return data;
  }
}