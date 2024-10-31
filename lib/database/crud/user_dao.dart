import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/user.dart';

class UserDao {
  final tableName = 'users';
  FirebaseAuth _auth = FirebaseAuth.instance;

  set auth(FirebaseAuth auth) {
    _auth = auth;
  }

  Future<int> create(LocalUser user) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(LocalUser user) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalUser>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.query(tableName, orderBy: 'name');
    return users.map((user) => LocalUser.fromMap(user)).toList();
  }

  Future<LocalUser> fetchById(int id) async {
    final database = await DatabaseService().database;
    final user = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return LocalUser.fromMap(user.first);
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllAsMap() async {
    final database = await DatabaseService().database;
    return await database.query(tableName);
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      print("User created: ${user?.uid}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}