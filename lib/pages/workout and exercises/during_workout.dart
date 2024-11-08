import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/break_timer_module.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_current_exercise.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_end_workout.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_next_exercise.dart';
import 'package:fitnessapp_idata2503/modules/workout_plan_module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/tables/workout.dart';
import '../../modules/during workout/dw_progress-bar.dart';
import '../../styles.dart';

class DuringWorkoutScreen extends StatefulWidget {
  final Workouts workout;
  final Map<Exercises, WorkoutExercises> exerciseMap;

  const DuringWorkoutScreen(
      {super.key, required this.workout, required this.exerciseMap});

  @override
  State<DuringWorkoutScreen> createState() {
    return _DuringWorkoutScreenState();
  }
}

class _DuringWorkoutScreenState extends State<DuringWorkoutScreen> {
  double totalExercises = 0;
  double currentExercise = 0;

  final WorkoutDao _workoutDao = WorkoutDao();

  @override
  void initState() {
    super.initState();
    _workoutDao.localUpdateActive(widget.workout, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: const Color(0xFF000000),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF48CC6D)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workout Progress',
                      style: TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          // Rounded corners
                          child: LinearProgressIndicator(
                            value: totalExercises == 0
                                ? 0
                                : currentExercise / totalExercises,
                            backgroundColor:
                                AppColors.fitnessSecondaryModuleColor,
                            // Dark grey background
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.fitnessMainColor),
                            // Green color
                            minHeight: 30, // Thicker progress bar
                          ),
                        ),
                        Positioned.fill(
                            left: 10,
                            top: 5,
                            child: Text(
                              textAlign: TextAlign.left,
                              '${(totalExercises == 0 ? 0 : (currentExercise / totalExercises * 100)).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
                DwCurrentExercise(exerciseMap: widget.exerciseMap),
                const SizedBox(height: 20),
                const BreakTimerModule(),
                const SizedBox(height: 20),
                const DwEndWorkout(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF000000),
    );
  }
}
