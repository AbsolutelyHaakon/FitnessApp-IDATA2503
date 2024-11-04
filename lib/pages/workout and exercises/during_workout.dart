import 'package:fitnessapp_idata2503/modules/during%20workout/break_timer_module.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_current_exercise.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_end_workout.dart';
import 'package:fitnessapp_idata2503/modules/during%20workout/dw_next_exercise.dart';
import 'package:fitnessapp_idata2503/modules/workout_plan_module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../modules/during workout/dw_progress-bar.dart';

class DuringWorkoutScreen extends StatefulWidget {
  const DuringWorkoutScreen({super.key});

  @override
  State<DuringWorkoutScreen> createState() {
    return _DuringWorkoutScreenState();
  }
}

class _DuringWorkoutScreenState extends State<DuringWorkoutScreen> {
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
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'My Workout Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
              ),
              DwProgressBar(),
              const DwCurrentExercise(),
              const SizedBox(height: 20),
              const DwNextExercise(),
              const SizedBox(height: 20),
              const BreakTimerModule(),
              const SizedBox(height: 20),
              const DwEndWorkout(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF000000),
    );
  }
}