import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/imgur_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/exercise.dart';
import '../tables/workout.dart';

/// This class handles all the CRUD operations for workouts in both local SQLite database and Firebase Firestore.
class WorkoutDao {
  final tableName = 'workouts';
  final WorkoutExercisesDao _workoutDao = WorkoutExercisesDao();
  final UserDao _userDao = UserDao();

  /// Inserts a new workout into the local database.
  Future<int> localCreate(Workouts workout) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing workout in the local database.
  Future<int> localUpdate(Workouts workout) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      workout.toMap(),
      where: 'workoutId = ?',
      whereArgs: [workout.workoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates the isActive status of a workout in the local database.
  Future<void> localUpdateActive(Workouts workout, bool isActive) async {
    final database = await DatabaseService().database;

    // Update the isActive value based on the input
    await database.update(
      tableName,
      {'isActive': isActive ? 1 : 0},
      where: 'workoutId = ?',
      whereArgs: [workout.workoutId],
    );
  }

  /// Sets all workouts to inactive in the local database.
  Future<void> localSetAllInactive() async {
    final database = await DatabaseService().database;

    await database.update(
      tableName,
      {'isActive': 0},
    );
  }

  /// Updates the exercises associated with a workout in the local database.
  Future<void> localUpdateWorkoutExercises(
      String workoutId, List<Exercises> exercises) async {
    final database = await DatabaseService().database;
    await database.transaction((txn) async {
      await txn.delete('workoutExercises',
          where: 'workoutId = ?', whereArgs: [workoutId]);
      for (var exercise in exercises) {
        await txn.insert('workoutExercises', {
          'workoutId': workoutId,
          'exerciseId': exercise.exerciseId,
        });
      }
    });
  }

  /// Fetches a workout by its ID from the local database.
  Future<Workouts> localFetchWorkoutById(String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    return Workouts.fromMap(data.first);
  }

  /// Fetches all workouts from the local database.
  Future<List<Workouts>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName, orderBy: 'name');
    return data.map((entry) => Workouts.fromMap(entry)).toList();
  }

  /// Fetches all workouts by user ID from the local database.
  Future<List<Workouts>> localFetchAllById(String? id) async {
    final database = await DatabaseService().database;
    if (id != null && id.isNotEmpty) {
      final privateData = await database.query(
        tableName,
        where: 'userId = ? AND isDeleted = ?',
        whereArgs: [id, 0],
      );
      final publicData = await database.query(
        tableName,
        where: 'isPrivate = ? AND userId = ? AND isDeleted = ?',
        whereArgs: [0, '', 0],
      );
      return [...privateData, ...publicData]
          .map((entry) => Workouts.fromMap(entry))
          .toList();
    } else {
      final data = await database.query(
        tableName,
        where:
            '(isPrivate = ? AND userId = ? AND isDeleted = ?) OR (isPrivate = ? AND userId = ? AND isDeleted = ?)',
        whereArgs: [0, '', 0, 1, '', 0],
      );
      return data.map((entry) => Workouts.fromMap(entry)).toList();
    }
  }

  /// Fetches a workout by its ID from the local database.
  Future<Workouts?> localFetchByWorkoutId(String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    if (data.isNotEmpty) {
      return Workouts.fromMap(data.first);
    } else {
      return null;
    }
  }

  /// Deletes a workout by its ID from the local database.
  Future<void> localDelete(String id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [id],
    );
  }

  /// Marks a workout as deleted in the local database.
  Future<void> localSetDeleted(String id) async {
    final database = await DatabaseService().database;
    await database.update(
      tableName,
      {'isDeleted': 1},
      where: 'workoutId = ?',
      whereArgs: [id],
    );
  }

  /// Fetches all exercises associated with a workout from the local database.
  Future<List<Exercises>> localFetchExercisesForWorkout(
      String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.rawQuery('''
    SELECT exercises.* FROM exercises
    INNER JOIN workoutExercises ON exercises.exerciseId = workoutExercises.exerciseId
    WHERE workoutExercises.workoutId = ?
    ORDER BY workoutExercises.ExerciseOrder ASC
  ''', [workoutId]);
    return data.map((entry) => Exercises.fromSqfl(entry)).toList();
  }

  /// Deletes all workouts from the local database.
  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  /// Checks if there are any active workouts in the local database.
  Future<bool> hasActiveWorkouts() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      'workouts',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.isNotEmpty;
  }

  /// Fetches the active workout from the local database.
  Future<Workouts?> fetchActiveWorkout() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      'workouts',
      where: 'isActive = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Workouts.fromMap(maps.first);
  }

  /// Generates a unique workout ID.
  Future<String> generateUniqueWorkoutId() async {
    final database = await DatabaseService().database;
    final existingIds = await database.query(tableName, columns: ['workoutId']);
    final existingIdSet =
        existingIds.map((e) => e['workoutId'] as String).toSet();

    String newId;
    do {
      newId = _generateRandomId();
    } while (existingIdSet.contains(newId));

    return newId;
  }

  /// Generates a random ID for a workout.
  String _generateRandomId() {
    const length = 10;
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  /// Fetches public workouts from Firebase and stores them locally if not already present.
  Future<void> fireBaseFirstTimeStartup() async {
    final database = await DatabaseService().database;
    final WorkoutExercisesDao workoutExercisesDao = WorkoutExercisesDao();
    // Check for public workouts in the local database
    final publicData = await database.query(
      tableName,
      where: 'isPrivate = ? AND userId = ?',
      whereArgs: [0, ''],
    );

    // If no public workouts exist, fetch from Firestore
    if (publicData.isEmpty) {
      final workouts = await fireBaseFetchPremadeWorkouts();
      for (var workout in workouts['workouts']) {
        await localCreate(workout);
        final temp = await workoutExercisesDao
            .fireBaseFetchAllWorkoutExercises(workout.workoutId);
        for (var exercise in temp['workoutExercises']) {
          await workoutExercisesDao.localCreate(exercise);
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////
  ////////////////// FIREBASE FUNCTIONS //////////////////////
  ////////////////////////////////////////////////////////////

  /// Deletes a workout from Firebase and marks it as deleted locally if it is part of user workouts.
  Future<void> fireBaseDeleteWorkout(String WorkoutId) async {
    // Handle the case where a workout is a part of someones userWorkouts
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .where('workoutId', isEqualTo: WorkoutId)
        .get();

    // if there exists userWorkouts with that workoutId we dont want to delete them, just set them as inactive
    if (querySnapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(WorkoutId)
          .update({'isDeleted': true});
      localSetDeleted(WorkoutId);
    } else {
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(WorkoutId)
          .delete();
      localDelete(WorkoutId);
      _workoutDao.deleteAllWorkoutExercisesWithWorkoutId(WorkoutId);
    }

    final querySnapshot2 = await FirebaseFirestore.instance
        .collection('userWorkoutDuplicate')
        .where('newWorkoutId', isEqualTo: WorkoutId)
        .get();

    for (var doc in querySnapshot2.docs) {
      await doc.reference.delete();
    }
  }

  /// Fetches all workouts for a user from Firebase.
  Future<Map<String, dynamic>> fireBaseFetchAllWorkouts(String userId) async {
    // Get all workouts for the user (public and private)
    QuerySnapshot personalWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();

    // Get all the workouts that are public for all users and has no userId
    QuerySnapshot publicWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('isPrivate', isEqualTo: false)
        .where('userId', isEqualTo: '')
        .get();

    List<Workouts> personalWorkouts = personalWorkoutsQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    List<Workouts> publicWorkouts = publicWorkoutsQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    List<Workouts> allWorkouts = [...personalWorkouts, ...publicWorkouts];

    return {'workouts': allWorkouts};
  }

  /// Fetches a workout by its ID from Firebase.
  Future<Workouts?> fireBaseFetchWorkout(String workoutId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(workoutId)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    } else {
      return null;
    }
  }

  /// Updates a workout in Firebase and locally.
  Future<void> firebaseUpdateWorkout(
      String workoutId,
      String? category,
      String? description,
      int? duration,
      int? intensity,
      bool isPrivate,
      String? userId,
      XFile? image,
      String name,
      bool wantId,
      int? calories,
      int? sets) async {
    if (userId == null) {
      return;
    }

    String? imageURL;
    if (image != null) {
      imageURL = await uploadImage(image);
    }

    // Update it locally
    Workouts? previousWorkout = await localFetchByWorkoutId(workoutId);
    if (previousWorkout == null) {
      return;
    }
    Workouts updatedWorkout = Workouts(
      workoutId: workoutId,
      category: category ?? previousWorkout.category,
      description: description ?? previousWorkout.description,
      duration: duration ?? previousWorkout.duration,
      calories: calories ?? previousWorkout.calories,
      sets: sets ?? previousWorkout.sets,
      intensity: intensity ?? previousWorkout.intensity,
      isPrivate: isPrivate ?? previousWorkout.isPrivate,
      userId: userId ?? previousWorkout.userId,
      imageURL: imageURL ?? previousWorkout.imageURL,
      name: name ?? previousWorkout.name,
      isDeleted: false,
    );

    final result = localUpdate(updatedWorkout);

    // Update it on Firebase
    await FirebaseFirestore.instance
        .collection('workouts')
        .doc(workoutId)
        .update({
      'category': category ?? previousWorkout.category,
      'description': description ?? previousWorkout.description,
      'duration': duration ?? previousWorkout.duration,
      'calories': calories ?? previousWorkout.calories,
      'sets': sets ?? previousWorkout.sets,
      'intensity': intensity ?? previousWorkout.intensity,
      'isPrivate': isPrivate ?? previousWorkout.isPrivate,
      'userId': userId ?? previousWorkout.userId,
      'imageURL': imageURL ?? previousWorkout.imageURL,
      'name': name ?? previousWorkout.name,
    });
  }

  /// Creates a new workout in Firebase and locally.
  Future<String?> fireBaseCreateWorkout(
      String? category,
      String? description,
      int? duration,
      int? intensity,
      bool isPrivate,
      String? userId,
      XFile? image,
      String name,
      bool wantId,
      int? calories,
      int? sets,
      String? PreImageURL) async {
    if (userId != null) {
      String? imageURL;

      if (image != null) {
        imageURL = await uploadImage(image);
      } else {
        imageURL = PreImageURL;
      }

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('workouts').add({
        'category': category ?? '',
        'description': description ?? '',
        'duration': duration ?? 0,
        'calories': calories ?? 0,
        'sets': sets ?? 0,
        'intensity': intensity ?? 0,
        'isPrivate': isPrivate,
        'userId': userId ?? '',
        'imageURL': imageURL ?? '',
        'name': name,
      });

      String newDocId = docRef.id;

      await localCreate(Workouts(
        workoutId: newDocId,
        category: category,
        description: description,
        duration: duration,
        calories: calories,
        sets: sets,
        intensity: intensity,
        isPrivate: isPrivate,
        userId: userId ?? '',
        imageURL: imageURL,
        name: name,
        isDeleted: false,
      ));
      return wantId ? newDocId : null;
    } else {
      String newDocId = _generateRandomId();

      await localCreate(Workouts(
        workoutId: newDocId,
        category: category,
        description: description,
        duration: duration,
        calories: calories,
        sets: sets,
        intensity: intensity,
        isPrivate: isPrivate,
        userId: userId ?? '',
        imageURL: '',
        name: name,
        isDeleted: false,
      ));

      return wantId ? newDocId : null;
    }
  }

  /// Fetches all public workouts from Firebase.
  Future<Map<String, dynamic>> fireBaseFetchPublicWorkouts() async {
    // Fetch our premade workouts
    QuerySnapshot PremadequerySnapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('isPrivate', isEqualTo: false)
        .where('userId', isEqualTo: '')
        .get();

    List<Workouts> workouts = PremadequerySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    // Fetch all public workouts
    QuerySnapshot PublicquerySnapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('isPrivate', isEqualTo: false)
        .where('userId', isNotEqualTo: '')
        .get();

    List<Workouts> publicWorkouts = PublicquerySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    workouts.addAll(publicWorkouts);

    return {'workouts': workouts};
  }

  Future<Map<String, dynamic>> fireBaseFetchPremadeWorkouts() async {
    // Fetch our premade workouts
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('isPrivate', isEqualTo: false)
        .where('userId', isEqualTo: '')
        .get();

    List<Workouts> workouts = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    return {'workouts': workouts};
  }

  /// Fetches all exercises associated with a workout from Firebase.
  Future<List<Exercises>> fireBaseFetchExercisesForWorkout(
      String workoutId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workoutExercises')
        .where('workoutId', isEqualTo: workoutId)
        .get();
    List exerciseIds =
        querySnapshot.docs.map((doc) => doc['exerciseId']).toList();
    List<Exercises> exercises = [];
    for (String exerciseId in exerciseIds) {
      Exercises? exercise =
          await ExerciseDao().fireBaseFetchExercise(exerciseId);
      if (exercise != null) {
        exercises.add(exercise);
      }
    }
    return exercises;
  }

  ImgurService imgurService = ImgurService();

  // Function to upload an image to Imgur and return the URL
  Future<String> uploadImage(XFile image) async {
    String? imgurUrl = await imgurService.saveImageToImgur(image);
    if (imgurUrl != null) {
      return imgurUrl;
    } else {
      return "";
    }
  }

//////////////////////////////////////////////////////////////////////////////
////////////////////////////  Duplication Checks /////////////////////////////
//////////////////////////////////////////////////////////////////////////////

  Future<String?> fireBaseIsAlreadyDuplicated(
      String oldWorkoutId, String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userWorkoutDuplicate')
        .where('oldWorkoutId', isEqualTo: oldWorkoutId)
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['newWorkoutId'] as String?;
    } else {
      return null;
    }
  }

  Future<void> fireBaseAddDuplicate(
      String oldWorkoutId, String userId, String newWorkoutId) async {
    await FirebaseFirestore.instance.collection('userWorkoutDuplicate').add({
      'oldWorkoutId': oldWorkoutId,
      'newWorkoutId': newWorkoutId,
      'userId': userId,
    });
  }

//////////////////////////////////////////////////////////////////////////////
////////////////////////////  Firebase Admin /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

  /// Gets the total count of workouts in Firebase.
  Future<int> getWorkoutsCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('workouts').get();
    return querySnapshot.docs.length;
  }

  /// Gets all workout IDs for an admin user from Firebase.
  Future<List<String>> getAllWorkouts(String? userId) async {
    if (userId != null && await _userDao.getAdminStatus(userId)) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('workouts').get();
      List<String> workoutIds =
          querySnapshot.docs.map((doc) => doc.id).toList();
      return workoutIds;
    } else {
      throw Exception('User is not an admin');
    }
  }
}
