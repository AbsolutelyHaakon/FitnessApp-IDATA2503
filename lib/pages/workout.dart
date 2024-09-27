import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:flutter/material.dart';

class Workout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 90),
          Padding(
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
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
          UpcomingWorkoutsBox(),
        ]),
      ),
      backgroundColor: Color(0xFF000000),
    );
  }
}
