import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseDao {
  final tableName = 'exercises';

  Future<int> create(Exercises exercise) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Exercises exercise) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      exercise.toMap(),
      where: 'exerciseId = ?',
      whereArgs: [exercise.exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercises>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName);
    return data.map((entry) => Exercises.fromMap(entry)).toList();
  }

  Future<Exercises> fetchById(int exerciseId) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
    return Exercises.fromMap(data.first);
  }

  Future<void> delete(int exerciseId) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllAsMap() async {
    final database = await DatabaseService().database;
    return await database.query(tableName);
  }


  /////////////////////////////////////////////
  /////////// FIREBASE FUNCTIONS //////////////
  /////////////////////////////////////////////

  Future<Map<String, dynamic>> updateExercise(String exerciseId, String? name, String? description, String? category,
    String? videoUrl, bool? isPrivate, String? userId) async {

  // Check for internet connection
  var connectivityResult = await (Connectivity().checkConnectivity());
  bool isConnected = connectivityResult != ConnectivityResult.none;

  if (isConnected) {
    // See if the person editing the exercise is the owner
    bool isOwner = false;
    bool isPrivateBefore = false;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('exercises').doc(exerciseId).get();
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
        return createExercise(
          name ?? data['name'],
          description ?? data['description'],
          category ?? data['category'],
          videoUrl ?? data['video_url'],
          isPrivate ?? data['isPrivate'],
          userId ?? data['userId']
        );
      }

      await FirebaseFirestore.instance.collection('exercises').doc(exerciseId).update({
        'name': name ?? data['name'],
        'description': description ?? data['description'],
        'category': category ?? data['category'],
        'video_url': videoUrl ?? data['video_url'],
        'isPrivate': isPrivate  ?? data['isPrivate'],
        'userId': userId ?? data['userId'],
      });

      await update(Exercises(
        exerciseId: exerciseId,
        name: name ?? data['name'],
        description: description ?? data['description'],
        category: category ?? data['category'],
        videoUrl: videoUrl ?? data['video_url'],
        isPrivate: isPrivate ?? data['isPrivate'],
        userId: userId ?? data['userId'],
      ));

      return {'exerciseId': exerciseId};
    } else {
      return {'error': 'Exercise does not exist'};
    }
  } else {
    // Perform local update
    Exercises exercise = await fetchById(int.parse(exerciseId));
    await update(Exercises(
      exerciseId: exerciseId,
      name: name ?? exercise.name,
      description: description ?? exercise.description,
      category: category ?? exercise.category,
      videoUrl: videoUrl ?? exercise.videoUrl,
      isPrivate: isPrivate ?? exercise.isPrivate,
      userId: userId ?? exercise.userId,
    ));
    return {'exerciseId': exerciseId};
  }
}

Future<Map<String, dynamic>> createExercise(String name, String description, String category,
                                            String videoUrl, bool isPrivate, String userId) async {
  // Check for internet connection
  var connectivityResult = await (Connectivity().checkConnectivity());
  bool isConnected = connectivityResult != ConnectivityResult.none;

  if (isConnected) {
    // If it is private then get the userID so it can be tied to the user
    bool userExists = false;
    if (isPrivate) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      userExists = documentSnapshot.exists;
    }
    if (isPrivate && !userExists) {
      return {'error': 'You need to log in to create a private exercise'};
    }

    DocumentReference docRef = await FirebaseFirestore.instance.collection('exercises').add({
      'name': name,
      'description': description,
      'category': category,
      'video_url': videoUrl,
      'isPrivate': isPrivate,
      'userId': userId,
    });

    String exerciseId = docRef.id;

    await create(Exercises(
      exerciseId: exerciseId,
      name: name,
      description: description,
      category: category,
      videoUrl: videoUrl,
      isPrivate: isPrivate,
      userId: userId,
    ));

    return {'exerciseId': exerciseId};
  } else {
    // Perform local creation
    String exerciseId = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique ID based on timestamp
    await create(Exercises(
      exerciseId: exerciseId,
      name: name,
      description: description,
      category: category,
      videoUrl: videoUrl,
      isPrivate: isPrivate,
      userId: userId,
    ));
    return {'exerciseId': exerciseId};
  }
}

}