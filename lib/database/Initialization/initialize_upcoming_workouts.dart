import 'package:sqflite/sqflite.dart';
import 'package:fitnessapp_idata2503/database/database_service.dart';
import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';

Future<List<UpcomingWorkoutsBox>> initializeUpcomingWorkoutData() async {
  final db = await DatabaseService().database;
  final today = DateTime.now();
  final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT workouts.name, workouts.category, workoutDates.date
    FROM workouts
    INNER JOIN workoutDates ON workouts.id = workoutDates.workoutId
    WHERE workoutDates.date >= ?
    ORDER BY workoutDates.date ASC
  ''', [today.toIso8601String()]);

  List<UpcomingWorkoutsBox> workouts = List.generate(maps.length, (i) {
    return UpcomingWorkoutsBox(
      title: maps[i]['name'],
      category: Type.values[maps[i]['category'] as int],
      date: DateTime.parse(maps[i]['date']),
      workouts: [], // Assuming workouts are stored elsewhere and need to be fetched separately
    );
  });

  return workouts;
}