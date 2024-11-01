import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class IndExerciseBox extends StatelessWidget {
  IndExerciseBox({
    super.key,
    required this.exerciseName,
    required this.exerciseReps,
    required this.exerciseSets,
  });

  final String exerciseName;
  final int exerciseReps;
  final int exerciseSets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.fitnessModuleColor,
        borderRadius: BorderRadius.circular(10), // Add rounded corners
      ),
      height: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(width: 15),
          Icon(
            Icons.menu,
            color: AppColors.fitnessPrimaryTextColor,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              exerciseName,
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
            ),
          ),
          SizedBox(width: 15),
          Text(
            '$exerciseReps Reps',
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
          ),
          SizedBox(width: 15),
          Text(
            '$exerciseSets Sets',
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
