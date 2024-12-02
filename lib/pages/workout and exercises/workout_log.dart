import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/detailed_workout_log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

// Workout log page widget
class WorkoutLog extends StatefulWidget {
  final bool isCreatingPost;

  const WorkoutLog({super.key, required this.isCreatingPost});

  @override
  _WorkoutLogState createState() => _WorkoutLogState();
}

// Workout log page state.
class _WorkoutLogState extends State<WorkoutLog> {
  bool isAscending = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'Day',
    'Week',
    'Month',
    'Year',
    'All',
  ];
  final WorkoutDao _workoutDao = WorkoutDao();
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();

  final Map<UserWorkouts, Workouts> _workoutMap = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch the data from the database
  Future<void> fetchData() async {
    final result = await _userWorkoutsDao.localFetchPreviousUserWorkouts(
        FirebaseAuth.instance.currentUser?.uid ?? 'localUser');
    for (var userWorkout in result) {
      final statistics = userWorkout.statistics;
      if (statistics == null ||
          statistics.replaceAll('"', '').trim() == "null" ||
          statistics.isEmpty) {
        continue;
      }
      Workouts? temp =
          await _workoutDao.localFetchByWorkoutId(userWorkout.workoutId);
      if (temp != null) {
        setState(() {
          _workoutMap[userWorkout] = temp;
        });
      }
    }
  }

  //For formatting the date to a string format dd/mm/yyyy
  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Function to map month number to month name
  String _getMonthName(String monthNumber) {
    const List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    int monthIndex = int.parse(monthNumber) - 1;
    return monthNames[monthIndex];
  }

  // Function to confirm deletion of a workout
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion",
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          content: const Text(
              "Are you sure you want to delete this workout from the log?"),
          backgroundColor: AppColors.fitnessModuleColor,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: AppColors.fitnessWarningColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build the workout log page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Here is the back button, filter and sort button
      appBar: AppBar(
        backgroundColor: AppColors.fitnessBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Row(
            children: [
              DropdownButton<String>(
                dropdownColor: AppColors.fitnessSecondaryModuleColor,
                value: _selectedFilter,
                items: _filterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: Theme.of(context).textTheme.bodyMedium),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                    isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isAscending
                        ? AppColors.fitnessPrimaryTextColor
                        : AppColors.fitnessMainColor),
                onPressed: () {
                  setState(() {
                    isAscending = !isAscending; // Toggle sorting order
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Workout log',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            // Workout Log Section
            Container(
              color: AppColors.fitnessBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildWorkoutSections(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }

  // Filters the workout based on the selected filter
  Map<UserWorkouts, Workouts> _filterWorkouts() {
    final DateTime now = DateTime.now();
    DateTime startDate;

    // Case switch to determine the start date based on the selected filter
    switch (_selectedFilter) {
      case 'Day':
        startDate = now.subtract(const Duration(days: 1));
        break;
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      case 'All':
      default:
        return _workoutMap; // Return all
    }

    // Filter the workouts based on the selected date range
    return Map.fromEntries(
      _workoutMap.entries.where((entry) {
        final DateTime workoutDate = entry.key.date;
        return workoutDate.isAfter(startDate) &&
            workoutDate.isBefore(now.add(const Duration(days: 1)));
      }),
    );
  }

  List<Widget> _buildWorkoutSections() {
    final filteredWorkouts = _filterWorkouts();

    // Group workouts by month and year
    Map<String, List<MapEntry<UserWorkouts, Workouts>>> workoutsByMonth = {};

    for (var entry in filteredWorkouts.entries) {
      String date = entry.key.date.toString();
      String month = date.substring(5, 7); // Adjusted to get the correct month
      String year = date.substring(0, 4); // Adjusted to get the correct year

      String monthYearKey = "$year-$month";

      if (workoutsByMonth[monthYearKey] == null) {
        workoutsByMonth[monthYearKey] = [];
      }
      workoutsByMonth[monthYearKey]!.add(entry);
    }

    // Sort the "keys" (month-year) based on isAscending = true/false
    final sortedKeys = workoutsByMonth.keys.toList()
      ..sort((a, b) => isAscending ? a.compareTo(b) : b.compareTo(a));

    List<Widget> sections = [];
    for (var monthYearKey in sortedKeys) {
      // Split month and year
      String year = monthYearKey.split('-')[0];
      String monthNumber = monthYearKey.split('-')[1];
      String monthName = _getMonthName(monthNumber);

      sections.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          "$monthName $year",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ));

      // Sort workouts within the month-year group by date. Example: sort the date in a month group
      workoutsByMonth[monthYearKey]!.sort((a, b) {
        DateTime dateA = a.key.date;
        DateTime dateB = b.key.date;
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });

      for (var workoutMap in workoutsByMonth[monthYearKey]!) {
        sections.add(_buildWorkoutLogEntry(
          context,
          workoutMapEntry: workoutMap,
        ));
      }
    }

    return sections;
  }

  // Function to check if the date is today
  bool _isToday(String date) {
    final DateTime today = DateTime.now();
    final DateTime workoutDate = DateFormat('dd.MM.yyyy').parse(date);
    return today.year == workoutDate.year &&
        today.month == workoutDate.month &&
        today.day == workoutDate.day;
  }

  SvgPicture _getIconForCategory(String category) {
    int index = officialWorkoutCategories.indexOf(category);
    if (index != -1) {
      return officialFilterCategoryIcons[
          index + 2]; // +2 to skip 'All' and 'Starred'
    }
    return SvgPicture.asset('assets/icons/defaultIcon.svg',
        width: 40, height: 40);
  }

// Function to build the workout log entry
  Widget _buildWorkoutLogEntry(BuildContext context,
      {required MapEntry<UserWorkouts, Workouts> workoutMapEntry}) {
    final UserWorkouts userWorkout = workoutMapEntry.key;
    final Workouts workout = workoutMapEntry.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Dismissible(
        key: Key(userWorkout.userWorkoutId.toString()),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _confirmDelete(context),
        onDismissed: (direction) {
          setState(() {
            _workoutMap.remove(userWorkout);
            _userWorkoutsDao.fireBaseDeleteUserWorkout(userWorkout);
          });
        },
        background: Container(
          color: AppColors.fitnessWarningColor,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(
            Icons.delete,
            color: AppColors.fitnessPrimaryTextColor,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (widget.isCreatingPost) {
              Navigator.of(context).pop(userWorkout.userWorkoutId);
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailedWorkoutLog(
                  workoutMapEntry: workoutMapEntry,
                ),
              ));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.fitnessModuleColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _getIconForCategory(workout.category ?? ''),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        workout.description ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${userWorkout.duration?.toStringAsFixed(0)} min',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _isToday(formatDate(userWorkout.date))
                          ? 'Today'
                          : formatDate(userWorkout.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
