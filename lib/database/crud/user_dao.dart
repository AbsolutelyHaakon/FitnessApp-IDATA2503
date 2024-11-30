import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/imgur_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/user.dart';

/// Data Access Object for the User table
/// All CRUD operations are defined here

class UserDao {
  final tableName = 'users';
  FirebaseAuth _auth = FirebaseAuth.instance;

  final ImgurService imgurService = ImgurService();

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
    if (user.isNotEmpty) {
      return LocalUser.fromMap(user.first);
    } else {
      throw StateError('No element');
    }
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

  Future<bool> fireBaseCheckIfEmailExists(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

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
      'weight': 0,
    });
    localCreate(LocalUser(
        userId: uid!, name: 'John Doe', email: email, weight: 0, height: 0.0));
  }

  void fireBaseUpdateUserEmail(
      String uid, String newEmail, String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        await user.verifyBeforeUpdateEmail(newEmail);
        print(
            'Verification email sent to $newEmail. Please verify to complete the update.');

        int checkCount = 0;
        const int maxChecks = 20;
        await FirebaseAuth.instance.signOut();

        Timer.periodic(Duration(seconds: 30), (timer) async {
          checkCount++;
          await user.reload();
          if (user.emailVerified) {
            await updateEmailInFirestore(uid, newEmail);
            timer.cancel();
          } else if (checkCount >= maxChecks) {
            print('Email not verified after $maxChecks checks.');
            timer.cancel();
          } else {
            print('Email not verified yet.');
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      print('Error updating email: $e');
      throw e;
    } catch (e) {
      print('Error updating email: $e');
      throw e;
    }
  }

  Future<void> updateEmailInFirestore(String uid, String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'email': newEmail,
        });

        DocumentSnapshot documentSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        Map<String, dynamic>? userData =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          LocalUser updatedLocalUser = LocalUser(
            userId: uid,
            name: userData['name'] ?? 'Unknown',
            email: newEmail,
            weight: userData['weight'] ?? 0,
            height: userData['height'] ?? 0.0,
            weightTarget: userData['weightTarget'] ?? 0,
            weightInitial: userData['weightInitial'] ?? 0,
            imageURL: userData['imageURL'] ?? '',
            bannerURL: userData['bannerURL'] ?? '',
            waterTarget: userData['waterTarget'] ?? 0,
            caloriesIntakeTarget: userData['caloriesIntakeTarget'] ?? 0,
            caloriesBurnedTarget: userData['caloriesBurnedTarget'] ?? 0,
          );

          await localUpdate(updatedLocalUser);
          print('Email updated successfully');
        } else {
          print('Local user not found');
        }
      } else {
        throw Exception('Email not verified or does not match the new email');
      }
    } catch (e) {
      print('Error updating email in Firestore: $e');
      throw e;
    }
  }

  void fireBaseUpdateUserData(
      String uid,
      String? name,
      double? height,
      int? weight,
      int? weightTarget,
      int? weightInitial,
      XFile? profileImage,
      XFile? bannerImage,
      int? waterTarget,
      int? caloriesIntakeTarget,
      int? caloriesBurnedTarget) async {
    if (uid == "") return;

    // Fetch existing user data
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic>? existingData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (existingData == null) return;

    String imageURL = '';
    if (profileImage != null) {
      imageURL = await uploadImage(profileImage);
    }

    print(existingData['weight']);

    // Replace empty values with existing values
    String updatedName =
        name?.isNotEmpty == true ? name! : existingData['name'];
    double updatedHeight = height != null && height != 0.0
        ? height
        : (existingData['height'] as num).toDouble();
    int updatedWeight = weight != null && weight != 0
        ? weight
        : (existingData['weight'] as num).toInt();
    int updatedWeightTarget = weightTarget != null && weightTarget != 0
        ? weightTarget
        : (existingData['weightTarget'] ?? 0);
    int updatedWeightInitial = weightInitial != null && weightInitial != 0
        ? weightInitial
        : (existingData['weightInitial'] ?? 0);
    String updatedImageURL =
        imageURL.isNotEmpty ? imageURL : (existingData['imageURL'] ?? '');
    String updatedBannerURL = bannerImage != null
        ? await uploadImage(bannerImage)
        : (existingData['bannerURL'] ?? '');
    int updatedWaterTarget = waterTarget != null && waterTarget != 0
        ? waterTarget
        : (existingData['waterTarget'] ?? 0);
    int updatedCaloriesIntakeTarget =
        caloriesIntakeTarget != null && caloriesIntakeTarget != 0
            ? caloriesIntakeTarget
            : (existingData['caloriesIntakeTarget'] ?? 0);
    int updatedCaloriesBurnedTarget =
        caloriesBurnedTarget != null && caloriesBurnedTarget != 0
            ? caloriesBurnedTarget
            : (existingData['caloriesBurnedTarget'] ?? 0);

    // Update Firestore
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': updatedName,
      'height': updatedHeight,
      'weight': updatedWeight,
      'weightTarget': updatedWeightTarget,
      'weightInitial': updatedWeightInitial,
      'imageURL': updatedImageURL,
      'bannerURL': updatedBannerURL,
      'waterTarget': updatedWaterTarget,
      'caloriesIntakeTarget': updatedCaloriesIntakeTarget,
      'caloriesBurnedTarget': updatedCaloriesBurnedTarget,
    });

    // Update local database
    localUpdate(LocalUser(
      userId: uid,
      name: updatedName,
      email: existingData['email'],
      weight: updatedWeight,
      height: updatedHeight,
      weightTarget: updatedWeightTarget,
      weightInitial: updatedWeightInitial,
      imageURL: updatedImageURL,
      bannerURL: updatedBannerURL,
      waterTarget: updatedWaterTarget,
      caloriesIntakeTarget: updatedCaloriesIntakeTarget,
      caloriesBurnedTarget: updatedCaloriesBurnedTarget,
    ));
  }

  Future<Map<String, dynamic>?> fireBaseGetUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        // Ensure that fields expected to be int? are properly converted
        data['weight'] = (data['weight'] as num?)?.toInt();
        data['weightTarget'] = (data['weightTarget'] as num?)?.toInt();
        data['weightInitial'] = (data['weightInitial'] as num?)?.toInt();
        data['waterTarget'] = (data['waterTarget'] as num?)?.toInt();
        data['caloriesIntakeTarget'] =
            (data['caloriesIntakeTarget'] as num?)?.toInt();
        data['caloriesBurnedTarget'] =
            (data['caloriesBurnedTarget'] as num?)?.toInt();
      }

      return data;
    } catch (e) {
      print('Error fetching users: $e');
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

  Future<String> uploadImage(XFile image) async {
    String? imgurUrl = await imgurService.saveImageToImgur(image);
    if (imgurUrl != null) {
      return imgurUrl;
    } else {
      return "";
    }
  }

  Future<Map<String, dynamic>> fireBaseUpdateUserPassword(
      String uid, String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return {'success': true, 'error': null};
      } else {
        return {'success': false, 'error': 'User not found'};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

//////////////////////////////////////////////////////////////////////////////
////////////////////////////  Firebase Admin /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

  // Check if user is admin
  // Admin status can only be given on the Firebase console and is not present within the app
  Future<bool> getAdminStatus(String? uid) async {
    if (uid == null || uid!.isEmpty) {
      return false;
    }
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;
    return data?['isAdmin'] ?? false;
  }

  Future<int> getUserCount() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.length;
  }
}
