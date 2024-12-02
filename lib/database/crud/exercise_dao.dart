// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../imgur_service.dart';

// DAO for handling exercises
class ExerciseDao {
  final tableName = 'exercises';

  // Function to create a new exercise in the local database
  Future<int> localCreate(Exercises exercise) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to update an existing exercise in the local database
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

  // Function to fetch all exercises from the local database
  Future<List<Exercises>> localFetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Exercises.fromMap(entry)).toList();
  }

  // Function to fetch a specific exercise by its ID from the local database
  Future<Exercises> localFetchById(int exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return Exercises.fromMap(data.first);
  }

  // Function to delete a specific exercise by its ID from the local database
  Future<void> localDelete(String exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
  }

  // Function to delete all exercises from the local database
  Future<void> localTruncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  // Function to fetch all exercises as a map from the local database
  Future<List<Map<String, dynamic>>> localFetchAllAsMap() async {
    final database = await DatabaseService().database;
    return await database.query(tableName);
  }

  // Function to fetch all exercises, both public and private, for a specific user from the local database
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

  // Function to fetch all exercises from Firebase and store them in the local database if they don't exist
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

  // Function to delete a specific exercise from Firebase and the local database
  Future<bool> fireBaseDeleteExercise(String exerciseId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .doc(exerciseId)
        .get();
    if (documentSnapshot.exists) {
      await FirebaseFirestore.instance
          .collection('exercises')
          .doc(exerciseId)
          .delete();
      await localDelete(exerciseId);
      return true;
    } else {
      return false;
    }
  }

  // Function to fetch all exercises from Firebase
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

  // Function to fetch a specific exercise from Firebase by its ID
  Future<Exercises?> fireBaseFetchExercise(String exerciseId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('exercises')
        .doc(exerciseId)
        .get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      data['exerciseId'] = documentSnapshot.id;
      return Exercises.fromMap(data);
    } else {
      return null;
    }
  }

  // Function to update a specific exercise in Firebase and the local database
  Future<Map<String, dynamic>> fireBaseUpdateExercise(
      String exerciseId,
      String? name,
      String? description,
      String? category,
      String? videoUrl,
      String? imageURL,
      XFile? image,
      bool? isPrivate,
      String? userId) async {
    if (userId == null) {
      print("pepepepe");
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
            userId);
      }

      if (image != null) {
        imageURL = await uploadImage(image);
      }

      await FirebaseFirestore.instance
          .collection('exercises')
          .doc(exerciseId)
          .update({
        'name': name ?? data['name'],
        'description': description ?? data['description'],
        'category': category ?? data['category'],
        'video_url': videoUrl ?? data['video_url'],
        'imageURL': imageURL ?? data['imageURL'],
        'isPrivate': isPrivate ?? data['isPrivate'],
        'userId': userId,
      });

      await localUpdate(Exercises(
        exerciseId: exerciseId,
        name: name ?? data['name'],
        description: description ?? data['description'],
        category: category ?? data['category'],
        videoUrl: videoUrl ?? data['video_url'],
        imageURL: imageURL ?? data['imageURL'],
        isPrivate: isPrivate ?? data['isPrivate'],
        userId: userId,
      ));

      return {'exerciseId': exerciseId};
    } else {
      return {'error': 'Exercise does not exist'};
    }
  }

  // Function to create a new exercise in Firebase and the local database
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
      'imageURL': imageURL,
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
      imageURL: imageURL,
      isPrivate: isPrivate,
      userId: userId ?? '',
    ));

    return {'exerciseId': exerciseId};
  }

  ImgurService imgurService = ImgurService();

  // Function to upload an image to Imgur and return the URL
  Future<String> uploadImage(XFile image) async {
    String? imgurUrl = await imgurService.saveImageToImgur(image);
    if (imgurUrl != null) {
      return imgurUrl;
    } else {
      return "";
    }
  }

//////////////////////////////////////////////////////////////////////////////
////////////////////////////  Firebase Admin /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

  // Function to get the count of exercises in the local database
  Future<int> getExercisesCount() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.length;
  }
}
