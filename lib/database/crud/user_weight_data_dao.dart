import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/user_weight_data.dart';

class UserWeightDataDao {
  final tableName = 'userWeightData';

  Future<int> create(UserWeightData data) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(UserWeightData data) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserWeightData>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName, orderBy: 'date');
    return data.map((entry) => UserWeightData.fromMap(entry)).toList();
  }

  Future<UserWeightData> fetchById(int id) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return UserWeightData.fromMap(data.first);
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}