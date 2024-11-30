import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/crud/user_follows_dao.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../imgur_service.dart';

// DAO for handling posts
class PostsDao {
  final tableName = 'posts';
  final UserFollowsDao _userFollowsDao = UserFollowsDao();

  // Function to create a new post in the local database
  Future<int> LocalCreate(Posts post) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to update an existing post in the local database
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

  // Function to fetch all posts from the local database
  Future<List<Posts>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Posts.fromMap(entry)).toList();
  }

  // Function to fetch a post by its ID from the local database
  Future<Posts> localFetchById(int postId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'postId = ?',
      whereArgs: [postId],
    );
    return Posts.fromMap(data.first);
  }

  // Function to delete a post by its ID from the local database
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

  // Function to delete a post from Firebase
  Future<bool> fireBaseDeletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Function to create a new post in Firebase
  Future<Map<String, dynamic>> fireBaseCreatePost(
      String? content,
      XFile? image,
      String? workoutId,
      String? location,
      Map<String, String>? visibleStats,
      String userId) async {
    // A post cant be made if there is no content, image or workout
    if ((content == null || content.isEmpty) &&
        (image == null) &&
        (workoutId == null || workoutId.isEmpty)) {
      return {
        'success': false,
        'message': 'Post must have content, image or workout to be posted',
      };
    }

    String imageURL = '';
    if (image != null) {
      imageURL = await uploadImage(image);
    }

    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('posts').add({
      'userId': userId,
      'content': content ?? '',
      'imageURL': imageURL ?? '',
      'date': DateTime.now(),
      'workoutId': workoutId ?? '',
      'location': location ?? '',
      'visibleStats': visibleStats ?? {},
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

  // Function to fetch the feed for a user from Firebase
  Future<Map<String, dynamic>> fireBaseFetchFeed(String userId) async {
    // First we find out who the person is following
    Map<String, dynamic> followingMap =
        await _userFollowsDao.fetchFollowing(userId);

    // Then we convert it to a list of user ids
    List<String> following =
        (followingMap['following'] as List<dynamic>).map((userFollows) {
      return userFollows.followsId as String;
    }).toList();

    // Temporary list of all posts
    List<Posts> allPosts = [];

    // For every user you are following, get their posts
    for (String followedUserId in following) {
      Map<String, dynamic> userPostsResult =
          await fireBaseFetchUserPosts(followedUserId);
      List<Posts> userPosts = userPostsResult['posts'];
      allPosts.addAll(userPosts);
    }

    // Sort posts by newest date
    allPosts.sort((a, b) => b.date.compareTo(a.date));

    return {
      'posts': allPosts,
    };
  }

  // Function to fetch all posts for a specific user from Firebase
  Future<Map<String, dynamic>> fireBaseFetchUserPosts(String? userId) async {
    // If the user has no posts, return an empty list
    if (userId == null) {
      return {
        'posts': [],
      };
    }

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

  ImgurService imgurService = ImgurService();

  // Function to upload an image to Imgur and return the URL
  Future<String> uploadImage(XFile image) async {
    String? imgurUrl = await imgurService.saveImageToImgur(image);
    if (imgurUrl != null) {
      print('Image uploaded to Imgur: $imgurUrl');
      return imgurUrl;
    } else {
      print('Failed to upload to Imgur.');
      return "";
    }
  }

//////////////////////////////////////////////////////////////////////////////
////////////////////////////  Firebase Admin /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

  // Function to get the count of posts in Firebase
  Future<int> getPostsCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    return querySnapshot.docs.length;
  }
}