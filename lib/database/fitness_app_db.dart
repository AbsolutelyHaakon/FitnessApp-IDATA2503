import 'package:sqflite/sqflite.dart';

class FitnessAppDB {
  Future<void> createDB(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS users (
      id STRING PRIMARY KEY,
      name STRING NOT NULL,
      email STRING NOT NULL,
      weight DOUBLE,
      targetWeight DOUBLE,
      height DOUBLE,
      imageURL STRING
    );''');
    // TODO: Connect the lastWeight to the log history of the users last time on that specific exercise (FRONTEND)
    await database.execute('''CREATE TABLE IF NOT EXISTS userHealthData (
      userHealthDataId STRING PRIMARY KEY,
      userId STRING,
      weight INTEGER,
      height INTEGER,
      date DATE NOT NULL,
      calories INTEGER,
      waterIntake INTEGER,
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');
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
      userId INTEGER,
      isActive BOOLEAN NOT NULL DEFAULT FALSE
    );''');
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
    await database.execute('''CREATE TABLE IF NOT EXISTS userWorkouts (
      userWorkoutId STRING PRIMARY KEY,
      userId STRING,
      workoutId STRING,
      date DATE NOT NULL,
      duration DOUBLE,
      statistics STRING,
      FOREIGN KEY (userId) REFERENCES users (id),
      FOREIGN KEY (workoutId) REFERENCES workouts (id)
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS posts (
      postId STRING PRIMARY KEY,
      userId STRING NOT NULL,
      content STRING,
      imageURL STRING,
      date DATE NOT NULL,
      workoutId STRING,
      location STRING,
      FOREIGN KEY (workoutId) REFERENCES workouts (id),
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS comments (
      commentId STRING PRIMARY KEY,
      postId STRING,
      userId STRING,
      content STRING NOT NULL,
      date DATE NOT NULL,
      FOREIGN KEY (postId) REFERENCES posts (postId),
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS userFollows(
    userFollowsId STRING PRIMARY KEY,
    userId STRING NOT NULL,
    followsId STRING NOT NULL,
    FOREIGN KEY (userId) REFERENCES users (id),
    FOREIGN KEY (followsId) REFERENCES users (id)
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS favoriteWorkouts(
    favoriteWorkoutId STRING PRIMARY KEY,
    userId STRING NOT NULL,
    workoutId STRING NOT NULL,
    FOREIGN KEY (userId) REFERENCES users (id),
    FOREIGN KEY (workoutId) REFERENCES workouts (id)
    );''');
  }


}