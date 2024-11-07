import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/create_workout_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../database/crud/user_workouts_dao.dart';
import '../../database/crud/workout_dao.dart';
import '../../database/tables/workout.dart';

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
  Map<Workouts, DateTime> scheduledWorkoutsMap = {};
  List<Workouts> workouts = [];
  Map<Workouts, DateTime> workoutsMap = {};

  @override
  void initState() {
    super.initState();
    fetchScheduledWorkouts();
    if (scheduledWorkoutsMap.isEmpty) {
      fetchAllWorkouts();
    }

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

  void fetchScheduledWorkouts() async {
    final upcomingWorkouts =
    await UserWorkoutsDao().FetchUpcomingWorkouts(widget.user!.uid);
    setState(() {
      scheduledWorkoutsMap = upcomingWorkouts;
    });
  }

  void fetchAllWorkouts() async {
    workouts = await WorkoutDao().localFetchAllById(widget.user!.uid);
    for (var workout in workouts) {
      workoutsMap[workout] = DateTime(1970, 1, 1);
    }
  }

  @override
  void dispose() {
    _addIconController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
  if (!mounted) return;
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
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheduledWorkoutsMap.isNotEmpty
                            ? 'Scheduled Workouts'
                            : 'Workout',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 35.0,
                          color: Colors.white,
                        ),
                      ),
                      if (scheduledWorkoutsMap.isEmpty)
                        const Text(
                          'Select a workout to schedule',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: WorkoutsBox(
                      workoutMap: scheduledWorkoutsMap.isNotEmpty
                          ? scheduledWorkoutsMap
                          : workoutsMap,
                    ),
                  ),
                ),
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
                  heroTag: 'AddButton',
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: const CircleBorder(),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateWorkoutPage(user: widget.user),
                      ),
                    );
                    if (result == true) {
                      fetchScheduledWorkouts();
                    }
                    _toggleOptions();
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            Positioned(
              bottom: 140,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: FloatingActionButton(
                  heroTag: 'PresetButton',
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    // Redirect to another page (not created yet)
                    _toggleOptions();
                  },
                  child: const Icon(Icons.list),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: FloatingActionButton(
                  heroTag: 'datePicker',
                  backgroundColor: AppColors.fitnessMainColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      // Make the background transparent
                      isDismissible: true,
                      // Allow dismissing by tapping outside
                      enableDrag: true,
                      // Allow dismissing by dragging down
                      builder: (context) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: AppColors.fitnessBackgroundColor,
                            // Black semi-transparent background
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.6,
                            widthFactor: 1,
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                // Your content here
                                Text('Select a date',
                                    style: TextStyle(color: Colors.white)),
                                // Add more widgets as needed
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    _toggleOptions();
                  },
                  child: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      floatingActionButton: FloatingActionButton(
        heroTag: 'toggleOptions',
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