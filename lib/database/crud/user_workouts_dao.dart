import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:sqflite/sqflite.dart';

import '../tables/workout.dart';

/// Data Access Object (DAO) for handling user workouts in the database
class UserWorkoutsDao {
  final tableName = 'userWorkouts';

  /// Create a new user workout in the local database
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

  /// Update an existing user workout in the local database
  Future<int> localUpdate(UserWorkouts userWorkout) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userWorkout.toMap(),
      where: 'userWorkoutId = ?',
      whereArgs: [userWorkout.userWorkoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all user workouts from the local database
  Future<List<UserWorkouts>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  /// Fetch user workouts by user ID from the local database
  Future<List<UserWorkouts>> localFetchByUserId(String userId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  /// Fetch a specific user workout by user ID and workout ID from the local database
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

  /// Fetch a specific user workout by user workout ID from the local database
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

  /// Delete a specific user workout by user workout ID from the local database
  Future<bool> localDelete(String userWorkoutId) async {
    final database = await DatabaseService().database;
    final rowsAffected = await database.delete(
      tableName,
      where: 'userWorkoutId = ?',
      whereArgs: [userWorkoutId],
    );
    if (rowsAffected > 0) {
      return true;
    } else {
      return false;
    }
  }

  /// Delete all user workouts from the local database
  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  /// Fetch upcoming user workouts by user ID from the local database
  Future<List<UserWorkouts>> localFetchUpcomingUserWorkouts(String id) async {
    final database = await DatabaseService().database;

    // Set the start of the day
    DateTime startOfDay =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Fetch all workouts for the user
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date >= ?',
      whereArgs: [id, startOfDay.toIso8601String()],
    );

    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  Future<List<UserWorkouts>> localFetchThisWeeksUserWorkouts(String id) async {
    final database = await DatabaseService().database;

    DateTime today = DateTime.now();
    DateTime startOfWeek = today
        .subtract(Duration(days: today.weekday))
        .subtract(Duration(
            hours: today.hour,
            minutes: today.minute,
            seconds: today.second,
            milliseconds: today.millisecond,
            microseconds: today.microsecond));
    DateTime endOfWeek = startOfWeek
        .add(const Duration(days: 6))
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));

    // fetch all workouts for the user
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        id,
        startOfWeek.toIso8601String(),
        endOfWeek.toIso8601String()
      ],
    );

    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  // Fetch the user workout for the current day
  Future<UserWorkouts?> localFetchTodaysWorkout() async {
    final database = await DatabaseService().database;

    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay =
        startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    final data = await database.query(
      tableName,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date ASC',
      limit: 1,
    );

    if (data.isNotEmpty) {
      return UserWorkouts.fromMap(data.first);
    } else {
      return null;
    }
  }

  /// Fetch previous user workouts by user ID from the local database
  Future<List<UserWorkouts>> localFetchPreviousUserWorkouts(String id) async {
    final database = await DatabaseService().database;

    // fetch all workouts for the user
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date <= ?',
      whereArgs: [id, DateTime.now().toIso8601String()],
    );

    return data.map((entry) => UserWorkouts.fromMap(entry)).toList();
  }

  /// Fetch upcoming workouts by user ID from the local database
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

  /// Fetch previous workouts by user ID from the local database
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

  /// Set all user workouts to inactive in the local database
  Future<void> localSetAllInactive() async {
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      {'isActive': 0},
    );
  }

  /// Set a specific user workout to active or inactive in the local database
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

  /// Update the active status of a specific user workout in the local database
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

  /// Fetch the active user workout from the local database
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

  Future<bool> localReplaceUserWorkout(
      UserWorkouts userWorkout, Workouts newWorkout) async {
    final deleted = await localDelete(userWorkout.userWorkoutId);
    if (deleted) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'localUser';
      await localCreate(UserWorkouts(
        userWorkoutId: '1',
        userId: userId,
        workoutId: newWorkout.workoutId,
        date: userWorkout.date,
        duration: 0.0,
        statistics: '',
        isActive: false,
      ));
      return true;
    }
    return false;
  }

  /////////////////////////////////////////////////////////
  ////////////// FIREBASE FUNCTIONS ///////////////////////
  /////////////////////////////////////////////////////////

  /// Fetch a user workout by ID from Firebase
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

  /// Create a new user workout in Firebase
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

  /// Update an existing user workout in Firebase
  Future<String> fireBaseUpdateUserWorkout(
      String userWorkoutId,
      String userId,
      String workoutId,
      DateTime date,
      String? workoutStats,
      double duration) async {
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
        duration: duration,
        statistics: workoutStats,
        isActive: false,
      ));

      return userWorkoutId;
    } else {
      throw Exception('No matching user workout found');
    }
  }

  /// Fetch upcoming workouts by user ID from Firebase
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

  /// Delete a user workout from Firebase
  Future<bool> fireBaseDeleteUserWorkout(UserWorkouts userWorkout) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (userWorkout != null && uid != null) {
      // Delete from Firebase
      final querySnapshot = await FirebaseFirestore.instance
          .collection('userWorkouts')
          .doc(userWorkout.userWorkoutId)
          .delete();

      // Delete locally
      await localDelete(userWorkout.userWorkoutId);

      return true;
    }
    return false;
  }

  /// Fetch previous workouts by user ID from Firebase
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

  /// Replace a user workout in Firebase
  Future<bool> fireBaseReplaceUserWorkout(
      UserWorkouts userWorkout, Workouts newWorkout) async {
    final deleted = await fireBaseDeleteUserWorkout(userWorkout);
    if (deleted) {
      fireBaseCreateUserWorkout(
          newWorkout.userId, newWorkout.workoutId, userWorkout.date);
      return true;
    }
    return false;
  }

  /// Set personal bests for a user in Firebase
  Future<void> fireBaseSetPersonalBests(String uid) async {
    if (uid == '') return;
    final result = await fireBaseFetchPreviousWorkouts(uid);

    Map<String, dynamic> personalBests = {};

    for (UserWorkouts workout in result['previousWorkouts']) {
      if (workout.statistics == 'null' ||
          workout.statistics == '' ||
          workout.statistics == null) continue;
      print('Workout stats: ${workout.statistics}');
      final stats = workout.statistics;
      Map<String, dynamic> decodedStats = jsonDecode(stats!);

      decodedStats.forEach((exercise, sets) {
        int maxWeightForExercise = 0;

        for (var set in sets) {
          int weight = set['weight'];
          if (weight > maxWeightForExercise && weight != 0) {
            maxWeightForExercise = weight;
          }
        }

        if ((personalBests[exercise] == null ||
                personalBests[exercise] < maxWeightForExercise) &&
            maxWeightForExercise > 0) {
          personalBests[exercise] = maxWeightForExercise;
        }
      });
    }

    QuerySnapshot personalBestsQuery = await FirebaseFirestore.instance
        .collection('userPersonalBests')
        .where('userId', isEqualTo: uid)
        .get();

    if (personalBestsQuery.docs.length <= 0) {
      await FirebaseFirestore.instance.collection('userPersonalBests').add({
        'userId': uid,
        'personalBestMap': personalBests,
      });
    } else {
      personalBestsQuery.docs.first.reference.update({
        'personalBestMap': personalBests,
      });
    }
  }

  /// Get personal bests for a user from Firebase
  Future<Map<String, dynamic>> fireBaseGetPersonalBests(String uid) async {
    if (uid == '') return {};

    QuerySnapshot personalBestsQuery = await FirebaseFirestore.instance
        .collection('userPersonalBests')
        .where('userId', isEqualTo: uid)
        .get();

    if (personalBestsQuery.docs.isNotEmpty) {
      final doc = personalBestsQuery.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['personalBestMap'];
    }

    return {};
  }
}
