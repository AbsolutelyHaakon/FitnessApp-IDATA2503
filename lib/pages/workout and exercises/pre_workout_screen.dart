import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/create_workout_page.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/during_workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/crud/workout_dao.dart';

class PreWorkoutScreen extends StatefulWidget {
  Workouts workout;

  PreWorkoutScreen({super.key, required this.workout});

  @override
  State<PreWorkoutScreen> createState() {
    return _PreWorkoutScreenState();
  }
}

class _PreWorkoutScreenState extends State<PreWorkoutScreen> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  List<Exercises> exercises = [];
  Map<Exercises, WorkoutExercises> exerciseMap = {};

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.workout.name);
    categoryController = TextEditingController(text: widget.workout.category);
    descriptionController =
        TextEditingController(text: widget.workout.description);
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final tempExercises = await WorkoutDao()
          .localFetchExercisesForWorkout(widget.workout.workoutId);
      Map<Exercises, WorkoutExercises> newExerciseMap = {};
      for (final exercise in tempExercises) {
        final workoutExercise = await WorkoutExercisesDao()
            .localFetchById(widget.workout.workoutId, exercise.exerciseId);
        if (workoutExercise != null) {
          newExerciseMap[exercise] = workoutExercise;
        }
      }
      setState(() {
        exercises = tempExercises;
        exerciseMap = newExerciseMap;
      });
    } catch (e) {
      print('Error fetching exercises: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.fitnessMainColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateWorkoutPage(
                    isAdmin: false,
                    preWorkout: widget.workout,
                  ),
                ),
              );
              if (result == true) {
                await fetchExercises();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.workout.name ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.workout.category ?? '',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.workout.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Center(
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
                                    backgroundImage:
                                        exercise.imageURL != null &&
                                                exercise.imageURL!.isNotEmpty
                                            ? NetworkImage(exercise.imageURL!)
                                            : null,
                                    backgroundColor:
                                        exercise.imageURL == null ||
                                                exercise.imageURL!.isEmpty
                                            ? Colors.green
                                            : null,
                                    child: exercise.imageURL == null ||
                                            exercise.imageURL!.isEmpty
                                        ? Text(
                                            exercise.name[0],
                                            style: const TextStyle(
                                              color: AppColors
                                                  .fitnessPrimaryTextColor,
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
                                      color:
                                          AppColors.fitnessSecondaryTextColor,
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
                                          color: AppColors
                                              .fitnessPrimaryTextColor)),
                                  content: const Text(
                                      'Starting a new workout will end the one currently active. Are you sure?',
                                      style: TextStyle(
                                          color: AppColors
                                              .fitnessPrimaryTextColor)),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('No',
                                          style: TextStyle(
                                              color: AppColors
                                                  .fitnessPrimaryTextColor)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Yes',
                                          style: TextStyle(
                                              color:
                                                  AppColors.fitnessMainColor)),
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
                                    workout: widget.workout,
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
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
