import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../database_service.dart';
import '../tables/favorite_workouts.dart';

// DAO class for handling favorite workouts
class FavoriteWorkoutsDao {
  final tableName = 'favoriteWorkouts';

  // Function to create a new favorite workout in the local database
  Future<void> localCreate(FavoriteWorkouts favoriteWorkouts) async {
    // If the favoriteWorkoutId is "1", generate a new ID based on the current timestamp
    if (favoriteWorkouts.favoriteWorkoutId == "1") {
      favoriteWorkouts = FavoriteWorkouts(
        favoriteWorkoutId: '${DateTime.now().millisecondsSinceEpoch}',
        userId: favoriteWorkouts.userId,
        workoutId: favoriteWorkouts.workoutId,
      );
    }

    // Get the database instance and insert the new favorite workout
    final database = await DatabaseService().database;
    await database.insert(
      tableName,
      favoriteWorkouts.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to update an existing favorite workout in the local database
  Future<void> localUpdate(FavoriteWorkouts favoriteWorkouts) async {
    // Get the database instance and update the favorite workout
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      favoriteWorkouts.toMap(),
      where: 'favoriteWorkoutId = ?',
      whereArgs: [favoriteWorkouts.favoriteWorkoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to fetch all favorite workouts for a specific user from the local database
  Future<List<FavoriteWorkouts>> localFetchByUserId(String? userId) async {
    // Get the database instance and query for favorite workouts by userId
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId ?? ''],
    );
    // Map the query results to a list of FavoriteWorkouts objects
    return data.map((entry) => FavoriteWorkouts.fromMap(entry)).toList();
  }

  // Function to delete all favorite workouts from the local database
  Future<void> localTruncate() async {
    // Get the database instance and delete all entries in the favoriteWorkouts table
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  // Function to delete a specific favorite workout from the local database by its ID
  Future<void> localDelete(String favoriteWorkoutId) async {
    // Get the database instance and delete the favorite workout by its ID
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'favoriteWorkoutId = ?',
      whereArgs: [favoriteWorkoutId],
    );
  }

  // Function to delete a favorite workout from the local database by userId and workoutId
  Future<void> localDeleteByUserIdAndWorkoutId(
      String userId, String workoutId) async {
    // Get the database instance and delete the favorite workout by userId and workoutId
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

  // Function to create a new favorite workout in Firebase and the local database
  Future<Map<String, dynamic>> fireBaseCreateFavoriteWorkout(
      String userId, String workoutId) async {
    // Add a new favorite workout to the Firebase collection
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('favoriteWorkouts').add({
      'userId': userId,
      'workoutId': workoutId,
    });

    // Get the new document ID
    String newDocId = docRef.id;

    // Create the favorite workout in the local database
    await localCreate(FavoriteWorkouts(
      favoriteWorkoutId: newDocId,
      userId: userId,
      workoutId: workoutId,
    ));

    // Return success and the new favorite workout ID
    return {"Success": true, "favoriteWorkoutId": newDocId};
  }

  // Function to delete a favorite workout from Firebase and the local database
  Future<Map<String, dynamic>> fireBaseDeleteFavoriteWorkout(
      String userId, String workoutId) async {
    // Query Firebase for the favorite workout by userId and workoutId
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('favoriteWorkouts')
        .where('userId', isEqualTo: userId)
        .where('workoutId', isEqualTo: workoutId)
        .get();
    if (querySnapshot.docs.isEmpty) {
      // If no favorite workout is found, return an error
      return {"Success": false, "Error": "Favorite Workout not found"};
    }
    // Delete each document found in the query
    for (var doc in querySnapshot.docs) {
      doc.reference.delete();
    }

    // Delete the favorite workout from the local database
    await localDeleteByUserIdAndWorkoutId(userId, workoutId);

    // Return success
    return {"Success": true};
  }

  // Function to fetch all favorite workouts for a specific user from Firebase
  Future<Map<String, dynamic>> fireBaseFetchAllFavoriteWorkouts(String userId) {
    // Query Firebase for favorite workouts by userId
    return FirebaseFirestore.instance
        .collection('favoriteWorkouts')
        .where('userId', isEqualTo: userId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<FavoriteWorkouts> favoriteWorkouts = [];
      // Map the query results to a list of FavoriteWorkouts objects
      for (var doc in querySnapshot.docs) {
        favoriteWorkouts.add(FavoriteWorkouts(
          favoriteWorkoutId: doc.id,
          userId: doc['userId'],
          workoutId: doc['workoutId'],
        ));
      }
      // Return the list of favorite workouts
      return {"favoriteWorkouts": favoriteWorkouts};
    });
  }
}
