// lib/modules/community_module.dart
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/pre_workout_screen.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_calendar.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_log.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Module for displaying the nutrition module
// Used to display the user's nutrition information

// Last edited: 31/10/2024
// Last edited by: Håkon Svensen Karlsen
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
              builder: (context) => const WorkoutLog(isCreatingPost: false,),
            ),
          );
        },
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(30),

          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Add icon here later
            Icon(
                Icons.history_rounded,
                color: AppColors.fitnessMainColor,
                size: 100,
              ),
              Text(
                'Workout log',
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontWeight: FontWeight.w500,
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