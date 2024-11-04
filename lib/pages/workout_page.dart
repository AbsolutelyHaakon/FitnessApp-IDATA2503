import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/upcoming_workouts_box.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/pages/create_workout_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../database/crud/user_workouts_dao.dart';
import '../database/tables/workout.dart';

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
  late Animation<double> _buttonAnimation;
  bool _showOptions = false;
  Map<Workouts, DateTime> workoutsList = {};

  @override
  void initState() {
    super.initState();
    fetchWorkouts();

    _addIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addIconAnimation =
        Tween<double>(begin: 0, end: 0.25).animate(_addIconController);
    _buttonAnimation = CurvedAnimation(
      parent: _addIconController,
      curve: Curves.easeInOut,
    );
  }

  void fetchWorkouts() async {
    final upcomingWorkouts = await UserWorkoutsDao().fetchUpcomingWorkouts(widget.user!.uid);
    setState(() {
      workoutsList = upcomingWorkouts;
    });
  }

  @override
  void dispose() {
    _addIconController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
    if (_addIconController.isCompleted) {
      _addIconController.reverse();
    } else {
      _addIconController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
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
                    itemCount: workoutsList.length,
                    itemBuilder: (context, index) {
                      final workout = workoutsList.keys.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: UpcomingWorkoutsBox(
                          workout: workoutsList,
                        ),
                      );
                    }),
              ),
            ],
          ),
          if (_showOptions) ...[
            Positioned(
              bottom: 200,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: FloatingActionButton(
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: const CircleBorder(),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateWorkoutPage(user: widget.user),
                      ),
                    );
                    if (result == true) {
                      fetchWorkouts();
                    }
                    _toggleOptions();
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ),
            Positioned(
              bottom: 140,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: FloatingActionButton(
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    // Redirect to another page (not created yet)
                    _toggleOptions();
                  },
                  child: Icon(Icons.list),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: FloatingActionButton(
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    // Open a popup menu to select a date
                    _toggleOptions();
                  },
                  child: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.fitnessMainColor,
        shape: const CircleBorder(),
        onPressed: _toggleOptions,
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