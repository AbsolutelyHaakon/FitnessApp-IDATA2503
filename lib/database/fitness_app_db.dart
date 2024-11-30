import 'package:sqflite/sqflite.dart';

class FitnessAppDB {
  /// This method creates the database schema by executing SQL commands to create tables.
  /// It ensures that the necessary tables are created if they do not already exist.
  Future<void> createDB(Database database) async {
    // Create the users table
    await database.execute('''CREATE TABLE IF NOT EXISTS users (
      id STRING PRIMARY KEY,
      name STRING NOT NULL,
      email STRING NOT NULL,
      weight INTEGER,
      weightTarget INTEGER,
      weightInitial INTEGER,
      waterTarget INTEGER,
      caloriesIntakeTarget INTEGER,
      caloriesBurnedTarget INTEGER,
      height DOUBLE,
      imageURL STRING,
      bannerURL STRING
    );''');

    // Create the userHealthData table
    await database.execute('''CREATE TABLE IF NOT EXISTS userHealthData (
      userHealthDataId STRING PRIMARY KEY,
      userId STRING,
      weight INTEGER,
      height INTEGER,
      date DATE NOT NULL,
      caloriesIntake INTEGER,
      caloriesBurned INTEGER,
      waterIntake INTEGER,
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');

    // Create the exercises table
    await database.execute('''CREATE TABLE IF NOT EXISTS exercises (
      exerciseId STRING PRIMARY KEY,
      name STRING NOT NULL,
      description STRING,
      category STRING,
      videoURL STRING,
      imageURL STRING,
      isPrivate BOOLEAN NOT NULL DEFAULT FALSE,
      userId STRING,
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');

    // Create the workouts table
    await database.execute('''CREATE TABLE IF NOT EXISTS workouts (
      workoutId STRING PRIMARY KEY,
      name STRING NOT NULL,
      description STRING,
      category STRING,
      duration INTEGER,
      intensity INTEGER,
      calories INTEGER,
      sets INTEGER,
      videoURL STRING,
      isPrivate BOOLEAN NOT NULL DEFAULT FALSE,
      userId STRING,
      isDeleted BOOLEAN NOT NULL DEFAULT FALSE,
      isActive BOOLEAN NOT NULL DEFAULT FALSE
    );''');

    // Create the workoutExercises table
    await database.execute('''CREATE TABLE IF NOT EXISTS workoutExercises (
      workoutExercisesId STRING PRIMARY KEY,
      workoutId STRING,
      exerciseId STRING,
      reps INTEGER,
      sets INTEGER,
      exerciseOrder INTEGER,
      FOREIGN KEY (workoutId) REFERENCES workouts (id),
      FOREIGN KEY (exerciseId) REFERENCES exercises (id)
    );''');

    // Create the userWorkouts table
    await database.execute('''CREATE TABLE IF NOT EXISTS userWorkouts (
      userWorkoutId STRING PRIMARY KEY,
      userId STRING NOT NULL,
      workoutId STRING NOT NULL,
      date DATE NOT NULL,
      duration DOUBLE,
      statistics STRING,
      isActive BOOLEAN NOT NULL DEFAULT FALSE,
      FOREIGN KEY (userId) REFERENCES users (id),
      FOREIGN KEY (workoutId) REFERENCES workouts (id)
    );''');

    // Create the posts table
    await database.execute('''CREATE TABLE IF NOT EXISTS posts (
      postId STRING PRIMARY KEY,
      userId STRING NOT NULL,
      content STRING,
      imageURL STRING,
      date DATE NOT NULL,
      userWorkoutsId STRING,
      location STRING,
      FOREIGN KEY (workoutId) REFERENCES workouts (id),
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');

    // Create the userFollows table
    await database.execute('''CREATE TABLE IF NOT EXISTS userFollows(
    userFollowsId STRING PRIMARY KEY,
    userId STRING NOT NULL,
    followsId STRING NOT NULL,
    FOREIGN KEY (userId) REFERENCES users (id),
    FOREIGN KEY (followsId) REFERENCES users (id)
    );''');

    // Create the favoriteWorkouts table
    await database.execute('''CREATE TABLE IF NOT EXISTS favoriteWorkouts(
    favoriteWorkoutId STRING PRIMARY KEY,
    userId STRING NOT NULL,
    workoutId STRING NOT NULL,
    FOREIGN KEY (userId) REFERENCES users (id),
    FOREIGN KEY (workoutId) REFERENCES workouts (id)
    );''');
  }


}