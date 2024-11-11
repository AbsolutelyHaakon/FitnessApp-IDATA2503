import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/exercise.dart';
import '../tables/workout.dart';

class WorkoutDao {
  final tableName = 'workouts';
  final WorkoutExercisesDao _workoutDao = WorkoutExercisesDao();

  Future<int> localCreate(Workouts workout) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

Future<void> localSetAllInactive() async {
  final database = await DatabaseService().database;

  await database.update(
    tableName,
    {'isActive': 0},
  );
}

  Future<void> localUpdateWorkoutExercises(String workoutId, List<Exercises> exercises) async {
    final database = await DatabaseService().database;
    await database.transaction((txn) async {
      await txn.delete('workoutExercises', where: 'workoutId = ?', whereArgs: [workoutId]);
      for (var exercise in exercises) {
        await txn.insert('workoutExercises', {
          'workoutId': workoutId,
          'exerciseId': exercise.exerciseId,
        });
      }
    });
}


  Future<List<Workouts>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName, orderBy: 'name');
    return data.map((entry) => Workouts.fromMap(entry)).toList();
  }

  // TODO CREATE A PUBLIC WORKOUT FETCH
  Future<List<Workouts>> localFetchAllById(String? id) async {
  final database = await DatabaseService().database;
  if (id != null && id.isNotEmpty){
    final data = await database.query(
      tableName,
      where: 'userId = ? OR (isPrivate = ? AND userId = ?)',
      whereArgs: [id, 0, ''],
    );
    return data.map((entry) => Workouts.fromMap(entry)).toList();
  } else {
    final data = await database.query(
      tableName,
      where: 'isPrivate = ? OR (isPrivate = ? AND userId = ?)',
      whereArgs: [0, 1, ''],
    );
    return data.map((entry) => Workouts.fromMap(entry)).toList();
  }


}

  Future<Workouts> localFetchByWorkoutId(String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    return Workouts.fromMap(data.first);
  }

  Future<void> localDelete(String id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Exercises>> localFetchExercisesForWorkout(String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.rawQuery('''
      SELECT exercises.* FROM exercises
      INNER JOIN workoutExercises ON exercises.exerciseId = workoutExercises.exerciseId
      WHERE workoutExercises.workoutId = ?
    ''', [workoutId]);
    return data.map((entry) => Exercises.fromSqfl(entry)).toList();
  }

  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  Future<bool> hasActiveWorkouts() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      'workouts',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.isNotEmpty;
  }

  Future<Workouts> fetchActiveWorkout() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await database.query(
      'workouts',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return Workouts.fromMap(maps.first);
  }


  Future<String> generateUniqueWorkoutId() async {
    final database = await DatabaseService().database;
    final existingIds = await database.query(tableName, columns: ['workoutId']);
    final existingIdSet = existingIds.map((e) => e['workoutId'] as String).toSet();

    String newId;
    do {
      newId = _generateRandomId();
    } while (existingIdSet.contains(newId));

    return newId;
  }

  String _generateRandomId() {
    const length = 10;
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }



  ////////////////////////////////////////////////////////////
  ////////////////// FIREBASE FUNCTIONS //////////////////////
  ////////////////////////////////////////////////////////////


  Future<void> fireBaseDeleteWorkout(String WorkoutId) async {
    await FirebaseFirestore.instance.collection('workouts').doc(WorkoutId).delete();
    localDelete(WorkoutId);
    _workoutDao.deleteAllWorkoutExercisesWithWorkoutId(WorkoutId);
  }

  Future<Map<String, dynamic>> fireBaseFetchAllWorkouts(String userId) async {

    // Get all workouts for the user (public and private)
    QuerySnapshot personalWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId).get();

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


 Future<String?> fireBaseCreateWorkout(String? category, String? description, int? duration, int? intensity,
     bool isPrivate, String? userId, String? video_url, String name, bool wantId, int? calories, int? sets) async {

    if (userId != null && userId.isNotEmpty) {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('workouts').add({
        'category': category ?? '',
        'description': description ?? '',
        'duration': duration ?? 0,
        'calories': calories ?? 0,
        'sets': sets ?? 0,
        'intensity': intensity ?? 0,
        'isPrivate': isPrivate,
        'userId': userId ?? '',
        'video_url': video_url ?? '',
        'name': name,
      });

      String newDocId = docRef.id;

      localCreate(Workouts(
        workoutId: newDocId,
        category: category,
        description: description,
        duration: duration,
        calories: calories,
        sets: sets,
        intensity: intensity,
        isPrivate: isPrivate,
        userId: userId ?? '',
        videoUrl: video_url,
        name: name,
      ));
      return wantId ? newDocId : null;
    } else {
      String newDocId = await _generateRandomId();

      localCreate(Workouts(
        workoutId: newDocId,
        category: category,
        description: description,
        duration: duration,
        calories: calories,
        sets: sets,
        intensity: intensity,
        isPrivate: isPrivate,
        userId: userId ?? '',
        videoUrl: video_url,
        name: name,
      ));

      return wantId ? newDocId : null;
    }
}



}