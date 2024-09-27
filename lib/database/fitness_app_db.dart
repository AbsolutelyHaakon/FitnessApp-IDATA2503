import 'package:sqflite/sqflite.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/user.dart';

class FitnessAppDB {
  final tableName = 'users';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "weight" INTEGER,
    PRIMARY KEY("id" AUTOINCREMENT)
    );""");
  }

  Future<int> create({
    required String name,
    required String email,
    required String password,
    required int weight,
  }) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (name, email, password, weight) VALUES (?, ?, ?, ?)''',
      [name, email, password, weight],
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
    return await database.rawUpdate(
      '''UPDATE $tableName SET name = ?, email = ?, password = ?, weight = ? WHERE id = ?''',
      [name, email, password, weight, id],
    );
  }

  Future<List<User>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.rawQuery(
        '''SELECT * from $tableName ORDER BY COALESCE(name)''');
    return users.map((user) => User.fromSqfliteDatabase(user)).toList();
  }

  Future<User> fetchById(int id) async {
    final database = await DatabaseService().database;
    final user = await database.rawQuery(
        '''SELECT * from $tableName WHERE id = ?''', [id]);
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
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ?''', [id]);
  }
}