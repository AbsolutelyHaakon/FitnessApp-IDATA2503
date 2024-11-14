import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/user.dart';

/**
 * Data Access Object for the User table
 * All CRUD operations are defined here
 */

class UserDao {
  final tableName = 'users';
  FirebaseAuth _auth = FirebaseAuth.instance;

  set auth(FirebaseAuth auth) {
    _auth = auth;
  }

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Local Database CRUD //////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<int> localCreate(LocalUser user) async {
    final database = await DatabaseService().database;
    print('User created: ${user.userId}');
    return await database.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> localUpdate(LocalUser user) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalUser>> localFetchAll() async {
    final database = await DatabaseService().database;
    final users = await database.query(tableName, orderBy: 'name');
    return users.map((user) => LocalUser.fromMap(user)).toList();
  }

  Future<LocalUser> localFetchById(String id) async {
    final database = await DatabaseService().database;
    final user = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return LocalUser.fromMap(user.first);
  }

  Future<void> localDelete(int id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> localFetchAllAsMap() async {
    final database = await DatabaseService().database;
    return await database.query(tableName);
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////// Firebase Authentication /////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> fireBaseCreateUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      fireBaseCreateUserData(user?.uid, email);
      return {'user': user, 'error': null};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return {'user': null, 'error': 'The password provided is too weak.'};
      } else if (e.code == 'email-already-in-use') {
        return {
          'user': null,
          'error': 'The account already exists for that email.'
        };
      }
    } catch (e) {
      return {'user': null, 'error': e.toString()};
    }
    return {'user': null, 'error': 'Unknown error occurred.'};
  }

  void fireBaseCreateUserData(String? uid, String email) {
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'email': email,
      'name': 'Not Set',
      'height': 0.0,
      'weight': 0.0,
    });
    localCreate(LocalUser(
        userId: uid!, name: 'John Doe', email: email, weight: 0.0, height: 0.0));
  }

  void fireBaseUpdateUserData(
      String uid, String name, double height, double weight) async {
    if (uid == "") return;

    // Fetch existing user data
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic>? existingData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (existingData == null) return;

    // Replace empty values with existing values
    String updatedName = name.isNotEmpty ? name : existingData['name'];
    double updatedHeight = height != 0.0 ? height : existingData['height'];
    double updatedWeight = weight != 0.0 ? weight : existingData['weight'];

    // Update Firestore
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': updatedName,
      'height': updatedHeight,
      'weight': updatedWeight,
    });

    // Update local database
    localUpdate(LocalUser(
      userId: uid,
      name: updatedName,
      email: existingData['email'],
      weight: updatedWeight,
      height: updatedHeight,
    ));
  }

  Future<Map<String, dynamic>?> fireBaseGetUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return documentSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> fireBaseLoginWithEmailAndPassword(
      String email, String password) async {
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
