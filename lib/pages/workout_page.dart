import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ffi';

import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/database/Initialization/initialize_upcoming_workouts.dart';
import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:fitnessapp_idata2503/pages/create_workout_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

UpcomingWorkoutsList workoutsList = UpcomingWorkoutsList();

class WorkoutPage extends StatefulWidget {
  final User? user;
  const WorkoutPage({super.key, this.user});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _addIconController;
  late Animation<double> _addIconAnimation;

  @override
  void initState() {
    super.initState();

    getWorkoutData();
    _addIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addIconAnimation =
        Tween<double>(begin: 0, end: 0.25).animate(_addIconController);
  }

  @override
  void dispose() {
    _addIconController.dispose();
    super.dispose();
  }

  void getWorkoutData() async {
    List<UpcomingWorkoutsBox> workouts =
        await initializeWorkoutData(widget.user!.uid);
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
      backgroundColor: AppColors.fitnessBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.fitnessMainColor,
        shape: CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateWorkoutPage(user: widget.user),
            ),
          );
          if (result == true) {
            print("success adrian"); // Reload exercises if a new exercise was created
          }
          if (_addIconController.isCompleted) {
            _addIconController.reverse();
          } else {
            _addIconController.forward();
          }
        },
        child: AnimatedBuilder(
          animation: _addIconAnimation,
          child: Icon(Icons.add),
          builder: (context, child) {
            return Transform.rotate(
              angle: _addIconAnimation.value * 3.14159,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
