import 'dart:convert';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';

class DatabaseToJson {
  final ExerciseDao exerciseDao = ExerciseDao();
  final UserDao userDao = UserDao();

  Future<String> convertDatabaseToJson() async {
    final exercises = await exerciseDao.fetchAllAsMap();
    final users = await userDao.fetchAllAsMap();

    final databaseMap = {
      'exercises': exercises,
      'users': users,
    };

    return jsonEncode(databaseMap);
  }
}