import 'package:sqflite/sqflite.dart';

/// This class is responsible for creating the database schema for the fitness app.
/// It contains methods to create tables for users, exercises, workouts, and other related data.
class FitnessAppDB {
  /// This method creates the database schema by executing SQL commands to create tables.
  /// It ensures that the necessary tables are created if they do not already exist.
  Future<void> createDB(Database database) async {
    // Create the users table
    await database.execute('''CREATE TABLE IF NOT EXISTS users (
      id STRING PRIMARY KEY, // Unique identifier for the user
      name STRING NOT NULL, // Name of the user
      email STRING NOT NULL, // Email of the user
      weight INTEGER, // Current weight of the user
      weightTarget INTEGER, // Target weight of the user
      weightInitial INTEGER, // Initial weight of the user
      waterTarget INTEGER, // Daily water intake target for the user
      caloriesIntakeTarget INTEGER, // Daily calories intake target for the user
      caloriesBurnedTarget INTEGER, // Daily calories burned target for the user
      height DOUBLE, // Height of the user
      imageURL STRING, // URL of the user's profile image
      bannerURL STRING // URL of the user's banner image
    );''');

    // Create the userHealthData table
    await database.execute('''CREATE TABLE IF NOT EXISTS userHealthData (
      userHealthDataId STRING PRIMARY KEY, // Unique identifier for the user health data
      userId STRING, // ID of the user
      weight INTEGER, // Weight of the user at the time of data entry
      height INTEGER, // Height of the user at the time of data entry
      date DATE NOT NULL, // Date of the data entry
      caloriesIntake INTEGER, // Calories intake of the user
      caloriesBurned INTEGER, // Calories burned by the user
      waterIntake INTEGER, // Water intake of the user
      FOREIGN KEY (userId) REFERENCES users (id) // Foreign key to the users table
    );''');

    // Create the exercises table
    await database.execute('''CREATE TABLE IF NOT EXISTS exercises (
      exerciseId STRING PRIMARY KEY, // Unique identifier for the exercise
      name STRING NOT NULL, // Name of the exercise
      description STRING, // Description of the exercise
      category STRING, // Category of the exercise
      videoURL STRING, // URL of the exercise video
      imageURL STRING, // URL of the exercise image
      isPrivate BOOLEAN NOT NULL DEFAULT FALSE, // Whether the exercise is private
      userId STRING, // ID of the user who created the exercise
      FOREIGN KEY (userId) REFERENCES users (id) // Foreign key to the users table
    );''');

    // Create the workouts table
    await database.execute('''CREATE TABLE IF NOT EXISTS workouts (
      workoutId STRING PRIMARY KEY, // Unique identifier for the workout
      name STRING NOT NULL, // Name of the workout
      description STRING, // Description of the workout
      category STRING, // Category of the workout
      duration INTEGER, // Duration of the workout
      intensity INTEGER, // Intensity level of the workout
      calories INTEGER, // Calories burned during the workout
      sets INTEGER, // Number of sets in the workout
      videoURL STRING, // URL of the workout video
      isPrivate BOOLEAN NOT NULL DEFAULT FALSE, // Whether the workout is private
      userId INTEGER, // ID of the user who created the workout
      isDeleted BOOLEAN NOT NULL DEFAULT FALSE, // Whether the workout is deleted
      isActive BOOLEAN NOT NULL DEFAULT FALSE // Whether the workout is active
    );''');

    // Create the workoutExercises table
    await database.execute('''CREATE TABLE IF NOT EXISTS workoutExercises (
      workoutExercisesId STRING PRIMARY KEY, // Unique identifier for the workout exercise
      workoutId STRING, // ID of the workout
      exerciseId STRING, // ID of the exercise
      reps INTEGER, // Number of repetitions for the exercise
      sets INTEGER, // Number of sets for the exercise
      exerciseOrder INTEGER, // Order of the exercise in the workout
      FOREIGN KEY (workoutId) REFERENCES workouts (id), // Foreign key to the workouts table
      FOREIGN KEY (exerciseId) REFERENCES exercises (id) // Foreign key to the exercises table
    );''');

    // Create the userWorkouts table
    await database.execute('''CREATE TABLE IF NOT EXISTS userWorkouts (
      userWorkoutId STRING PRIMARY KEY, // Unique identifier for the user workout
      userId STRING, // ID of the user
      workoutId STRING, // ID of the workout
      date DATE NOT NULL, // Date of the workout
      duration DOUBLE, // Duration of the workout
      statistics STRING, // Statistics of the workout
      isActive BOOLEAN NOT NULL DEFAULT FALSE, // Whether the workout is active
      FOREIGN KEY (userId) REFERENCES users (id), // Foreign key to the users table
      FOREIGN KEY (workoutId) REFERENCES workouts (id) // Foreign key to the workouts table
    );''');

    // Create the posts table
    await database.execute('''CREATE TABLE IF NOT EXISTS posts (
      postId STRING PRIMARY KEY, // Unique identifier for the post
      userId STRING NOT NULL, // ID of the user who created the post
      content STRING, // Content of the post
      imageURL STRING, // URL of the post image
      date DATE NOT NULL, // Date of the post
      workoutId STRING, // ID of the workout associated with the post
      location STRING, // Location of the post
      FOREIGN KEY (workoutId) REFERENCES workouts (id), // Foreign key to the workouts table
      FOREIGN KEY (userId) REFERENCES users (id) // Foreign key to the users table
    );''');

    // Create the comments table
    await database.execute('''CREATE TABLE IF NOT EXISTS comments (
      commentId STRING PRIMARY KEY, // Unique identifier for the comment
      postId STRING, // ID of the post
      userId STRING, // ID of the user who made the comment
      content STRING NOT NULL, // Content of the comment
      date DATE NOT NULL, // Date of the comment
      FOREIGN KEY (postId) REFERENCES posts (postId), // Foreign key to the posts table
      FOREIGN KEY (userId) REFERENCES users (id) // Foreign key to the users table
    );''');

    // Create the userFollows table
    await database.execute('''CREATE TABLE IF NOT EXISTS userFollows(
      userFollowsId STRING PRIMARY KEY, // Unique identifier for the user follow
      userId STRING NOT NULL, // ID of the user
      followsId STRING NOT NULL, // ID of the user being followed
      FOREIGN KEY (userId) REFERENCES users (id), // Foreign key to the users table
      FOREIGN KEY (followsId) REFERENCES users (id) // Foreign key to the users table
    );''');

    // Create the favoriteWorkouts table
    await database.execute('''CREATE TABLE IF NOT EXISTS favoriteWorkouts(
      favoriteWorkoutId STRING PRIMARY KEY, // Unique identifier for the favorite workout
      userId STRING NOT NULL, // ID of the user
      workoutId STRING NOT NULL, // ID of the workout
      FOREIGN KEY (userId) REFERENCES users (id), // Foreign key to the users table
      FOREIGN KEY (workoutId) REFERENCES workouts (id) // Foreign key to the workouts table
    );''');
  }
}