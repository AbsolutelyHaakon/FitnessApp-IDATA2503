import 'dart:async';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/break_timer_module.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_current_exercise.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_end_workout.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_next_exercise.dart';
import 'package:fitnessapp_idata2503/modules/workout_plan_module.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../database/tables/workout.dart';
import '../../styles.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class DuringWorkoutScreen extends StatefulWidget {
  final UserWorkouts? userWorkouts;
  final Workouts? workouts;
  final Map<Exercises, WorkoutExercises> exerciseMap;

  const DuringWorkoutScreen(
      {super.key, this.userWorkouts, required this.exerciseMap, this.workouts});

  @override
  State<DuringWorkoutScreen> createState() {
    return _DuringWorkoutScreenState();
  }
}

class _DuringWorkoutScreenState extends State<DuringWorkoutScreen> with WidgetsBindingObserver {
  double totalExercises = 0;
  double currentExercise = 0;

  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  Workouts workouts = const Workouts(
    workoutId: '0',
    name: 'Workout 1',
    description: 'Description 1',
    duration: 30,
    isPrivate: false,
    userId: '1',
  );

  Duration countdownDuration = Duration(minutes: 3);
  Duration remainingTime = Duration(minutes: 3);
  Timer? countdownTimer;
  bool isRunning = false;
  bool isInBackground = false;


  @override
  void initState() {
    super.initState();
    if (widget.userWorkouts != null) {
      _getWorkoutData();
    } else if (widget.workouts != null) {
      WidgetsBinding.instance.addObserver(this);
      _userWorkoutsDao.localSetAllInactive();
      _workoutDao.localUpdateActive(widget.workouts!, true);
      if (!hasActiveWorkout.value) {
        activeWorkoutStartTime = DateTime.now();
      }
      print("Active workout found");
      hasActiveWorkout.value = true;
      activeWorkoutId.value = workouts.workoutId;
      activeWorkoutName.value = workouts.name;
      workouts = widget.workouts!;
    }
    totalExercises = widget.exerciseMap.length.toDouble();
  }

  _getWorkoutData() async {
    workouts = await _workoutDao.localFetchByWorkoutId(widget.userWorkouts!.workoutId);
    if (workouts.workoutId != '0'){
      WidgetsBinding.instance.addObserver(this);
      _userWorkoutsDao.localSetAllInactive();
      _workoutDao.localUpdateActive(widget.workouts!, true);
      if (!hasActiveWorkout.value) {
        activeWorkoutStartTime = DateTime.now();
      }
      hasActiveWorkout.value = true;
      activeUserWorkoutId.value = widget.userWorkouts!.userWorkoutId;
      activeWorkoutId.value = workouts.workoutId;
      activeWorkoutName.value = workouts.name;
    }
    // TODO: MAYBE ADD A CHECK HERE OR SOME ERROR HANDLING ON THE FRONTEND SIDE
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      isInBackground = true;
    } else if (state == AppLifecycleState.resumed) {
      isInBackground = false;
    }
  }

  Future<void> _scheduleNotification() async {
    if (isInBackground) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'fitnessapp_idata2503', // id
        'Fitness App', // title
        channelDescription: 'Notification channel for the Fitness App',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Break Time',
        'Your break time is over!',
        platformChannelSpecifics,
        payload: 'item x',
      );
    }
  }



  void startTimer() {
    setState(() {
      isRunning = true;
    });
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          if (remainingTime.inSeconds > 0) {
            remainingTime -= const Duration(seconds: 1);
          } else {
            countdownTimer?.cancel();
            isRunning = false;
            _scheduleNotification();
          }
        });
      }
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
            icon: Icon(CupertinoIcons.pencil, color: AppColors.fitnessPrimaryTextColor),
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
                  workouts.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                DwCurrentExercise(exerciseMap: widget.exerciseMap, userWorkouts: widget.userWorkouts, workouts: workouts),
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