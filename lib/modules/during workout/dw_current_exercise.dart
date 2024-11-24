import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/beeping_circle.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_progress-bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/tables/exercise.dart';
import '../../database/tables/workout_exercises.dart';
import '../../globals.dart';
import '../../styles.dart';



class DwCurrentExercise extends StatefulWidget {
  final Map<Exercises, WorkoutExercises> exerciseMap;
  final UserWorkouts userWorkouts;

  const DwCurrentExercise(
      {super.key, required this.exerciseMap, required this.userWorkouts});

  @override
  _DwCurrentExerciseState createState() => _DwCurrentExerciseState();
}

class _DwCurrentExerciseState extends State<DwCurrentExercise> {
  List<Exercises> exercises = [];
  List<WorkoutExercises> workoutExercises = [];
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  final ScrollController _scrollController = ScrollController();
  Duration workoutDuration = Duration.zero;
  int finalTime = 0;
  String workoutId = '';

  UserWorkouts? userWorkouts;

  Future<void> _endWorkout() async {
    hasActiveWorkout.value = false;
    activeUserWorkoutId.value = '';
    activeWorkoutId.value = '';
    activeWorkoutName.value = '';
    activeWorkoutIndex = 0;
    await _userWorkoutsDao.localSetAllInactive();
    await _workoutDao.localSetAllInactive();

    String jsonString = jsonEncode(exerciseStats.map((key, value) =>
        MapEntry(key.toString(), value.map((set) => set.toJson()).toList())));

    DateTime endTime = DateTime.now();
    workoutDuration = endTime.difference(activeWorkoutStartTime);
    finalTime = workoutDuration.inMinutes;

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      _userWorkoutsDao.fireBaseUpdateUserWorkout(
          FirebaseAuth.instance.currentUser!.uid, workoutId,
          widget.userWorkouts?.date ?? DateTime.now(),
          jsonString, finalTime);
    } else {
      _userWorkoutsDao.localUpdate(UserWorkouts(
        userWorkoutId: '',
        userId: '',
        workoutId: workoutId,
        date: DateTime.now(),
        duration: finalTime.toDouble(),
        statistics: jsonString,
        isActive: false,
      ));
    }
  }

  @override
  void initState() {
    super.initState();

    fetchExercises();
    populateExerciseStats();

      workoutId = widget.userWorkouts!.workoutId;
  }

  void fetchExercises() {
    widget.exerciseMap.forEach((key, value) {
      exercises.add(key);
      workoutExercises.add(value);
    });
  }

  void populateExerciseStats() {
    if (exerciseStats.isEmpty) {
      widget.exerciseMap.forEach((key, value) {
        List<SetStats> stats = [];
        for (int i = 0; i < value.sets; i++) {
          stats.add(SetStats(set: i + 1, reps: value.reps, weight: 0));
        }
        exerciseStats[key] = stats;
      });
    }
  }

  void _showPicker(BuildContext context, Exercises exercise, int setIndex) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: AppColors.fitnessModuleColor,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Select Reps and Weight',
                style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor, fontSize: 18),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem:
                            exerciseStats[exercise]![setIndex].reps - 1),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            exerciseStats[exercise]![setIndex].reps = index + 1;
                          });
                        },
                        children: List<Widget>.generate(50, (int index) {
                          return Center(
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem:
                            exerciseStats[exercise]![setIndex].weight),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            exerciseStats[exercise]![setIndex].weight = index;
                          });
                        },
                        children: List<Widget>.generate(300, (int index) {
                          return Center(
                            child: Text(
                              (index).toString(),
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSet(Exercises exercise) {
    setState(() {
      int newSetNumber = exerciseStats[exercise]!.length + 1;
      exerciseStats[exercise]!
          .add(SetStats(set: newSetNumber, reps: 0, weight: 0));
    });
  }

  void _removeSet(Exercises exercise, int setIndex) {
    setState(() {
      exerciseStats[exercise]!.removeAt(setIndex);
    });
  }

  void _nextExercise() {
    setState(() {
      activeWorkoutIndex = (activeWorkoutIndex + 1) % exercises.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          DwProgressBar(value: (activeWorkoutIndex) / exercises.length),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color(0xFF262626), // Almost the same color
                  width: 1.0, // Very thin
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      BeepingCircle(),
                      const SizedBox(width: 10),
                      Text(
                        exercises[activeWorkoutIndex].name,
                        style: const TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 240,
                          ),
                          child: RawScrollbar(
                            thumbVisibility: true,
                            thickness: 4.0,
                            radius: Radius.circular(20.0),
                            thumbColor: AppColors.fitnessMainColor,
                            controller: _scrollController,
                            // Add this line
                            child: SingleChildScrollView(
                              controller: _scrollController, // Add this line
                              child: Column(
                                children: exerciseStats[
                                exercises[activeWorkoutIndex]]!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  SetStats stats = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '\u2022 Set ${stats.set}',
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .fitnessPrimaryTextColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                '${stats.reps} Reps',
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .fitnessPrimaryTextColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                '${stats.weight} Kg',
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .fitnessPrimaryTextColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if (index ==
                                                exerciseStats[exercises[
                                                activeWorkoutIndex]]!
                                                    .length -
                                                    1)
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    _removeSet(
                                                        exercises[
                                                        activeWorkoutIndex],
                                                        index),
                                                child: const Icon(
                                                  CupertinoIcons.minus_circle,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              )
                                            else
                                              const SizedBox(
                                                width: 40,
                                                height: 20,
                                              ),
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  _showPicker(
                                                      context,
                                                      exercises[activeWorkoutIndex],
                                                      index),
                                              child: const Icon(
                                                CupertinoIcons.pencil,
                                                color: AppColors
                                                    .fitnessPrimaryTextColor,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: CupertinoButton(
                      onPressed: () => _addSet(exercises[activeWorkoutIndex]),
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Add Set",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (activeWorkoutIndex < exercises.length - 1)
            Column(
              children: [
                const SizedBox(height: 20),
                IntrinsicHeight(
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: AppColors.fitnessModuleColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Color(0xFF262626),
                        width: 1.0, // Very thin
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Next Exercise',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 46),
                            Text(
                              exercises[activeWorkoutIndex + 1].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sets: ${workoutExercises[activeWorkoutIndex +
                                    1].sets}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Reps: ${workoutExercises[activeWorkoutIndex +
                                    1].reps}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  onPressed: _nextExercise,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Next Exercise",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 40),
          IntrinsicHeight(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color(0xFF262626),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoButton(
                    onPressed: () async {
                      await _endWorkout();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      width: 410,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFFCC4848),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "End Workout",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}