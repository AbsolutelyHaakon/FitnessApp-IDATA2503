import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'user.dart';

class UserDao {
  final tableName = 'users';

  Future<int> create(User user) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(User user) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.query(tableName, orderBy: 'name');
    return users.map((user) => User.fromMap(user)).toList();
  }

  Future<User> fetchById(int id) async {
    final database = await DatabaseService().database;
    final user = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return User.fromMap(user.first);
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