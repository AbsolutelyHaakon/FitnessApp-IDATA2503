import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';

class GetDataFromServer {
  final ExerciseDao exerciseDao = ExerciseDao();

  Future<void> syncExercises(String? userId) async {
    if (userId == null) {
      print("User ID is null");
      return;
    }
    print("Syncing exercises for user: $userId");
    // Fetch all exercises from Firebase
    Map<String, dynamic> firebaseData = await exerciseDao.fetchAllExercisesFromFireBase(userId);
    List<Exercises> allExercises = firebaseData['exercises'];
    print("All exercises: $allExercises");
    print(allExercises[0].exerciseId);

    // Truncate the local database
    await exerciseDao.truncate();

    // Add all fetched exercises to the local database
    for (Exercises exercise in allExercises) {
      await exerciseDao.create(exercise);
    }
  }
}