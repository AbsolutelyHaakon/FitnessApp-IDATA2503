import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'workout_log.dart';

// Last edited: 04.11.2024
// Last edited by: Di Xie

class DetailedWorkoutLog extends StatelessWidget {
  final String title;
  final String category;
  final DateTime date;
  final String duration;

  const DetailedWorkoutLog({
    Key? key,
    required this.title,
    required this.category,
    required this.date,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date to be displayed in the app bar
    String appBarTitle = DateFormat('dd MMMM yyyy').format(date);
    // Format the date to exclude the time part
    String formattedDate = DateFormat('dd.MM.yyyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: const TextStyle(
            color: AppColors.fitnessPrimaryTextColor)
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const WorkoutLog(), // Ensure WorkoutLog is the correct widget
            ));
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
              'Title: $title',
              style: const TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fitnessPrimaryTextColor),
            ),
            const SizedBox(
                height: 10
            ),
            Text(
              'Category/Type/IDFK XD: $category',
              style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.fitnessSecondaryTextColor),
            ),
            const SizedBox(
                height: 10
            ),
            Text(
              'Date: $formattedDate',
              style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.fitnessSecondaryTextColor),
            ),
            const SizedBox(
                height: 10
            ),
            Text(
              'Duration: $duration',
              style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.fitnessPrimaryTextColor),
            ),
            // Add more detailed information here
          ],
        ),
      ),
    );
  }
}