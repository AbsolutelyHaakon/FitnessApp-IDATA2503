import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'workout_log.dart';

// Last edited: 25.11.2024
// Last edited by: Di Xie

class DetailedWorkoutLog extends StatelessWidget {
  final MapEntry<UserWorkouts, Workouts> workoutMapEntry;

  const DetailedWorkoutLog({
    Key? key,
    required this.workoutMapEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userWorkout = workoutMapEntry.key;
    final workout = workoutMapEntry.value;

    // Format the date to be displayed in the app bar
    String appBarTitle = DateFormat('dd MMMM yyyy').format(userWorkout.date);
    // Format the date to exclude the time part
    String formattedDate = DateFormat('dd.MM.yyyy').format(userWorkout.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle,
            style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${workout.name}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fitnessPrimaryTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: ${workout.category}',
              style: const TextStyle(
                  fontSize: 18, color: AppColors.fitnessSecondaryTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Date: $formattedDate',
              style: const TextStyle(
                  fontSize: 18, color: AppColors.fitnessSecondaryTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Duration: ${userWorkout.duration} minutes',
              style: const TextStyle(
                  fontSize: 18, color: AppColors.fitnessPrimaryTextColor),
            ),
            // Add more detailed information here
          ],
        ),
      ),
    );
  }
}