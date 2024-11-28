import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/favorite_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/favorite_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';

import '../crud/workout_exercises_dao.dart';
import '../tables/workout_exercises.dart';

class GetDataFromServer {
  final ExerciseDao exerciseDao = ExerciseDao();
  final WorkoutDao workoutsDao = WorkoutDao();
  final WorkoutExercisesDao workoutExercisesDao = WorkoutExercisesDao();
  final FavoriteWorkoutsDao favoriteWorkoutsDao = FavoriteWorkoutsDao();
  final UserWorkoutsDao userWorkoutsDao = UserWorkoutsDao();

  Future<void> syncData(String? userId) async {
    await syncExercises(userId);
    await syncWorkouts(userId);
    await syncFavoriteWorkouts(userId);
  }

  Future<void> syncExercises(String? userId) async {
    if (userId == null) {
      return;
    }
    // Fetch all exercises from Firebase
    Map<String, dynamic> firebaseData =
        await exerciseDao.fireBaseFetchAllExercisesFromFireBase(userId);
    List<Exercises> allExercises = firebaseData['exercises'];
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

  Future<void> syncFavoriteWorkouts(String? userId) async {
    // Fetch all favorite workouts from Firebase
    Map<String, dynamic> firebaseData =
        await favoriteWorkoutsDao.fireBaseFetchAllFavoriteWorkouts(userId ?? '');
    List<FavoriteWorkouts> allFavoriteWorkouts = firebaseData['favoriteWorkouts'];

    // Truncate the local database
    await favoriteWorkoutsDao.localTruncate();

    // Add all fetched favorite workouts to the local database
    for (FavoriteWorkouts favoriteWorkout in allFavoriteWorkouts) {
      await favoriteWorkoutsDao.localCreate(favoriteWorkout);
    }
  }

  Future<void> SyncUserWorkouts(String? userId) async {
    if (userId == null) {
      return;
    }
    // First delete all the local data
    await userWorkoutsDao.localTruncate();

    // Fetch all user workouts from Firebase
    final prevWork = await userWorkoutsDao.fireBaseFetchPreviousWorkouts(userId);
    final upcomingWork = await userWorkoutsDao.fireBaseFetchUpcomingWorkouts(userId);

    List<UserWorkouts> allUserWorkouts = prevWork["previousWorkouts"];
    allUserWorkouts.addAll(upcomingWork["upcomingWorkouts"]);

    // Add all fetched user workouts to the local database
    for (UserWorkouts userWorkouts in allUserWorkouts) {
      await userWorkoutsDao.localCreate(userWorkouts);
    }
    }
  }
