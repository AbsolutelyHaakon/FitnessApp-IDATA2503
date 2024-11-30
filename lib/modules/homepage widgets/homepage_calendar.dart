import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_calendar.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';

class HomePageCalendar extends StatefulWidget {
  const HomePageCalendar({super.key});

  @override
  State<HomePageCalendar> createState() => _HomePageCalendarState();
}

class _HomePageCalendarState extends State<HomePageCalendar> {
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'localUser';
  List<UserWorkouts> _userWorkouts = [];
  Map<UserWorkouts, Workouts> _workoutData = {};

  @override
  void initState() {
    super.initState();
    getUserWorkouts();
  }

  Future<void> getUserWorkouts() async {
    final result =
        await _userWorkoutsDao.localFetchThisWeeksUserWorkouts(userId);
    setState(() {
      _userWorkouts = result;
    });

    if (_userWorkouts.isNotEmpty) {
      await getWorkoutData();
    }
  }

  Future<void> getWorkoutData() async {
    for (final userWorkout in _userWorkouts) {
      if (userWorkout != null) {
        final workoutId = userWorkout.workoutId;
        final result = await _workoutDao.localFetchByWorkoutId(workoutId);
        if (result != null) {
          setState(() {
            _workoutData[userWorkout] = result;
          });
        }
      }
    }
  }

  String getDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    List<DateTime> currentWeek =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutCalendar()),
        );
      },
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: AppColors.fitnessSecondaryModuleColor,
          borderRadius: BorderRadius.circular(15),
        ),
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: currentWeek.map((date) {
              UserWorkouts? userWorkout = _userWorkouts.firstWhere(
                (userWorkout) =>
                    userWorkout.date.year == date.year &&
                    userWorkout.date.month == date.month &&
                    userWorkout.date.day == date.day,
                orElse: () => UserWorkouts(
                    date: DateTime(1970, 1, 1),
                    userWorkoutId: '3',
                    userId: '2',
                    workoutId: '1',
                    isActive: false), // Default value
              );

              Workouts? workout = userWorkout.date != DateTime(1970, 1, 1)
                  ? _workoutData[userWorkout]
                  : null;

              print(workout?.name);
              print(workout?.category);

              bool isToday = date.day == today.day &&
                  date.month == today.month &&
                  date.year == today.year;

              return Container(
                decoration: BoxDecoration(
                  color:
                      isToday ? AppColors.fitnessPrimaryTextColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getDayName(date),
                          style: TextStyle(
                            color: isToday
                                ? AppColors.fitnessBackgroundColor
                                : AppColors.fitnessPrimaryTextColor,
                            fontSize: 12,
                          )),
                      workout != null
                          ? SvgPicture.asset(
                              'assets/icons/${workout.category?.toLowerCase()}Icon.svg',
                              width: 24,
                              height: 24,
                            )
                          : Icon(
                              Icons.question_mark,
                              color: isToday
                                  ? AppColors.fitnessPrimaryTextColor
                                  : AppColors.fitnessSecondaryModuleColor,
                              size: 20,
                            ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
