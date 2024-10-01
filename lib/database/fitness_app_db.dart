import 'package:sqflite/sqflite.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/user.dart';

class FitnessAppDB {
  final tableName = 'users';

  Future<void> createDB(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      weight INTEGER
    );''');
    await database.execute('''CREATE TABLE IF NOT EXISTS userWeightData (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      weight INTEGER,
      date TEXT,
      FOREIGN KEY (userId) REFERENCES users (id)
    );''');
  }

  Future<List<User>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.query(tableName, orderBy: 'name');
    return users.map((user) => User.fromMap(user)).toList();
  }
}