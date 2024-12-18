import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/homepage_calendar.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/rings_module.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_calendar.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/tables/workout.dart';
import 'social and account/me.dart';

// Home page widget
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

const double commonPadding = 16.0;
const double rowSpacing = 28.0;

// Home page widget. This is the main page of the app.
class _HomeState extends State<Home> {
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();

  List<Workouts> workouts = [];

  @override
  void initState() {
    super.initState();
    fetchNextWorkout();
  }

  Future<void> fetchNextWorkout() async {
    setState(() {
      workouts = [];
    });
    final result = await _userWorkoutsDao.localFetchTodaysWorkout();
    if (result != null) {
      final workout = await _workoutDao.localFetchByWorkoutId(result.workoutId);
      // Sadly we have to do all of these checks for statistics cause the JSON object can be either null, "null" or '"null'
      if (workout != null && result.statistics != null &&
          result.duration != null && result.statistics != "null" &&
          result.statistics != '"null') {
        setState(() {
          workouts = [workout];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Scaffold(
        backgroundColor: AppColors.fitnessBackgroundColor,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 40.0),
                child: Column(
                  children: [
                    // Custom App Bar
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  Text(
                                    'Home',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Today\'s workout',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineMedium),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.fitnessModuleColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          HomePageCalendar(onRefresh: fetchNextWorkout,
                              workoutsIsEmpty: workouts.isEmpty),
                          const SizedBox(height: 10),
                          if (workouts.isNotEmpty)
                            WorkoutsBox(
                              workouts: [...workouts],
                              isHome: true,
                              isSearch: false,
                              isToday: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const RingsModule(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}