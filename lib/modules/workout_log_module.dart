// lib/modules/community_module.dart
import 'package:fitnessapp_idata2503/pages/pre_workout_screen.dart';
import 'package:fitnessapp_idata2503/pages/workout_log.dart';
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
              builder: (context) => const WorkoutLog(), //TODO: Change to workout log            )
            ),
          );
        },
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFF262626), // Almost the same color
              width: 1.0, // Very thin
            ),
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