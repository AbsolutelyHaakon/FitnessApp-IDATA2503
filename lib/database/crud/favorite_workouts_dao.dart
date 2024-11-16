import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../database_service.dart';
import '../tables/favorite_workouts.dart';

class FavoriteWorkoutsDao {
  final tableName = 'favoriteWorkouts';

  Future<void> localCreate(FavoriteWorkouts favoriteWorkouts) async {
    final database = await DatabaseService().database;
    await database.insert(
      tableName,
      favoriteWorkouts.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> localUpdate(FavoriteWorkouts favoriteWorkouts) async {
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      favoriteWorkouts.toMap(),
      where: 'favoriteWorkoutId = ?',
      whereArgs: [favoriteWorkouts.favoriteWorkoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FavoriteWorkouts>> localFetchByUserId(String? userId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId ?? ''],
    );
    return data.map((entry) => FavoriteWorkouts.fromMap(entry)).toList();
  }

  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  Future<void> localDelete(String favoriteWorkoutId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'favoriteWorkoutId = ?',
      whereArgs: [favoriteWorkoutId],
    );
  }

  Future<void> localDeleteByUserIdAndWorkoutId(String userId,
      String workoutId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userId, workoutId],
    );
  }

/////////////////////////////////////////////////////////
////////////// FIREBASE FUNCTIONS ///////////////////////
/////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> fireBaseCreateFavoriteWorkout(String userId,
      String workoutId) async {
    DocumentReference docRef = await FirebaseFirestore.instance.collection(
        'favoriteWorkouts').add({
      'userId': userId,
      'workoutId': workoutId,
    });

    String newDocId = docRef.id;

    await localCreate(FavoriteWorkouts(
      favoriteWorkoutId: newDocId,
      userId: userId,
      workoutId: workoutId,
    ));

    return {"Success": true, "favoriteWorkoutId": newDocId};
  }

  Future<Map<String, dynamic>> fireBaseDeleteFavoriteWorkout(String userId, String workoutId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('favoriteWorkouts').where('userId', isEqualTo: userId).where('workoutId', isEqualTo: workoutId).get();
    if (querySnapshot.docs.isEmpty) {
      return {"Success": false, "Error": "Favorite Workout not found"};
    }
    for (var doc in querySnapshot.docs) {
      doc.reference.delete();
    }

    await localDeleteByUserIdAndWorkoutId(userId, workoutId);

    return {"Success": true};
  }

  Future<Map<String, dynamic>> fireBaseFetchAllFavoriteWorkouts(String userId){
    return FirebaseFirestore.instance.collection('favoriteWorkouts').where('userId', isEqualTo: userId).get().then((QuerySnapshot querySnapshot) {
      List<FavoriteWorkouts> favoriteWorkouts = [];
      querySnapshot.docs.forEach((doc) {
        favoriteWorkouts.add(FavoriteWorkouts(
          favoriteWorkoutId: doc.id,
          userId: doc['userId'],
          workoutId: doc['workoutId'],
        ));
      });
      return {"favoriteWorkouts": favoriteWorkouts};
    });
  }

}