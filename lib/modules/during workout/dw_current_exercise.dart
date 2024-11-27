import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/beeping_circle.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_progress-bar.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/create_post_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../database/tables/exercise.dart';
import '../../database/tables/workout_exercises.dart';
import '../../globals.dart';
import '../../styles.dart';

class DwCurrentExercise extends StatefulWidget {
  final Map<Exercises, WorkoutExercises> exerciseMap;
  final UserWorkouts userWorkouts;
  final VoidCallback onEndWorkout;

  const DwCurrentExercise({
    super.key,
    required this.exerciseMap,
    required this.userWorkouts,
    required this.onEndWorkout,
  });

  @override
  _DwCurrentExerciseState createState() => _DwCurrentExerciseState();
}

class _DwCurrentExerciseState extends State<DwCurrentExercise> {
  late ConfettiController _confettiController;
  List<Exercises> exercises = [];
  List<WorkoutExercises> workoutExercises = [];
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  final ScrollController _scrollController = ScrollController();
  Duration workoutDuration = Duration.zero;
  int finalTime = 0;
  int workoutProgressIndex = 0;
  bool exerciseEnded = false;

  @override
  void initState() {
    super.initState();
    fetchExercises();
    populateExerciseStats();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _endWorkoutWithConfetti() async {
    setState(() {
      exerciseEnded = true;
    });
    _confettiController.play();
    await _endWorkout();
    widget.onEndWorkout();
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
    workoutProgressIndex = activeWorkoutIndex;
  }

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
          widget.userWorkouts.userWorkoutId,
          FirebaseAuth.instance.currentUser!.uid,
          widget.userWorkouts.workoutId,
          widget.userWorkouts.date ?? DateTime.now(),
          jsonString,
          finalTime);
    } else {
      _userWorkoutsDao.localUpdate(UserWorkouts(
        userWorkoutId: '',
        userId: '',
        workoutId: widget.userWorkouts.workoutId,
        date: DateTime.now(),
        duration: finalTime.toDouble(),
        statistics: jsonString,
        isActive: false,
      ));
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
      workoutProgressIndex++;
    });
  }

  String getWorkoutDuration() {
    final duration = Duration(
      hours: workoutDuration.inHours,
      minutes: workoutDuration.inMinutes.remainder(60),
      seconds: workoutDuration.inSeconds.remainder(60),
    );

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty || exerciseStats.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (exerciseEnded) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DwProgressBar(
                      value: (workoutProgressIndex) / exercises.length),
                  const SizedBox(height: 100),
                  const Text(
                    'Workout Ended!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  Text('You worked out for: ${getWorkoutDuration()}'),
                  const SizedBox(height: 200),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        color: AppColors.fitnessModuleColor,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        color: AppColors.fitnessMainColor,
                        onPressed: () async {
                          final pushedUserWorkout =
                              await _userWorkoutsDao.localFetchByUserWorkoutsId(
                                  widget.userWorkouts.userWorkoutId);
                          print(pushedUserWorkout);
                          if (pushedUserWorkout != null) {
                            await Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => CreatePostPage(
                                    userWorkout: pushedUserWorkout),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          CupertinoIcons.share,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        children: [
          DwProgressBar(value: (workoutProgressIndex) / exercises.length),
          const SizedBox(height: 10),
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
                          constraints: BoxConstraints(maxHeight: 240),
                          child: RawScrollbar(
                            thumbVisibility: true,
                            thickness: 4.0,
                            radius: Radius.circular(20.0),
                            thumbColor: AppColors.fitnessMainColor,
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
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
                                                onPressed: () => _removeSet(
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
                                              onPressed: () => _showPicker(
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
                        width: 1.0,
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
                                'Sets: ${workoutExercises[activeWorkoutIndex + 1].sets}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Reps: ${workoutExercises[activeWorkoutIndex + 1].reps}',
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
                      workoutProgressIndex = exercises.length;
                      setState(() {
                        activeWorkoutIndex = 0;
                        exerciseEnded = true;
                      });
                      widget.onEndWorkout();
                      await _endWorkout();
                      _endWorkoutWithConfetti();
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
