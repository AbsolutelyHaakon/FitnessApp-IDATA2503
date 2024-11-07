import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/workout_exercises.dart';

class WorkoutExercisesDao {
  final tableName = 'workoutExercises';

  Future<int> localCreate(WorkoutExercises workoutExercises) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workoutExercises.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<List<WorkoutExercises>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => WorkoutExercises.fromMap(entry)).toList();
  }

  Future<List<WorkoutExercises>> localFetchByWorkoutId(int workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ?',
      whereArgs: [workoutId],
    );
    return data.map((entry) => WorkoutExercises.fromMap(entry)).toList();
  }

  Future<WorkoutExercises> localFetchById(int workoutId, int exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
    return WorkoutExercises.fromMap(data.first);
  }

  Future<void> localDelete(int workoutId, int exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'workoutId = ? AND exerciseId = ?',
      whereArgs: [workoutId, exerciseId],
    );
  }

  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);

  }


  ////////////////////////////////////////////////////////////
  /////////////////// FIREBASE FUNCTIONS /////////////////////
  ////////////////////////////////////////////////////////////


  Future<Map<String, dynamic>> fireBaseFetchAllWorkoutExercises(String workoutId) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('workoutExercises')
      .where('workoutId', isEqualTo: workoutId).get();

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

  void fireBaseCreateWorkoutExercise(String workoutId, String exerciseId, int reps, int sets, int exerciseOrder) async {
    DocumentReference docRef = await FirebaseFirestore.instance.collection('workoutExercises').add({
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