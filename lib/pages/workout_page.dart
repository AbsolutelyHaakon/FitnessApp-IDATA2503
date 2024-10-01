import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(height: 90),
        const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Workout',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 35.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: UpcomingWorkoutsList().listOfWorkouts.length,
              itemBuilder: (context, index) {
                final workout = UpcomingWorkoutsList().listOfWorkouts[index];
                return UpcomingWorkoutsBox(
                  title: workout.title,
                  category:
                      Type.values.firstWhere((e) => e.name == workout.category),
                  date: workout.date,
                  workouts: workout.workouts,
                );
              }),
        ),
      ]),
      backgroundColor: const Color(0xFF000000),
    );
  }
}
