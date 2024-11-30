import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
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

// Last edited: 24/11/2024
// Last edited by: Håkon Svensen Karlsen

//TODO: Implement map functionality
//TODO: Connect it to the persistent storage

class WorkoutPlanModule extends StatefulWidget {
  final UserWorkouts userWorkouts;

  WorkoutPlanModule({super.key, required this.userWorkouts});

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
          .localFetchExercisesForWorkout(widget.userWorkouts.workoutId);
      for (final exercise in exercises) {
        final workoutExercise = await WorkoutExercisesDao()
            .localFetchById(widget.userWorkouts.workoutId, exercise.exerciseId);
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
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor,
              ),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
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
                    leading: CircleAvatar(
                      backgroundImage: exercise.imageURL != null &&
                              exercise.imageURL!.isNotEmpty
                          ? NetworkImage(exercise.imageURL!)
                          : null,
                      backgroundColor: exercise.imageURL == null ||
                              exercise.imageURL!.isEmpty
                          ? Colors.green
                          : null,
                      child: exercise.imageURL == null ||
                              exercise.imageURL!.isEmpty
                          ? Text(
                              exercise.name[0],
                              style: const TextStyle(
                                color: AppColors.fitnessPrimaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            )
                          : null,
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
                        ? const Icon(Icons.tv,
                            color: AppColors.fitnessMainColor)
                        : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          CupertinoButton(
            onPressed: () async {
              if (hasActiveWorkout.value) {
                bool shouldStartNewWorkout = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Active Workout',
                        style: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                    content: const Text(
                        'Starting a new workout will end the one currently active. Are you sure?',
                        style: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No',
                            style: TextStyle(
                                color: AppColors.fitnessPrimaryTextColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes',
                            style:
                                TextStyle(color: AppColors.fitnessMainColor)),
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
                      userWorkouts: widget.userWorkouts,
                      exerciseMap: exerciseMap),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
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
