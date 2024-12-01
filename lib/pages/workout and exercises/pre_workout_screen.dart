import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/create_workout_page.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/during_workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/crud/workout_dao.dart';

// Screen displayed before starting a workout
class PreWorkoutScreen extends StatefulWidget {
  UserWorkouts? userWorkouts;
  Workouts? workouts;
  bool isSearch;

  PreWorkoutScreen(
      {super.key, this.userWorkouts, this.workouts, required this.isSearch});

  @override
  State<PreWorkoutScreen> createState() {
    return _PreWorkoutScreenState();
  }
}

class _PreWorkoutScreenState extends State<PreWorkoutScreen> {
  List<Exercises> exercises = [];
  Map<Exercises, WorkoutExercises> exerciseMap = {};
  bool isAdmin = false;

  final WorkoutDao _workoutDao = WorkoutDao();
  Workouts workouts = const Workouts(
    workoutId: '0',
    name: 'Workout 1',
    imageURL: '',
    description: 'Description 1',
    duration: 30,
    isPrivate: false,
    userId: '1',
    isDeleted: false,
  );

  @override
  void initState() {
    super.initState();
    if (widget.workouts != null) {
      _getWorkoutData(false);
    } else {
      _getUserWorkoutData();
    }
  }

  // Fetch workout data
  _getWorkoutData(bool isUpdate) async {
    if (isUpdate) {
      if (widget.workouts == null) {
        return;
      }
      widget.workouts =
          await WorkoutDao().localFetchByWorkoutId(widget.workouts!.workoutId);
    }

    setState(() {
      workouts = widget.workouts!;
    });
    fetchExercises();
  }

  // Fetch user workout data
  _getUserWorkoutData() async {
    if (widget.userWorkouts == null) {
      return;
    }
    if (widget.isSearch) {
      Workouts? temp = await _workoutDao
          .fireBaseFetchWorkout(widget.userWorkouts!.workoutId);
      if (temp != null) {
        workouts = temp;
        fetchExercises();
      }
    } else {
      Workouts? temp = await _workoutDao
          .localFetchByWorkoutId(widget.userWorkouts!.workoutId);
      workouts = temp ?? workouts;
      if (workouts.workoutId != '0') {
        fetchExercises();
      }
    }

    await UserDao()
        .getAdminStatus(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      setState(() {
        isAdmin = value;
      });
    });
  }

  // Fetch exercises for the workout
  Future<void> fetchExercises() async {
    try {
      List<Exercises> tempExercises = [];
      Map<Exercises, WorkoutExercises> newExerciseMap = {};
      if (widget.isSearch) {
        tempExercises = await WorkoutDao()
            .fireBaseFetchExercisesForWorkout(workouts.workoutId);
        for (final exercise in tempExercises) {
          final workoutExercise = await WorkoutExercisesDao()
              .fireBaseFetchById(workouts.workoutId, exercise.exerciseId);
          if (workoutExercise != null) {
            newExerciseMap[exercise] = workoutExercise;
          }
        }
      } else {
        tempExercises = await WorkoutDao()
            .localFetchExercisesForWorkout(workouts.workoutId);

        for (final exercise in tempExercises) {
          final workoutExercise = await WorkoutExercisesDao()
              .localFetchById(workouts.workoutId, exercise.exerciseId);
          if (workoutExercise != null) {
            newExerciseMap[exercise] = workoutExercise;
          }
        }
      }

      // Update the exerciseMap before sorting
      setState(() {
        exerciseMap = newExerciseMap;
      });

      // Sort exercises based on exerciseOrder
      tempExercises.sort((a, b) {
        final orderA = exerciseMap[a]?.exerciseOrder ?? 0;
        final orderB = exerciseMap[b]?.exerciseOrder ?? 0;
        return orderA.compareTo(orderB);
      });

      setState(() {
        exercises = tempExercises;
      });
    } catch (e) {
      print('Error fetching exercises: $e');
    }

    await UserDao()
        .getAdminStatus(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      setState(() {
        isAdmin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Plan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.fitnessPrimaryTextColor,
              ),
        ),
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
          if (FirebaseAuth.instance.currentUser != null &&
              (FirebaseAuth.instance.currentUser!.uid == workouts.userId ||
                  isAdmin))
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateWorkoutPage(
                      isAdmin: false,
                      preWorkout: workouts,
                    ),
                  ),
                );
                if (result != null && result is Workouts) {
                  setState(() {
                    _getWorkoutData(true);
                  });
                }
              },
              child: const Text('Edit Workout',
                  style: TextStyle(color: AppColors.fitnessMainColor)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workouts.name ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            workouts.category ?? '',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            workouts.description ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100, // Set the desired width
                        height: 100, // Set the desired height
                        child: workouts.imageURL != null && workouts.imageURL!.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Set the desired radius
                          child: Image.network(workouts.imageURL!, fit: BoxFit.cover),
                        )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ],
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
                            decoration: const BoxDecoration(
                              color: AppColors.fitnessModuleColor,
                            ),
                            child: ListView.builder(
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = exercises[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
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
                        Row(
                          children: [
                            Expanded(
                              flex: widget.isSearch ? 8 : 9,
                              child: CupertinoButton(
                                onPressed: () async {
                                  if (hasActiveWorkout.value) {
                                    bool shouldStartNewWorkout =
                                        await showDialog(
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
                                                Navigator.of(context)
                                                    .pop(false),
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
                                                    color: AppColors
                                                        .fitnessMainColor)),
                                          ),
                                        ],
                                        backgroundColor:
                                            AppColors.fitnessModuleColor,
                                      ),
                                    );
                                    if (!shouldStartNewWorkout) {
                                      return;
                                    }
                                  }
                                  if (widget.userWorkouts == null &&
                                      widget.workouts != null) {
                                    if (FirebaseAuth
                                            .instance.currentUser?.uid !=
                                        null) {
                                      final newDocId = await UserWorkoutsDao()
                                          .fireBaseCreateUserWorkout(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              widget.workouts!.workoutId,
                                              DateTime.now());
                                      if (newDocId == null) {
                                        return;
                                      }

                                      final newUserWorkout =
                                          await UserWorkoutsDao()
                                              .localFetchByUserWorkoutsId(
                                                  newDocId);
                                      widget.userWorkouts = newUserWorkout;
                                    } else {
                                      final newUserWorkout =
                                          await UserWorkoutsDao()
                                              .localCreate(UserWorkouts(
                                        userWorkoutId: '1',
                                        userId: FirebaseAuth
                                                .instance.currentUser?.uid ??
                                            '',
                                        workoutId: widget.workouts!.workoutId,
                                        date: DateTime.now(),
                                        duration: 0.0,
                                        statistics: '',
                                        isActive: true,
                                      ));
                                      widget.userWorkouts = newUserWorkout;
                                    }
                                  }

                                  exerciseStats = {};
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DuringWorkoutScreen(
                                          userWorkouts: widget.userWorkouts!,
                                          exerciseMap: exerciseMap),
                                    ),
                                  );
                                },
                                child: Container(
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
                            ),
                            if (widget.isSearch &&
                                FirebaseAuth.instance.currentUser != null)
                              Expanded(
                                flex: 3,
                                child: CupertinoButton(
                                  onPressed: () {},
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.fitnessSecondaryModuleColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      CupertinoIcons.add_circled,
                                      color: AppColors.fitnessPrimaryTextColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
