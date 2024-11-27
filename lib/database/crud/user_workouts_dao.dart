import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:sqflite/sqflite.dart';

import '../tables/workout.dart';

class UserWorkoutsDao {
  final tableName = 'userWorkouts';

  Future<UserWorkouts> localCreate(UserWorkouts userWorkout) async {
    final database = await DatabaseService().database;

    // Check if userWorkoutId is "1" and generate a unique ID if necessary
    if (userWorkout.userWorkoutId == "1") {
      userWorkout = UserWorkouts(
        userWorkoutId:
            '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}',
        userId: userWorkout.userId,
        workoutId: userWorkout.workoutId,
        date: userWorkout.date,
        duration: userWorkout.duration,
        statistics: userWorkout.statistics,
        isActive: userWorkout.isActive,
      );
    }

    await database.insert(
      tableName,
      userWorkout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return userWorkout;
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

  Future<UserWorkouts?> localFetchById(String userId, String workoutId) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userId, workoutId],
    );

    if (maps.isNotEmpty) {
      return UserWorkouts.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<UserWorkouts?> localFetchByUserWorkoutsId(String userWorkoutId) async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'userWorkoutId = ?',
      whereArgs: [userWorkoutId],
    );

    if (maps.isNotEmpty) {
      return UserWorkouts.fromMap(maps.first);
    } else {
      return null;
    }
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

  Future<void> localSetAllInactive() async {
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      {'isActive': 0},
    );
  }

  Future<void> localSetActive(
      String workoutId, DateTime date, bool isActive) async {
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      {'isActive': isActive ? 1 : 0},
      where: 'workoutId = ? AND date = ?',
      whereArgs: [workoutId, date],
    );
  }

  Future<void> localUpdateActive(
      UserWorkouts userWorkout, bool isActive) async {
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      {'isActive': isActive ? 1 : 0},
      where: 'userId = ? AND workoutId = ?',
      whereArgs: [userWorkout.userId, userWorkout.workoutId],
    );
  }

  Future<Workouts?> fetchActiveUserWorkout() async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'isActive = ?',
      whereArgs: [1],
    );

    if (data.isNotEmpty) {
      final userWorkout = UserWorkouts.fromMap(data.first);
      final workoutData = await database.query(
        'workouts',
        where: 'workoutId = ?',
        whereArgs: [userWorkout.workoutId],
      );

      return Workouts.fromMap(workoutData.first);
    }

    return null;
  }

  /////////////////////////////////////////////////////////
  ////////////// FIREBASE FUNCTIONS ///////////////////////
  /////////////////////////////////////////////////////////

  Future<UserWorkouts> fireBaseFetchUserWorkoutById(
      String userWorkoutId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .doc(userWorkoutId)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['userWorkoutId'] = doc.id;
    return UserWorkouts.fromMap(data);
  }

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
      duration: 0.0,
      statistics: '',
      isActive: false,
    ));

    return newDocId;
  }

  Future<String> fireBaseUpdateUserWorkout(
      String userWorkoutId,
      String userId,
      String workoutId,
      DateTime date,
      String? workoutStats,
      int duration) async {

    print('Updating user workout with id: $userWorkoutId');

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .doc(userWorkoutId)
        .get();

    if (docSnapshot.exists) {
      await docSnapshot.reference.update({
        'statistics': workoutStats,
        'duration': duration,
      });

      await localUpdate(UserWorkouts(
        userWorkoutId: userWorkoutId,
        userId: userId,
        workoutId: workoutId,
        date: date,
        duration: duration.toDouble(),
        statistics: workoutStats,
        isActive: false,
      ));

      return userWorkoutId;
    } else {
      throw Exception('No matching user workout found');
    }
  }

  Future<Map<String, dynamic>> fireBaseFetchUpcomingWorkouts(String uid) async {
    DateTime startOfDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    QuerySnapshot upcomingWorkoutsQuery = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .where('userId', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
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

  Future<Map<String, dynamic>> fireBaseFetchPreviousWorkouts(String uid) async {
    QuerySnapshot previousWorkoutsQuery = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .where('userId', isEqualTo: uid)
        .where('date', isLessThanOrEqualTo: DateTime.now())
        .get();

    List<UserWorkouts> previousWorkouts = previousWorkoutsQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userWorkoutId'] = doc.id;
      return UserWorkouts.fromMap(data);
    }).toList();

    return {'previousWorkouts': previousWorkouts};
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
