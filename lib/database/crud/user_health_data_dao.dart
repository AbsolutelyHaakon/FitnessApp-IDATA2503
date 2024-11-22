import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/user_health_data.dart';
import 'package:sqflite/sqflite.dart';

class UserHealthDataDao {
  final tableName = 'userHealthData';

  Future<int> localCreate(UserHealthData userHealthData) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      userHealthData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<List<UserHealthData>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => UserHealthData.fromMap(entry)).toList();
  }

  Future<UserHealthData> localFetchById(int userId, DateTime date) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );
    return UserHealthData.fromMap(data.first);
  }

  Future<void> localDelete(int userId, DateTime date) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );
  }

  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

////////////////////////////////////////////////////////////
////////////////// FIREBASE FUNCTIONS //////////////////////
////////////////////////////////////////////////////////////

  Future<void> fireBaseCreateUserHealthData(String userId, int? height,
      int? weight, DateTime date, int? calories, int? waterIntake) async {
    // See if there already exists a document with the same userId and date
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userHealthData')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .get();
    // If it does not exist, create a new document
    if (querySnapshot.docs.isEmpty) {
      // Get data from the previous entry
      QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection('userHealthData')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot2.docs.isNotEmpty) {
        final previousData =
            querySnapshot2.docs.first.data() as Map<String, dynamic>;
        final previousWeight = previousData['weight'];
        final previousHeight = previousData['height'];
        final previousCalories = previousData['calories'];
        final previousWaterIntake = previousData['waterIntake'];
        // If the user did not enter a value, use the previous value
        weight ??= previousWeight;
        height ??= previousHeight;
        calories ??= previousCalories;
        waterIntake ??= previousWaterIntake;
      }

      await FirebaseFirestore.instance.collection('userHealthData').add({
        'userId': userId,
        'date': date,
        'weight': weight ?? 0,
        'height': height ?? 0,
        'calories': calories ?? 0,
        'waterIntake': waterIntake ?? 0,
      });
    } else {
      // If it does exist, update the existing document
      final docId = querySnapshot.docs.first.id;
      final existingData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      final updatedCalories = (existingData['calories'] ?? 0) + (calories ?? 0);
      final updatedWaterIntake =
          (existingData['waterIntake'] ?? 0) + (waterIntake ?? 0);

      await FirebaseFirestore.instance
          .collection('userHealthData')
          .doc(docId)
          .update({
        'weight': weight,
        'height': height,
        'calories': updatedCalories,
        'waterIntake': updatedWaterIntake,
      });
    }
  }

  Future<Map<String, dynamic>> fireBaseFetchUserHealthData(String userId) async {
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
