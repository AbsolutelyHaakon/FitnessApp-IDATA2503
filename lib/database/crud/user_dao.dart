import 'package:cloud_firestore/cloud_firestore.dart';
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
    print('User created: ${user.id}');
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

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////// Firebase Authentication /////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      print("User created: ${user?.uid}");
      createUserData(user?.uid, email);
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

 void createUserData(String? uid, String email) {
  FirebaseFirestore.instance.collection('users').doc(uid).set({
    'email': email,
    'name': 'Not Set',
    'height': 0.0,
    'weight': 0.0,
  });
  create(LocalUser(
      id: uid!,
      name: 'John Doe',
      email: email,
      weight: 0.0,
      height: 0.0));
}

  Future<Map<String, dynamic>> loginWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return {'user': userCredential.user, 'error': null};
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email') {
      return {'user': null, 'error': 'No user found for that email.'};
    } else if (e.code == 'invalid-credential') {
      return {'user': null, 'error': 'Wrong password provided.'};
    }
  } catch (e) {
    return {'user': null, 'error': e.toString()};
  }
  return {'user': null, 'error': 'Unknown error occurred.'};
}


}