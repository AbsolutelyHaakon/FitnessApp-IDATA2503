import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/globals.dart';

import '../../database/crud/workout_dao.dart';
import '../../database/tables/workout.dart';
import '../../styles.dart';

class DwEndWorkout extends StatefulWidget {
  final Workouts workout;

  DwEndWorkout({super.key, required this.workout});

  @override
  _DwEndWorkoutState createState() => _DwEndWorkoutState();
}

class _DwEndWorkoutState extends State<DwEndWorkout> {
  final WorkoutDao _workoutDao = WorkoutDao();

  Future<void> _endWorkout() async {
    hasActiveWorkout.value = false;
    activeWorkoutId.value = '';
    activeWorkoutName.value = '';
    activeWorkoutIndex = 0;
    await _workoutDao.localSetAllInactive();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
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