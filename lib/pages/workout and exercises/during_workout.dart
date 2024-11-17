import 'dart:async';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/break_timer_module.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_current_exercise.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_end_workout.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_next_exercise.dart';
import 'package:fitnessapp_idata2503/modules/workout_plan_module.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/tables/workout.dart';
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

  Duration countdownDuration = Duration(minutes: 3);
  Duration remainingTime = Duration(minutes: 3);
  Timer? countdownTimer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _workoutDao.localSetAllInactive();
    _workoutDao.localUpdateActive(widget.workout, true);
    hasActiveWorkout.value = true;
  }

  void startTimer() {
    setState(() {
      isRunning = true;
    });
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= Duration(seconds: 1);
        } else {
          countdownTimer?.cancel();
          isRunning = false;
        }
      });
    });
  }

  void pauseTimer() {
    setState(() {
      isRunning = false;
    });
    countdownTimer?.cancel();
  }

  void resetTimer() {
    setState(() {
      remainingTime = countdownDuration;
      isRunning = false;
    });
    countdownTimer?.cancel();
  }

  void setCountdownDuration(Duration duration) {
    setState(() {
      countdownDuration = duration;
      remainingTime = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exerciseMap.isEmpty) {
      return Center(
        child: Text(
          'No exercises found for this workout.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

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
          if (remainingTime != countdownDuration)
            Center(
              child: Text(
                '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: Icon(CupertinoIcons.pencil, color: AppColors.fitnessSecondaryTextColor),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Container(
                    height: 250,
                    color: AppColors.fitnessBackgroundColor,
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle:
                              TextStyle(color: AppColors.fitnessPrimaryTextColor),
                        ),
                      ),
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        initialTimerDuration: countdownDuration,
                        onTimerDurationChanged: (Duration newDuration) {
                          setCountdownDuration(newDuration);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.restart, color: Colors.white),
            onPressed: resetTimer,
          ),
          IconButton(
            icon: Icon(isRunning ? CupertinoIcons.pause : CupertinoIcons.timer,
                color: Colors.white),
            onPressed: isRunning ? pauseTimer : startTimer,
          ),
        ],
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
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                DwCurrentExercise(exerciseMap: widget.exerciseMap),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                DwEndWorkout(workout: widget.workout),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
