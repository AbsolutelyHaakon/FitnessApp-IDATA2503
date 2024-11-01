import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';

class GetDataFromServer {
  final ExerciseDao exerciseDao = ExerciseDao();

  Future<void> syncExercises(String userId) async {
    // Fetch all exercises from Firebase
    Map<String, dynamic> firebaseData = await exerciseDao.fetchAllExercisesFromFireBase(userId);
    List<Exercises> allExercises = firebaseData['exercises'];

    // Truncate the local database
    await exerciseDao.truncate();

    // Add all fetched exercises to the local database
    for (Exercises exercise in allExercises) {
      await exerciseDao.create(exercise);
    }
  }
}