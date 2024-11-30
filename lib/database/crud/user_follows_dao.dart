import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_follows.dart';
import 'package:sqflite/sqflite.dart';

// DAO for handling user follows
class UserFollowsDao {
  final tableName = 'userFollows';

  // Insert a new follow relationship into the local database
  Future<int> localCreate(UserFollows userFollows) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userFollows.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing follow relationship in the local database
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

  // Fetch all follow relationships from the local database
  Future<List<UserFollows>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserFollows.fromMap(entry)).toList();
  }

  // Fetch a specific follow relationship by userId and followsId from the local database
  Future<UserFollows> localFetchById(int userId, int followsId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userId, followsId],
    );
    return UserFollows.fromMap(data.first);
  }

  // Delete a follow relationship from the local database
  Future<void> localDelete(String userId, String followsId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND followsId = ?',
      whereArgs: [userId, followsId],
    );
  }

////////////////////////////////////////////////////////////
/////////////////// FIREBASE FUNCTIONS /////////////////////
////////////////////////////////////////////////////////////

  // Check if a user follows another user in Firebase
  Future<bool> fireBaseCheckIfFollows(String userId, String followsId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: userId)
        .where('followsId', isEqualTo: followsId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Add a follow relationship in Firebase and local database
  Future<void> fireBaseFollow(String userId, String followsId) async {
    DocumentReference docref =
        await FirebaseFirestore.instance.collection('userFollows').add({
      'userId': userId,
      'followsId': followsId,
    });

    String docId = docref.id;

    localCreate(UserFollows(
        userFollowsId: docId, userId: userId, followsId: followsId));
  }

  // Remove a follow relationship from Firebase and local database
  Future<void> fireBaseUnfollow(String userId, String followsId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: userId)
        .where('followsId', isEqualTo: followsId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.first.reference.delete();
      localDelete(userId, followsId);
    }
  }

  // Fetch all users that the given user is following from Firebase
  Future<Map<String, dynamic>> fetchFollowing(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: userId)
        .get();

    List<UserFollows> following = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userFollowsId'] = doc.id;
      return UserFollows.fromMap(data);
    }).toList();

    return {
      'success': true,
      'following': following,
    };
  }

  // Fetch all users that follow the given user from Firebase
  Future<Map<String, dynamic>> fetchFollowedBy(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('followsId', isEqualTo: userId)
        .get();

    List<UserFollows> following = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userFollowsId'] = doc.id;
      return UserFollows.fromMap(data);
    }).toList();

    return {
      'success': true,
      'following': following,
    };
  }

  // Get the number of followers for a given user from Firebase
  Future<int> fireBaseGetFollowerCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('followsId', isEqualTo: uid)
        .get();
    return querySnapshot.size;
  }

  // Get the number of users that the given user is following from Firebase
  Future<int> fireBaseGetFollowingCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: uid)
        .get();
    return querySnapshot.size;
  }

}