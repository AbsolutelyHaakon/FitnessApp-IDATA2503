import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../imgur_service.dart';

class ExerciseDao {
  final tableName = 'exercises';

  Future<int> localCreate(Exercises exercise) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> localUpdate(Exercises exercise) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      exercise.toMap(),
      where: 'exerciseId = ?',
      whereArgs: [exercise.exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercises>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Exercises.fromMap(entry)).toList();
  }

  Future<Exercises> localFetchById(int exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return Exercises.fromMap(data.first);
  }

  Future<void> localDelete(int exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  Future<List<Map<String, dynamic>>> localFetchAllAsMap() async {
    final database = await DatabaseService().database;
    return await database.query(tableName);
  }

  Future<Map<String, dynamic>> localFetchAllExercises(String? userId) async {
    final database = await DatabaseService().database;

    // Fetch public exercises
    final publicData = await database.query(tableName,
        where: 'isPrivate = ? AND (userId IS NULL OR userId = ?)',
        whereArgs: [0, '']);

    List<Exercises> publicExercises =
        publicData.map((entry) => Exercises.fromSqfl(entry)).toList();

    if (userId != null && userId.isNotEmpty) {
      // Fetch private exercises for the user
      final privateData = await database
          .query(tableName, where: 'userId = ?', whereArgs: [userId]);
      List<Exercises> privateExercises =
          privateData.map((entry) => Exercises.fromSqfl(entry)).toList();

      return {
        'exercises': [...privateExercises, ...publicExercises]
      };
    } else {
      return {'exercises': publicExercises};
    }
  }

  /////////////////////////////////////////////
  /////////// FIREBASE FUNCTIONS //////////////
  /////////////////////////////////////////////

  Future<void> fireBaseFirstTimeStartup() async {
    final database = await DatabaseService().database;

    // Check for public exercises in the local database
    final publicData = await database.query(
      tableName,
      where: 'isPrivate = ? AND userId = ?',
      whereArgs: [0, ''],
    );

    // If no public exercises exist, fetch from Firestore
    if (publicData.isEmpty) {
      final exercises = await fireBaseFetchAllExercisesFromFireBase(null);
      for (var exercise in exercises['exercises']) {
        await localCreate(exercise);
      }
    }
  }

  Future<Map<String, dynamic>> fireBaseDeleteExercise() async {
    return {'error': 'Not implemented'};
  }

  Future<Map<String, dynamic>> fireBaseFetchAllExercisesFromFireBase(
      String? userId) async {
    // Fetch public exercises
    QuerySnapshot publicExercisesQuery = await FirebaseFirestore.instance
        .collection('exercises')
        .where('isPrivate', isEqualTo: false)
        .where('userId', isEqualTo: '')
        .get();

    List<Exercises> publicExercises = publicExercisesQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['exerciseId'] = doc.id;
      return Exercises.fromMap(data);
    }).toList();

    // If user is logged in, fetch private exercises
    if (userId != null) {
      QuerySnapshot privateExercisesQuery = await FirebaseFirestore.instance
          .collection('exercises')
          .where('isPrivate', isEqualTo: true)
          .where('userId', isEqualTo: userId)
          .get();

      List<Exercises> privateExercises = privateExercisesQuery.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['exerciseId'] = doc.id;
        return Exercises.fromMap(data);
      }).toList();

      return {
        'exercises': [...privateExercises, ...publicExercises]
      };
    } else {
      return {'exercises': publicExercises};
    }
  }

  Future<Map<String, dynamic>> fireBaseUpdateExercise(
      String exerciseId,
      String? name,
      String? description,
      String? category,
      String? videoUrl,
      String? imageURL,
      bool? isPrivate,
      String? userId) async {
    if (userId == null || userId.isEmpty) {
      return {'error': 'You need to log in to edit an exercise'};
    }
    // See if the person editing the exercise is the owner
    bool isOwner = false;
    bool isPrivateBefore = false;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .doc(exerciseId)
        .get();
    // If exercise exists
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      // Check if they are the owner and if it is a public or private exercise
      isOwner = data['userId'] == userId;
      isPrivateBefore = data['isPrivate'];

      if (!isOwner && isPrivateBefore) {
        return {'error': 'You do not have permission to edit this exercise'};
      }
      if (!isOwner && !isPrivateBefore) {
        // If you are editing a public exercise and it will make a new one which you are the owner of
        return fireBaseCreateExercise(
            name ?? data['name'],
            description ?? data['description'],
            category ?? data['category'],
            videoUrl ?? data['video_url'],
            imageURL ?? data['imageURL'],
            isPrivate ?? data['isPrivate'],
            userId ?? data['userId']);
      }

      await FirebaseFirestore.instance
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'name': name ?? data['name'],
        'description': description ?? data['description'],
        'category': category ?? data['category'],
        'video_url': videoUrl ?? data['video_url'],
        'isPrivate': isPrivate ?? data['isPrivate'],
        'userId': userId ?? data['userId'],
      });

      await localUpdate(Exercises(
        exerciseId: exerciseId,
        name: name ?? data['name'],
        description: description ?? data['description'],
        category: category ?? data['category'],
        videoUrl: videoUrl ?? data['video_url'],
        imageURL: imageURL ?? data['imageURL'],
        isPrivate: isPrivate ?? data['isPrivate'],
        userId: userId ?? data['userId'],
      ));

      return {'exerciseId': exerciseId};
    } else {
      return {'error': 'Exercise does not exist'};
    }
  }

  Future<Map<String, dynamic>> fireBaseCreateExercise(
      String name,
      String? description,
      String category,
      String? videoUrl,
      XFile? image,
      bool isPrivate,
      String? userId) async {
    // Handle ImageURL storing if it exits
    String imageURL = '';
    if (image != null) {
      imageURL = await uploadImage(image);
    }

    // If it is private then get the userID so it can be tied to the user
    bool userExists = false;
    if (isPrivate) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      userExists = documentSnapshot.exists;
    }
    if (isPrivate && !userExists) {
      return {'error': 'You need to log in to create a private exercise'};
    }

    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('exercises').add({
      'name': name,
      'description': description ?? '',
      'category': category,
      'video_url': videoUrl ?? '',
      'imageURL': imageURL ?? '',
      'isPrivate': isPrivate,
      'userId': userId ?? '',
    });

    String exerciseId = docRef.id;

    await localCreate(Exercises(
      exerciseId: exerciseId,
      name: name,
      description: description ?? '',
      category: category,
      videoUrl: videoUrl ?? '',
      imageURL: imageURL ?? '',
      isPrivate: isPrivate,
      userId: userId ?? '',
    ));

    return {'exerciseId': exerciseId};
  }

  ImgurService imgurService = ImgurService();

  Future<String> uploadImage(XFile image) async {
    String? imgurUrl = await imgurService.saveImageToImgur(image);
    if (imgurUrl != null) {
      print('Image uploaded to Imgur: $imgurUrl');
      return imgurUrl;
    } else {
      print('Failed to upload to Imgur.');
      return "";
    }
  }

//////////////////////////////////////////////////////////////////////////////
////////////////////////////  Firebase Admin /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

  Future<int> getExercisesCount() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.length;
  }
}
