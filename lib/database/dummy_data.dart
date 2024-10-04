import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_weight_data.dart';
import 'package:fitnessapp_idata2503/database/crud/user_weight_data_dao.dart';

// THIS IS PURELY AI GENERATED AND ONLY USED FOR TESTING PURPOSES
// DO NOT PUBLISH THIS CODE IN A RELEASE!

class DummyData {
  final UserDao userDao = UserDao();
  final UserWeightDataDao userWeightDataDao = UserWeightDataDao();
  final ExerciseDao exerciseDao = ExerciseDao();
  final WorkoutDao workoutDao = WorkoutDao();
  final WorkoutExercisesDao workoutExercisesDao = WorkoutExercisesDao();

  Future<void> insertDummyUsers() async {
    List<User> users = [
      User(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          weight: 70),
      User(
          name: 'Jane Smith',
          email: 'jane@example.com',
          password: 'password123',
          weight: 65),
      User(
          name: 'Alice Johnson',
          email: 'alice@example.com',
          password: 'password123',
          weight: 55),
    ];

    for (User user in users) {
      await userDao.create(user);
    }
  }

  Future<void> insertDummyUserWeights() async {
    List<UserWeightData> userWeights = [
      UserWeightData(id: 1, userId: 1, weight: 70, date: '2023-01-01'),
      UserWeightData(id: 2, userId: 1, weight: 71, date: '2023-02-01'),
      UserWeightData(id: 3, userId: 2, weight: 65, date: '2023-01-01'),
      UserWeightData(id: 4, userId: 2, weight: 66, date: '2023-02-01'),
      UserWeightData(id: 5, userId: 3, weight: 55, date: '2023-01-01'),
      UserWeightData(id: 6, userId: 3, weight: 56, date: '2023-02-01'),
    ];

    for (UserWeightData userWeight in userWeights) {
      await userWeightDataDao.create(userWeight);
    }
  }

  Future<void> insertDummyExercises() async {
    List<Exercise> exercises = [
      Exercise(
          name: 'Push Up',
          description: 'Upper body exercise',
          category: 'Strength',
          videoUrl: 'http://example.com/pushup',
          lastWeight: 0),
      Exercise(
          name: 'Squat',
          description: 'Lower body exercise',
          category: 'Strength',
          videoUrl: 'http://example.com/squat',
          lastWeight: 0),
      Exercise(
          name: 'Plank',
          description: 'Core exercise',
          category: 'Strength',
          videoUrl: 'http://example.com/plank',
          lastWeight: 0),
    ];

    for (Exercise exercise in exercises) {
      await exerciseDao.create(exercise);
    }
  }

  Future<void> insertDummyWorkouts() async {
    List<Workout> workouts = [
      Workout(
          name: 'Morning Routine',
          description: 'A quick morning workout',
          category: WorkoutCategory.general),
      Workout(
          name: 'Evening Routine',
          description: 'A quick evening workout',
          category: WorkoutCategory.general),
    ];

    for (Workout workout in workouts) {
      await workoutDao.create(workout);
    }
  }

  Future<void> insertDummyWorkoutExercises() async {
    List<WorkoutExercises> workoutExercises = [
      WorkoutExercises(workoutId: 1, exerciseId: 1),
      WorkoutExercises(workoutId: 1, exerciseId: 2),
      WorkoutExercises(workoutId: 2, exerciseId: 2),
      WorkoutExercises(workoutId: 2, exerciseId: 3),
    ];

    for (WorkoutExercises workoutExercise in workoutExercises) {
      await workoutExercisesDao.create(workoutExercise);
    }
  }

  Future<void> insertAllDummyData() async {
    await insertDummyUsers();
    await insertDummyUserWeights();
    await insertDummyExercises();
    await insertDummyWorkouts();
    await insertDummyWorkoutExercises();
  }
}
