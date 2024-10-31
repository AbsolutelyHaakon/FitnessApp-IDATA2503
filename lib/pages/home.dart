import 'package:fitnessapp_idata2503/modules/rings_module.dart';
import 'package:fitnessapp_idata2503/modules/wip_module.dart';
import 'package:fitnessapp_idata2503/modules/workout_log_module.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/upcoming_workouts_box.dart';
import '../modules/nutrition_module.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 90),
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Color(0xFF434343),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 35.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              UpcomingWorkoutsBox(
                title: 'First Workout!',
                category: Type.fullBody,
                date: DateTime.now(),
                workouts: [
                  // Add workouts here..
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NutritionModule(),
                    RingsModule(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WorkoutLogModule(),
                    WipModule()
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF000000),
    );
  }
}