import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';

class UpcomingWorkouts extends StatelessWidget {
  const UpcomingWorkouts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Upcoming Workouts'),
        UpcomingWorkoutsBox(),
      ],
    );
  }
}
