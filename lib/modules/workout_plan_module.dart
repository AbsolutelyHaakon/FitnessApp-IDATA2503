import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/globals.dart';

import '../database/crud/workout_dao.dart';
import '../pages/workout and exercises/during_workout.dart';

// Shows the selected workout plan details before deciding to start it
// Displays workout info and potentially a map of the workout route

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
    fetchExercises(); // Fetch exercises when the widget is initialized
  }

  // Function to fetch exercises for the workout
  void fetchExercises() async {
    try {
      exercises = await WorkoutDao()
          .localFetchExercisesForWorkout(widget.userWorkouts.workoutId);
      for (final exercise in exercises) {
        final workoutExercise = await WorkoutExercisesDao()
            .localFetchById(widget.userWorkouts.workoutId, exercise.exerciseId);
        if (workoutExercise != null) {
          exerciseMap[exercise] = workoutExercise; // Map exercises to workout exercises
        }
      }
      setState(() {}); // Update the state to reflect the fetched exercises
    } catch (e) {
      print('Error fetching exercises: $e'); // Print error if fetching fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40), // Add some space at the top
          ClipRRect(
            borderRadius: BorderRadius.circular(30), // Rounded corners for the container
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor, // Background color for the container
              ),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: exercises.length, // Number of exercises
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0), // Padding for the list tile
                    tileColor: Colors.white.withOpacity(0.1), // Background color with opacity
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners for the list tile
                    ),
                    leading: CircleAvatar(
                      backgroundImage: exercise.imageURL != null &&
                              exercise.imageURL!.isNotEmpty
                          ? NetworkImage(exercise.imageURL!) // Display image if available
                          : null,
                      backgroundColor:
                          exercise.imageURL == null || exercise.imageURL!.isEmpty
                              ? Colors.green // Default background color if no image
                              : null,
                      child:
                          exercise.imageURL == null || exercise.imageURL!.isEmpty
                              ? Text(
                                  exercise.name[0], // Display first letter of the exercise name
                                  style: const TextStyle(
                                    color: AppColors.fitnessPrimaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24.0,
                                  ),
                                )
                              : null,
                    ),
                    title: Text(
                      exercise.name, // Display exercise name
                      style: const TextStyle(
                        color: AppColors.fitnessPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      'Reps: ${exerciseMap[exercise]?.reps}, Sets: ${exerciseMap[exercise]?.sets}', // Display reps and sets
                      style: const TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                        fontSize: 16.0,
                      ),
                    ),
                    trailing: exercise.videoUrl != null &&
                            exercise.videoUrl!.isNotEmpty
                        ? const Icon(Icons.tv, color: AppColors.fitnessMainColor) // Display video icon if available
                        : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40), // Add some space below the list
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
                  return; // Do nothing if the user chooses not to start a new workout
                }
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DuringWorkoutScreen(
                      userWorkouts: widget.userWorkouts, exerciseMap: exerciseMap), // Navigate to the DuringWorkoutScreen
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // Button width
              height: 60, // Button height
              decoration: BoxDecoration(
                color: AppColors.fitnessMainColor, // Button background color
                borderRadius: BorderRadius.circular(20), // Rounded corners for the button
              ),
              alignment: Alignment.center,
              child: const Text(
                "Start Workout", // Button text
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