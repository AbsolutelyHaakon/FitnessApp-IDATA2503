import 'database_service.dart';

class DummyData {
  Future<void> insertDummyUserWorkouts() async {
    final database = await DatabaseService().database;
    await database.insert('userWorkouts', {
      'userWorkoutId': 'uw4',
      'userId': 'aH0XtrtqgEcYPvnmSslZSfFNUp43',
      'workoutId': 'PJtppVkaHh0SJo9t8Puw',
      'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 23, 59, 59).toIso8601String()
    });
  }
}