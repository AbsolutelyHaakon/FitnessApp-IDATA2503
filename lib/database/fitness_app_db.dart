import 'package:sqflite/sqflite.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/user.dart';

class FitnessAppDB {
  final tableName = 'users';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "weight" INTEGER
    );""");
  }

  Future<int> create({
    required String name,
    required String email,
    required String password,
    required int weight,
  }) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      {
        'name': name,
        'email': email,
        'password': password,
        'weight': weight,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update({
    required int id,
    required String name,
    required String email,
    required String password,
    required int weight,
  }) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        'name': name,
        'email': email,
        'password': password,
        'weight': weight,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.query(
      tableName,
      orderBy: 'name',
    );
    return users.map((user) => User.fromSqfliteDatabase(user)).toList();
  }

  Future<User> fetchById(int id) async {
    final database = await DatabaseService().database;
    final user = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return User.fromSqfliteDatabase(user.first);
  }

  Future<int> updateWeight({required int id, required int weight}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        'weight': weight,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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