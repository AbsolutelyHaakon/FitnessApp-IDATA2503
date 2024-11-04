import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../database_service.dart';
import '../tables/exercise.dart';
import '../tables/workout.dart';

class WorkoutDao {
  final tableName = 'workouts';

  Future<int> create(Workouts workout) async {
    final database = await DatabaseService().database;
    return await database.insert(
      tableName,
      workout.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(Workouts workout) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.workoutId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Workouts>> fetchAll() async {
    final database = await DatabaseService().database;
    final data = await database.query(tableName, orderBy: 'name');
    return data.map((entry) => Workouts.fromMap(entry)).toList();
  }

  Future<Workouts> fetchById(String id) async {
    final database = await DatabaseService().database;
    final data = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Workouts.fromMap(data.first);
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Exercises>> fetchExercisesForWorkout(String workoutId) async {
    final database = await DatabaseService().database;
    final data = await database.rawQuery('''
      SELECT exercises.* FROM exercises
      INNER JOIN workoutExercises ON exercises.exerciseId = workoutExercises.exerciseId
      WHERE workoutExercises.workoutId = ?
    ''', [workoutId]);
    return data.map((entry) => Exercises.fromMap(entry)).toList();
  }

  Future<void> truncate() async {
    final database = await DatabaseService().database;
    await database.delete(tableName);
  }

  ////////////////////////////////////////////////////////////
  ////////////////// FIREBASE FUNCTIONS //////////////////////
  ////////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> fetchAllWorkoutsFromFireBase(String userId) async {

    // Get all workouts for the user (public and private)
    QuerySnapshot personalWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId).get();

    // Get all the workouts that are public for all users and has no userId
    QuerySnapshot publicWorkoutsQuery = await FirebaseFirestore.instance
        .collection('workouts')
        .where('isPrivate', isEqualTo: false)
        .where('userId', isEqualTo: '')
        .get();

    List<Workouts> personalWorkouts = personalWorkoutsQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    List<Workouts> publicWorkouts = publicWorkoutsQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['workoutId'] = doc.id;
      return Workouts.fromMap(data);
    }).toList();

    List<Workouts> allWorkouts = [...personalWorkouts, ...publicWorkouts];

    return {'workouts': allWorkouts};
  }


 Future<String?> createWorkout(String? category, String? description, int? duration, int? intensity,
     bool isPrivate, String? userId, String? video_url, String name, bool wantId) async {

    DocumentReference docRef = await FirebaseFirestore.instance.collection('workouts').add({
      'category': category ?? '',
      'description': description ?? '',
      'duration': duration ?? 0,
      'intensity': intensity ?? 0,
      'isPrivate': isPrivate,
      'userId': userId ?? '',
      'video_url': video_url ?? '',
      'name': name,
    });

    String newDocId = docRef.id;

    create(Workouts(
      workoutId: newDocId,
      category: category,
      description: description,
      duration: duration,
      intensity: intensity,
      isPrivate: isPrivate,
      userId: userId ?? '',
      videoUrl: video_url,
      name: name,
    ));

    return wantId ? newDocId : null;
}



}