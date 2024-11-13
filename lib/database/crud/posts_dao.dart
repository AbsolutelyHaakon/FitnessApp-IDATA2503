import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/crud/user_follows_dao.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:sqflite/sqflite.dart';

class PostsDao {
  final tableName = 'posts';
  final UserFollowsDao _userFollowsDao = UserFollowsDao();

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

/////////////////////////////////////////////////////////
////////////////// FIREBASE FUNCTIONS ///////////////////
/////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> fireBaseCreatePost(
      String? content,
      String? imageURL,
      String? workoutId,
      String? location,
      List<String>? visibleStats,
      String userId) async {
    // A post cant be made if there is no content, image or workout
    if ((content == null || content.isEmpty) &&
        (imageURL == null || imageURL.isEmpty) &&
        (workoutId == null || workoutId.isEmpty)) {
      return {
        'success': false,
        'message': 'Post must have content, image or workout to be posted',
      };
    }
    DocumentReference docRef = await FirebaseFirestore.instance.collection('posts').add({
      'userId': userId,
      'content': content ?? '',
      'imageURL': imageURL ?? '',
      'date': DateTime.now(),
      'workoutId': workoutId ?? '',
      'location': location ?? '',
    });

    String newPostId = docRef.id;

    LocalCreate(Posts(
        postId: newPostId,
        userId: userId,
        content: content,
        date: DateTime.now()));

    return {
      'success': true,
      'message': 'Post created successfully',
    };
  }

  Future<Map<String, dynamic>> fireBaseFetchFeed(String userId) async {
  Map<String, dynamic> followingMap = await _userFollowsDao.fetchFollowing(userId);

  List<String> following = followingMap['following'].map((userFollows) {
    return userFollows.followsId;
  }).toList();


  List<Posts> allPosts = [];


  for (String followedUserId in following) {
    Map<String, dynamic> userPostsResult = await fireBaseFetchUserPosts(followedUserId);
    List<Posts> userPosts = userPostsResult['posts'];
    allPosts.addAll(userPosts);
  }

  return {
    'posts': allPosts,
  };
}

  Future<Map<String, dynamic>> fireBaseFetchUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    List<Posts> userPosts = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['postId'] = doc.id;
      return Posts.fromMap(data);
    }).toList();

    return {
      'posts': userPosts,
    };
  }
}
