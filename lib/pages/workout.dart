import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/pages/upcoming_workouts.dart';
import 'package:flutter/material.dart';

class Workout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Heading1(text: 'Workout'),
        backgroundColor: const Color(0xFF000000),
      ),
      body: const SingleChildScrollView(
        child: Column(children: [
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
        ]),
      ),
      backgroundColor: const Color(0xFF000000),
    );
  }
}
