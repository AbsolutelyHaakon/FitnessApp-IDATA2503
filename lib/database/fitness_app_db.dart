import 'package:sqflite/sqflite.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user.dart';

class FitnessAppDB {
  Future<void> createDB(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      weight INTEGER
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS userWeightData (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      weight INTEGER,
      date TEXT,
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');
    // TODO: Connect the lastWeight to the log history of the users last time on that specific exercise
    await database.execute('''CREATE TABLE IF NOT EXISTS exercise (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      videoUrl TEXT,
      lastWeight INTEGER
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS workouts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category INTEGER
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS workoutExercises (
      workoutId INTEGER,
      exerciseId INTEGER,
      FOREIGN KEY (workoutId) REFERENCES workouts (id),
      FOREIGN KEY (exerciseId) REFERENCES exercise (id),
      PRIMARY KEY (workoutId, exerciseId)
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS workoutDates (
      userId INTEGER,
      workoutId INTEGER,
      date TEXT,
      FOREIGN KEY (userId) REFERENCES users (id),
      FOREIGN KEY (workoutId) REFERENCES workouts (id),
      PRIMARY KEY (workoutId, date)
    );''');
  }


}