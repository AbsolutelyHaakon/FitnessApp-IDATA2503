import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/globals.dart';

import '../database/crud/workout_dao.dart';
import '../pages/workout and exercises/during_workout.dart';

// Shows the selected workout plan details before deciding to start it
// Displays workout info and potentially a map of the workout route

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

//TODO: Implement map functionality
//TODO: Connect it to the persistent storage

class WorkoutPlanModule extends StatefulWidget {
  final Workouts workout;

  WorkoutPlanModule({super.key, required this.workout});

  @override
  State<WorkoutPlanModule> createState() => _WorkoutPlanModuleState();
}

class _WorkoutPlanModuleState extends State<WorkoutPlanModule> {
  List<Exercises> exercises = [];
  Map<Exercises, WorkoutExercises> exerciseMap = {};

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  void fetchExercises() async {
    try {
      exercises = await WorkoutDao()
          .localFetchExercisesForWorkout(widget.workout.workoutId);
      for (final exercise in exercises) {
        final workoutExercise = await WorkoutExercisesDao()
            .localFetchById(widget.workout.workoutId, exercise.exerciseId);
        if (workoutExercise != null) {
          exerciseMap[exercise] = workoutExercise;
        }
      }
      setState(() {});
    } catch (e) {
      print('Error fetching exercises: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.fitnessModuleColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Color(0xFF262626), // Almost the same color
                width: 1.0, // Very thin
              ),
            ),
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  tileColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: AppColors.fitnessPrimaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Text(
                    'Reps: ${exerciseMap[exercise]?.reps}, Sets: ${exerciseMap[exercise]?.sets}',
                    style: const TextStyle(
                      color: AppColors.fitnessSecondaryTextColor,
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: exercise.videoUrl != null &&
                          exercise.videoUrl!.isNotEmpty
                      ? const Icon(Icons.tv, color: AppColors.fitnessMainColor)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 90),
          CupertinoButton(
            onPressed: () async {
              if (hasActiveWorkout) {
                bool shouldStartNewWorkout = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Active Workout',
                        style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                    content: const Text(
                        'Starting a new workout will end the one currently active. Are you sure?',
                        style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No',
                            style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes',
                            style: TextStyle(color: AppColors.fitnessMainColor)),
                      ),
                    ],
                    backgroundColor: AppColors.fitnessModuleColor,
                  ),
                );
                if (!shouldStartNewWorkout) {
                  return;
                }
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DuringWorkoutScreen(
                      workout: widget.workout, exerciseMap: exerciseMap),
                ),
              );
            },
            child: Container(
              width: 410,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.fitnessMainColor,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Start Workout",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
