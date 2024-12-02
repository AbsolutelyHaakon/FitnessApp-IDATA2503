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
  final VoidCallback onRefresh;
  final bool workoutsIsEmpty;

  const HomePageCalendar(
      {super.key, required this.onRefresh, required this.workoutsIsEmpty});

  @override
  State<HomePageCalendar> createState() => _HomePageCalendarState();
}

class _HomePageCalendarState extends State<HomePageCalendar> {
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'localUser';
  List<UserWorkouts> _userWorkouts = [];
  final Map<UserWorkouts, Workouts> _workoutData = {};

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
      final workoutId = userWorkout.workoutId;
      final result = await _workoutDao.localFetchByWorkoutId(workoutId);
      if (result != null) {
        setState(() {
          _workoutData[userWorkout] = result;
        });
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
          MaterialPageRoute(builder: (context) => const WorkoutCalendar()),
        ).then((_) {
          getUserWorkouts();
          widget.onRefresh();
        });
      },
      child: Container(
        height: widget.workoutsIsEmpty ? 230 : 75,
        decoration: BoxDecoration(
          color: AppColors.fitnessModuleColor,
          borderRadius: BorderRadius.circular(30),
        ),
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
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
                  bool isToday = date.day == today.day &&
                      date.month == today.month &&
                      date.year == today.year;

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.fitnessPrimaryTextColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 4.0, right: 4.0, top: 2.0, bottom: 8.0),
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
                                  'assets/icons/${workout.category?.toLowerCase().replaceAll(' ', '')}Icon.svg',
                                  width: 24,
                                  height: 24,
                                )
                              : Icon(
                                  Icons.question_mark,
                                  color: isToday
                                      ? AppColors.fitnessPrimaryTextColor
                                      : AppColors.fitnessModuleColor,
                                  size: 24,
                                ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (widget.workoutsIsEmpty)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutCalendar(),
                      ),
                    ).then((_) {
                      getUserWorkouts();
                      widget.onRefresh();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 40.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'No workout scheduled for today. Schedule one now by pressing me, or just enjoy your rest day!',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
