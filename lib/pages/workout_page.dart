import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:flutter/material.dart';

UpcomingWorkoutsList workoutsList = UpcomingWorkoutsList();

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();

    initializeWorkoutData();
  }

  void initializeWorkoutData() {
    // Add a workout to the list
    workoutsList.insertList([
      UpcomingWorkoutsBox(
        title: 'Fart Workout',
        category: Type.back,
        date: DateTime.now(),
        workouts: [],
      ),
      UpcomingWorkoutsBox(
          title: 'Head Workout',
          category: Type.fullBody,
          date: DateTime.now(),
          workouts: [],),
      UpcomingWorkoutsBox(
        title: 'Throat Workout',
        category: Type.chest,
        date: DateTime.now(),
        workouts: [],
      ),
      UpcomingWorkoutsBox(
        title: 'Skibidi Workout',
        category: Type.legs,
        date: DateTime.now(),
        workouts: [],
      )
    ]);
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
                  workouts: workout.workouts,
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
