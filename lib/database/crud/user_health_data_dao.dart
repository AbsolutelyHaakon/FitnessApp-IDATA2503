import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_health_data.dart';
import 'package:sqflite/sqflite.dart';

// DAO for handling user health data
class UserHealthDataDao {
  final tableName = 'userHealthData';

  // Insert a new health data entry into the local database
  Future<int> localCreate(UserHealthData userHealthData) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userHealthData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing health data entry in the local database
  Future<int> localUpdate(UserHealthData userHealthData) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      userHealthData.toMap(),
      where: 'userId = ? AND date = ?',
      whereArgs: [userHealthData.userId, userHealthData.date.toIso8601String()],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all health data entries from the local database
  Future<List<UserHealthData>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserHealthData.fromMap(entry)).toList();
  }

  // Fetch a specific health data entry by userId and date from the local database
  Future<UserHealthData> localFetchById(int userId, DateTime date) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );
    return UserHealthData.fromMap(data.first);
  }

  // Delete a health data entry from the local database
  Future<void> localDelete(int userId, DateTime date) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );
  }

  // Delete all health data entries from the local database
  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  // Calculate today's water intake percentage based on the goal
  Future<double> getTodayWaterIntakePercentage(String userId, double goal) async {
    var userDataMap = await fireBaseFetchUserHealthData(userId);
    List<UserHealthData> userData = userDataMap['userHealthData'];

    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    int todayIntake = 0;

    // Loop through user data to find today's water intake
    for (var entry in userData) {
      DateTime date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (date == todayDate && entry.waterIntake != null) {
        todayIntake = entry.waterIntake! > todayIntake ? entry.waterIntake! : todayIntake;
      }
    }

    return todayIntake / goal;
  }

  ////////////////////////////////////////////////////////////
  ////////////////// FIREBASE FUNCTIONS //////////////////////
  ////////////////////////////////////////////////////////////

  // Create a new health data entry in Firebase
  Future<void> fireBaseCreateUserHealthData(String userId, int? height,
      int? weight, DateTime date, int? caloriesIntake, int? caloriesBurned, int? waterIntake) async {
      await FirebaseFirestore.instance.collection('userHealthData').add({
        'userId': userId,
        'date': date,
        'weight': weight ?? 0,
        'height': height ?? 0,
        'caloriesIntake': caloriesIntake ?? 0,
        'caloriesBurned': caloriesBurned ?? 0,
        'waterIntake': waterIntake ?? 0,
      });
  }

  // Fetch all health data entries for a user from Firebase
  Future<Map<String, dynamic>> fireBaseFetchUserHealthData(
      String userId) async {

    QuerySnapshot userHealthDataQuery = await FirebaseFirestore.instance
        .collection('userHealthData')
        .where('userId', isEqualTo: userId)
        .get();

    List<UserHealthData> userHealthData = userHealthDataQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['userHealthDataId'] = doc.id;
      return UserHealthData.fromMap(data);
    }).toList();

    return {'userHealthData': userHealthData};
  }
}