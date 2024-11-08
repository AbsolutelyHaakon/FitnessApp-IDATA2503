import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';

import '../crud/workout_exercises_dao.dart';
import '../tables/workout_exercises.dart';

class GetDataFromServer {
  final ExerciseDao exerciseDao = ExerciseDao();
  final WorkoutDao workoutsDao = WorkoutDao();
  final WorkoutExercisesDao workoutExercisesDao = WorkoutExercisesDao();

  Future<void> syncData(String? userId) async {
    await syncExercises(userId);
    await syncWorkouts(userId);
  }

  Future<void> syncExercises(String? userId) async {
    if (userId == null) {
      return;
    }
    // Fetch all exercises from Firebase
    Map<String, dynamic> firebaseData =
        await exerciseDao.fireBaseFetchAllExercisesFromFireBase(userId);
    List<Exercises> allExercises = firebaseData['exercises'];
    print(allExercises[0].name);
    print(allExercises[0].isPrivate);
    // Truncate the local database
    await exerciseDao.localTruncate();

    // Add all fetched exercises to the local database
    for (Exercises exercise in allExercises) {
      await exerciseDao.localCreate(exercise);
    }
  }

  Future<void> syncWorkouts(String? userId) async {
    if (userId == null) {
      return;
    }
    // Fetch all workouts from Firebase
    Map<String, dynamic> firebaseData =
        await workoutsDao.fireBaseFetchAllWorkouts(userId);
    List<Workouts> allWorkouts = firebaseData['workouts'];

    // Truncate the local database
    await workoutsDao.localTruncate();
    await workoutExercisesDao.localTruncate();

    // Add all fetched exercises to the local database
    for (Workouts workout in allWorkouts) {
      await workoutsDao.localCreate(workout);
      await syncWorkoutExercises(workout.workoutId);
    }


  }

  Future<void> syncWorkoutExercises(String? workoutId) async {
    if (workoutId == null) {
      return;
    }
    // Fetch all workout exercises from Firebase
    Map<String, dynamic> firebaseData =
        await workoutExercisesDao.fireBaseFetchAllWorkoutExercises(workoutId);
    List<WorkoutExercises> allWorkoutExercises = firebaseData['workoutExercises'];

    // Add all fetched exercises to the local database
    for (WorkoutExercises workoutExercise in allWorkoutExercises) {
      await workoutExercisesDao.localCreate(workoutExercise);
    }
  }

}
