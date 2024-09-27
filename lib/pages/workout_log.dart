import 'package:fitnessapp_idata2503/modules/workout_plan_module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutLog extends StatefulWidget {
  const WorkoutLog({super.key});

  @override
  State<WorkoutLog> createState() {
    return _WorkoutLogState();
  }
}

class _WorkoutLogState extends State<WorkoutLog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: Color(0xFF292929),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Color(0xFF48CC6D)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Workout log',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Hike',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            WorkoutPlanModule(),
            SizedBox(height: 10),
          ],
        ),
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}