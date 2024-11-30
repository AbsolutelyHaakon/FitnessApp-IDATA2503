import 'database_service.dart';

/// This class is used to insert dummy data into the database for testing purposes.
/// It contains methods to insert dummy user workouts.
class DummyData {
  /// This method inserts a dummy user workout into the database.
  /// It creates a new entry in the 'userWorkouts' table with predefined values.
  Future<void> insertDummyUserWorkouts() async {
    final database = await DatabaseService().database; // Get the database instance
    await database.insert('userWorkouts', {
      'userWorkoutId': 'uw4', // Unique ID for the user workout
      'userId': 'aH0XtrtqgEcYPvnmSslZSfFNUp43', // ID of the user
      'workoutId': 'PJtppVkaHh0SJo9t8Puw', // ID of the workout
      'date': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 23, 59, 59).toIso8601String() // Date of the workout
    });
  }
}