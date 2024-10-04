// lib/modules/nutrition_module.dart
import 'package:fitnessapp_idata2503/pages/pre_workout_screen.dart';
import 'package:fitnessapp_idata2503/pages/workout_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutLogModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const WorkoutLog(), //TODO: Change to workout log            )
            ),
          );
        },
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Add icon here later
            Icon(
                Icons.history,
                color: Color(0xFF48CC6D),
                size: 100,
              ),
              Text(
                'Workout log',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}