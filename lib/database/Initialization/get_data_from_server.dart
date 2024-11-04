import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';

class GetDataFromServer {
  final ExerciseDao exerciseDao = ExerciseDao();
  final WorkoutDao workoutsDao = WorkoutDao();

  Future<void> syncData(String? userId) async {
    await syncExercises(userId);
    await syncWorkouts(userId);
  }

  Future<void> syncExercises(String? userId) async {
    if (userId == null) {
      return;
    }
    // Fetch all exercises from Firebase
    Map<String, dynamic> firebaseData = await exerciseDao.fetchAllExercisesFromFireBase(userId);
    List<Exercises> allExercises = firebaseData['exercises'];
    // Truncate the local database
    await exerciseDao.truncate();

    // Add all fetched exercises to the local database
    for (Exercises exercise in allExercises) {
      await exerciseDao.create(exercise);
    }
  }

  Future<void> syncWorkouts(String? userId) async {
  if (userId == null) {
    return;
  }
  // Fetch all workouts from Firebase
  Map<String, dynamic> firebaseData = await workoutsDao.fetchAllWorkoutsFromFireBase(userId);
  List<Workouts> allWorkouts = firebaseData['workouts'];

  // Truncate the local database
  await workoutsDao.truncate();

  // Add all fetched exercises to the local database
  for (Workouts workout in allWorkouts) {
    await workoutsDao.create(workout);
  }
}
}