// lib/pages/detailed_workout_log.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    // Format the date to exclude the time part
    String formattedDate = DateFormat('dd.MM.yyyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Workout Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Category: $category',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Date: $formattedDate',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Duration: $duration',
              style: TextStyle(fontSize: 18),
            ),
            // Add more detailed information here
          ],
        ),
      ),
    );
  }
}