import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/create_post_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailedWorkoutLog extends StatelessWidget {
  final MapEntry<UserWorkouts, Workouts> workoutMapEntry;

  const DetailedWorkoutLog({
    super.key,
    required this.workoutMapEntry,
  });

  @override
  Widget build(BuildContext context) {
    final userWorkout = workoutMapEntry.key;
    final workout = workoutMapEntry.value;

    // Format the date to be displayed in the app bar
    DateFormat('dd MMMM yyyy').format(userWorkout.date);
    // Format the date to exclude the time part
    String formattedDate = DateFormat('dd.MM.yyyy').format(userWorkout.date);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.fitnessBackgroundColor,
        title: Text(
          workout.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.fitnessPrimaryTextColor,
              ),
        ),
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
          if (workoutMapEntry.key.userId == FirebaseAuth.instance.currentUser?.uid)
          TextButton(
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostPage(
                    userWorkout: workoutMapEntry.key,
                  ),
                ),
              );
            },
            child: const Text('Share Workout',
                style: TextStyle(color: AppColors.fitnessMainColor)),
          ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Workout Details'),
            const SizedBox(height: 10),
            _buildCard(
              children: [
                _buildInfoRow('Title', workout.name),
                const Divider(),
                _buildInfoRow('Category', workout.category ?? 'Unknown'),
                const Divider(),
                _buildInfoRow('Date', formattedDate),
                const Divider(),
                _buildInfoRow('Duration',
                    '${userWorkout.duration?.toStringAsFixed(0)} minutes'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Function to build the section title
  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.fitnessMainColor,
        ),
      ),
    );
  }

  // Function to build a card with the given children widgets
  Widget _buildCard({required List<Widget> children}) {
    return Card(
      color: AppColors.fitnessBackgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // Function to build a row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.fitnessSecondaryTextColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.fitnessPrimaryTextColor,
          ),
        ),
      ],
    );
  }
}
