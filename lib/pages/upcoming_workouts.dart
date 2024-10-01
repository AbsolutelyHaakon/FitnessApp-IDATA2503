import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:fitnessapp_idata2503/logic/workout.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';

class UpcomingWorkouts extends StatelessWidget {
  const UpcomingWorkouts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Upcoming Workouts'),
        ListView.builder(itemBuilder: (context, index) {
          final workout = UpcomingWorkoutsList().listOfWorkouts[index];
          return UpcomingWorkoutsBox(
            title: workout.title,
            category: Type.values.firstWhere((e) => e.name == workout.category),
            date: workout.date,
            workouts: workout.workouts,
          );
        }),
      ],
    );
  }
}
