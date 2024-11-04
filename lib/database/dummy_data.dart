import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class DummyData {
  Future<void> insertDummyUserWorkouts() async {
    final database = await DatabaseService().database;
    await database.insert('userWorkouts', {
      'userWorkoutId': 'uw3',
      'userId': 'aH0XtrtqgEcYPvnmSslZSfFNUp43',
      'workoutId': '7dd1Ec2KagwFjwOC6awC',
      'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1, 23, 59, 59).millisecondsSinceEpoch
    });
  }
}