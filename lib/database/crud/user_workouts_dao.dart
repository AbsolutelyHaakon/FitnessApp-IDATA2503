import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:sqflite/sqflite.dart';

import '../tables/workout.dart';

class UserWorkoutsDao {
  final tableName = 'userWorkouts';

  Future<int> localCreate(UserWorkouts userWorkout) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userWorkout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> localUpdate(UserWorkouts userWorkout) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userWorkout.toMap(),
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userWorkout.userId, userWorkout.workoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserWorkouts>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  Future<List<UserWorkouts>> localFetchByUserId(String userId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  Future<UserWorkouts> localFetchById(String userId, String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userId, workoutId],
    );
    return UserWorkouts.fromMap(data.first);
  }

  Future<void> localDelete(String userId, String workoutId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userId, workoutId],
    );
  }

  Future<List<UserWorkouts>> localFetchUpcomingUserWorkouts(String id) async {
    final database = await DatabaseService().database;

    // fetch all workouts for the user
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date >= ?',
      whereArgs: [id, DateTime.now().millisecondsSinceEpoch],
    );

    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  Future<List<UserWorkouts>> localFetchPreviousUserWorkouts(String id) async {
    final database = await DatabaseService().database;

    // fetch all workouts for the user
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date <= ?',
      whereArgs: [id, DateTime.now().millisecondsSinceEpoch],
    );

    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  Future<Map<Workouts, DateTime>> FetchUpcomingWorkouts(String uid) async {
    final database = await DatabaseService().database;

    Map<Workouts, DateTime> upcomingWorkouts = {};
    final data = await localFetchUpcomingUserWorkouts(uid);

    for (UserWorkouts userWorkout in data) {
      final upcomingWorkoutData = await database.query(
        'workouts',
        where: 'workoutId = ?',
        whereArgs: [userWorkout.workoutId],
      );

      upcomingWorkouts[Workouts.fromMap(upcomingWorkoutData.first)] =
          userWorkout.date;
    }

    return upcomingWorkouts;
  }

  Future<Map<Workouts, DateTime>> FetchPreviousWorkouts(String uid) async {
    final database = await DatabaseService().database;

    Map<Workouts, DateTime> upcomingWorkouts = {};
    final data = await localFetchPreviousUserWorkouts(uid);

    for (UserWorkouts userWorkout in data) {
      final upcomingWorkoutData = await database.query(
        'workouts',
        where: 'workoutId = ?',
        whereArgs: [userWorkout.workoutId],
      );

      upcomingWorkouts[Workouts.fromMap(upcomingWorkoutData.first)] =
          userWorkout.date;
    }

    return upcomingWorkouts;
  }

  /////////////////////////////////////////////////////////
  ////////////// FIREBASE FUNCTIONS ///////////////////////
  /////////////////////////////////////////////////////////

  Future<String?> fireBaseCreateUserWorkout(
      String userId, String workoutId, DateTime date) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('userWorkouts').add({
      'userId': userId,
      'workoutId': workoutId,
      'date': date,
    });

    String newDocId = docRef.id;

    localCreate(UserWorkouts(
      userWorkoutId: newDocId,
      userId: userId,
      workoutId: workoutId,
      date: date,
      duration: 0,
      statistics: '',
    ));

    return newDocId;
  }

  Future<Map<String, dynamic>> fireBaseFetchUpcomingWorkouts(String uid) async {
    QuerySnapshot upcomingWorkoutsQuery = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: DateTime.now())
        .get();

    List<UserWorkouts> upcomingWorkouts = upcomingWorkoutsQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userWorkoutId'] = doc.id;
      return UserWorkouts.fromMap(data);
    }).toList();

    return {'upcomingWorkouts': upcomingWorkouts};
  }

  Future<bool> fireBaseDeleteUserWorkout(
      String workoutId, DateTime date) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (workoutId.isNotEmpty && uid != null) {
      // Delete from Firebase
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userWorkouts')
          .where('userId', isEqualTo: uid)
          .where('workoutId', isEqualTo: workoutId)
          .where('date', isEqualTo: date)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete locally
      await localDelete(uid, workoutId);

      return true;
    }
    return false;
  }

  Future<bool> fireBaseReplaceUserWorkout(String toBeDeletedId, String userId,
      String workoutId, DateTime date) async {
    final deleted = await fireBaseDeleteUserWorkout(toBeDeletedId, date);

    if (deleted) {
      fireBaseCreateUserWorkout(userId, workoutId, date);
      return true;
    }
    return false;
  }
}
