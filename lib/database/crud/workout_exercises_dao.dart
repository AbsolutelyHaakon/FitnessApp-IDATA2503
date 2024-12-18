import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/workout_exercises.dart';

/// This class handles CRUD operations for workout exercises both locally and on Firebase.
class WorkoutExercisesDao {
  final tableName = 'workoutExercises';

  /// Inserts a new workout exercise into the local database.
  Future<int> localCreate(WorkoutExercises workoutExercises) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workoutExercises.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing workout exercise in the local database.
  Future<int> localUpdate(WorkoutExercises workoutExercises) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      workoutExercises.toMap(),
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutExercises.workoutId, workoutExercises.exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetches all workout exercises from the local database.
  Future<List<WorkoutExercises>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => WorkoutExercises.fromMap(entry)).toList();
  }

  /// Fetches all workout exercises for a specific workout ID from the local database.
  Future<List<WorkoutExercises>> localFetchByWorkoutId(String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    return data.map((entry) => WorkoutExercises.fromMap(entry)).toList();
  }

  /// Fetches a specific workout exercise by workout ID and exercise ID from the local database.
  Future<WorkoutExercises> localFetchById(
      String workoutId, String exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
    return WorkoutExercises.fromMap(data.first);
  }

  /// Deletes a specific workout exercise from the local database.
  Future<void> localDelete(String workoutId, String exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
  }

  /// Deletes all workout exercises from the local database.
  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  ////////////////////////////////////////////////////////////
  /////////////////// FIREBASE FUNCTIONS /////////////////////
  ////////////////////////////////////////////////////////////

  /// Deletes all workout exercises not in the provided list from Firebase and locally.
  Future<void> deleteAllWorkoutExercisesNotInList(List<Exercises> exercises, String workoutId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workoutExercises')
        .where('workoutId', isEqualTo: workoutId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (!exercises.any((exercise) => exercise.exerciseId == data['exerciseId'])) {
        await doc.reference.delete();
        await localDelete(data['workoutId'], data['exerciseId']);
      }
    }
  }

  /// Deletes all workout exercises with a specific workout ID from Firebase and locally.
  Future<void> deleteAllWorkoutExercisesWithWorkoutId(String workoutId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workoutExercises')
        .where('workoutId', isEqualTo: workoutId)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    List<WorkoutExercises> deleteList = await localFetchByWorkoutId(workoutId);
    for (WorkoutExercises workoutExercises in deleteList) {
      localDelete(workoutExercises.workoutId, workoutExercises.exerciseId);
    }
  }

  /// Fetches all workout exercises for a specific workout ID from Firebase.
  Future<Map<String, dynamic>> fireBaseFetchAllWorkoutExercises(
      String workoutId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workoutExercises')
        .where('workoutId', isEqualTo: workoutId)
        .get();

    List<WorkoutExercises> allWorkoutExercises = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return WorkoutExercises(
        workoutExercisesId: doc.id,
        workoutId: data['workoutId'],
        exerciseId: data['exerciseId'],
        reps: data['reps'],
        sets: data['sets'],
        exerciseOrder: data['exerciseOrder'],
      );
    }).toList();

    return {
      'workoutExercises': allWorkoutExercises,
    };
  }

  /// Creates a new workout exercise in Firebase and updates it locally.
  Future<void> fireBaseCreateWorkoutExercise(String workoutId, String exerciseId,
      int reps, int sets, int exerciseOrder) async {
    // Check if the workoutExercise already exists
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workoutExercises')
        .where('workoutId', isEqualTo: workoutId)
        .where('exerciseId', isEqualTo: exerciseId)
        .get();

    // If the workoutExercise already exists, return
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update({
        'exerciseOrder': exerciseOrder,
      });

      localUpdate(WorkoutExercises(
        workoutExercisesId: doc.id,
        workoutId: workoutId,
        exerciseId: exerciseId,
        reps: reps,
        sets: sets,
        exerciseOrder: exerciseOrder,
      ));
    } else {
      DocumentReference docRef =
      await FirebaseFirestore.instance.collection('workoutExercises').add({
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'reps': reps,
        'sets': sets,
        'exerciseOrder': exerciseOrder,
      });

      String newDocId = docRef.id;

      localCreate(WorkoutExercises(
        workoutExercisesId: newDocId,
        workoutId: workoutId,
        exerciseId: exerciseId,
        reps: reps,
        sets: sets,
        exerciseOrder: exerciseOrder,
      ));
    }
  }

  /// Fetches a specific workout exercise by workout ID and exercise ID from Firebase.
  Future<WorkoutExercises?> fireBaseFetchById(String workoutId, String exerciseId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workoutExercises')
        .where('workoutId', isEqualTo: workoutId)
        .where('exerciseId', isEqualTo: exerciseId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    DocumentSnapshot doc = querySnapshot.docs.first;
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WorkoutExercises(
      workoutExercisesId: doc.id,
      workoutId: data['workoutId'],
      exerciseId: data['exerciseId'],
      reps: data['reps'],
      sets: data['sets'],
      exerciseOrder: data['exerciseOrder'],
    );
  }

  /// Deletes all inactive workout exercises from Firebase.
  Future<Map<String, dynamic>> fireBaseDeleteInactiveWorkoutExercises(
      List<String> activeWorkoutIds) async {
    if (activeWorkoutIds.isEmpty) {
      return {'success': false, 'message': 'No active workouts'};
    }
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('workoutExercises').get();
    List<String> deletedIds = [];

    if (querySnapshot.docs.isEmpty) {
      return {'success': false, 'message': 'No WorkoutExercises to delete'};
    }

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (!activeWorkoutIds.contains(data['workoutId'])) {
        await doc.reference.delete();
        deletedIds.add(doc.id);
      }
    }

    if (deletedIds.isEmpty) {
      return {
        'success': false,
        'message': 'No inactive workoutExercises to delete'
      };
    }

    return {
      'success': true,
      'message': '${deletedIds.length} items deleted',
      'deletedIds': deletedIds
    };
  }
}