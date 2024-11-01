import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/database/Initialization/initialize_upcoming_workouts.dart';
import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:flutter/material.dart';

UpcomingWorkoutsList workoutsList = UpcomingWorkoutsList();

class WorkoutPage extends StatefulWidget {
  final User? user;
  const WorkoutPage({super.key, this.user});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();

    getWorkoutData();
  }

  void getWorkoutData() async {
    List<UpcomingWorkoutsBox> workouts = await initializeWorkoutData(widget.user!.uid);
    workoutsList.insertList(workouts);
  }

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
              itemCount: workoutsList.listOfWorkouts.length,
              itemBuilder: (context, index) {
                final workout = workoutsList.listOfWorkouts[index];
                return UpcomingWorkoutsBox(
                  title: workout.title,
                  category: workout.category,
                  date: workout.date,
                );
              }),
        ),
      ]),
      backgroundColor: const Color(0xFF000000),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
