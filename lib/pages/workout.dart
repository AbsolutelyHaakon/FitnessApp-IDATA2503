import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/pages/upcoming_workouts.dart';
import 'package:flutter/material.dart';

class Workout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        backgroundColor: Color(0xFF292929),
      ),
      body: const SingleChildScrollView(
        child: Column(children: [
          Text(
            'Welcome to the Workout page!',
            style: TextStyle(color: Colors.white),
          ),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
        ]),
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}
