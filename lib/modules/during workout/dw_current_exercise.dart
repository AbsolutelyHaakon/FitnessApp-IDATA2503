import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/tables/exercise.dart';
import '../../database/tables/workout_exercises.dart';
import '../../styles.dart';

class SetStats {
  int set;
  int reps;
  int weight;

  SetStats({required this.set, required this.reps, required this.weight});
}

class DwCurrentExercise extends StatefulWidget {
  final Map<Exercises, WorkoutExercises> exerciseMap;

  const DwCurrentExercise({super.key, required this.exerciseMap});

  @override
  _DwCurrentExerciseState createState() => _DwCurrentExerciseState();
}

class _DwCurrentExerciseState extends State<DwCurrentExercise> {
  bool _isAddingSet = false;

  List<Exercises> exercises = [];
  List<WorkoutExercises> workoutExercises = [];

  int currentExerciseIndex = 0;
  int currentSetIndex = 0;

  Map<Exercises, List<SetStats>> exerciseStats = {};

  late FixedExtentScrollController repsController;
  late FixedExtentScrollController weightController;

  @override
  void initState() {
    super.initState();
    fetchExercises();
    populateExerciseStats();
    initializeScrollControllers();
  }

  void fetchExercises() {
    widget.exerciseMap.forEach((key, value) {
      exercises.add(key);
      workoutExercises.add(value);
    });
  }

  void populateExerciseStats() {
    widget.exerciseMap.forEach((key, value) {
      List<SetStats> stats = [];
      for (int i = 0; i < value.sets; i++) {
        stats.add(SetStats(set: i + 1, reps: value.reps, weight: 0));
      }
      exerciseStats[key] = stats;
    });
  }

  void initializeScrollControllers() {
    final currentStats = exerciseStats[exercises[currentExerciseIndex]]!;
    repsController = FixedExtentScrollController(initialItem: currentStats[currentSetIndex].reps);
    weightController = FixedExtentScrollController(initialItem: currentStats[currentSetIndex].weight ~/ 5);
  }

  void updateScrollControllers() {
    repsController.dispose();
    weightController.dispose();

    final currentStats = exerciseStats[exercises[currentExerciseIndex]]!;
    repsController = FixedExtentScrollController(initialItem: currentStats[currentSetIndex].reps);
    weightController = FixedExtentScrollController(initialItem: currentStats[currentSetIndex].weight ~/ 5);
  }

  void _incrementSet() {
    setState(() {
      if (currentSetIndex < workoutExercises[currentExerciseIndex].sets - 1) {
        currentSetIndex++;
        updateScrollControllers();
      }
    });
  }

  void _decrementSet() {
    setState(() {
      if (currentSetIndex > 0) {
        currentSetIndex--;
        updateScrollControllers();
      }
    });
  }

  @override
  void dispose() {
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
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
                  Stack(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.fitnessMainColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            exercises[currentExerciseIndex].name,
                            style: const TextStyle(
                              color: AppColors.fitnessPrimaryTextColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 10,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _isAddingSet = !_isAddingSet;
                            });
                          },
                          child: const Icon(
                            CupertinoIcons.pencil,
                            color: AppColors.fitnessPrimaryTextColor,
                            size: 20,
                          ),
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
                          'Sets: ${workoutExercises[currentExerciseIndex].sets}',
                          style: const TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Reps: ${workoutExercises[currentExerciseIndex].reps}',
                          style: const TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Set ${currentSetIndex + 1}:',
                          style: const TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _decrementSet,
                          child: Icon(
                            CupertinoIcons.left_chevron,
                            color: currentSetIndex == 0
                                ? AppColors.fitnessSecondaryTextColor
                                : AppColors.fitnessPrimaryTextColor,
                            size: 20,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _incrementSet,
                          child: Icon(
                            CupertinoIcons.right_chevron,
                            color: (currentSetIndex + 1) == workoutExercises[currentExerciseIndex].sets
                                ? AppColors.fitnessSecondaryTextColor
                                : AppColors.fitnessPrimaryTextColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
                    child: Row(
                      children: [
                        const Text(
                          'Reps:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40.0,
                            scrollController: repsController,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                exerciseStats[exercises[currentExerciseIndex]]![currentSetIndex].reps = index;
                              });
                            },
                            children: List<Widget>.generate(50, (int index) {
                              return Center(
                                child: Text(
                                  index.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Weight:',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40.0,
                            scrollController: weightController,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                exerciseStats[exercises[currentExerciseIndex]]![currentSetIndex].weight = index * 5;
                              });
                            },
                            children: List<Widget>.generate(50, (int index) {
                              return Center(
                                child: Text(
                                  (index * 5).toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        if (currentExerciseIndex < exercises.length - 1) {
                          currentExerciseIndex++;
                          currentSetIndex = 0;
                          updateScrollControllers();
                        }
                      });
                    },
                    child: Container(
                      width: 410,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFF48CC6D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Finish Exercise",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.black,
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
          const SizedBox(height: 10),
          if (currentExerciseIndex < exercises.length - 1)
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
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Next Exercise',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          exercises[currentExerciseIndex + 1].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sets   ${workoutExercises[currentExerciseIndex + 1].sets}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Reps  ${workoutExercises[currentExerciseIndex + 1].reps}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Weight: 0',
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
                      ],
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