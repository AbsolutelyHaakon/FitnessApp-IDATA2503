import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<bool> fireBaseCheckIfFollows(String userId, String followsId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: userId)
        .where('followsId', isEqualTo: followsId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

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

  Future<int> fireBaseGetFollowerCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('followsId', isEqualTo: uid)
        .get();
    return querySnapshot.size;
  }

  Future<int> fireBaseGetFollowingCount(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userFollows')
        .where('userId', isEqualTo: uid)
        .get();
    return querySnapshot.size;
  }

}
