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

class WorkoutLog extends StatefulWidget {
  final bool isCreatingPost;

  const WorkoutLog({super.key, required this.isCreatingPost});

  @override
  _WorkoutLogState createState() => _WorkoutLogState();
}

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
  List<Workouts> _workouts = [];
  List<UserWorkouts> _previousWorkouts = [];
  final WorkoutDao _workoutDao = WorkoutDao();
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();

  @override
  void initState() {
    super.initState();
    fetchPreviousWorkouts();
  }

  void fetchAllWorkouts(String category) async {
    List<Workouts> workoutsData = [];
    for (var userWorkout in _previousWorkouts) {
      Workouts? temp =
          await _workoutDao.localFetchByWorkoutId(userWorkout.workoutId);
      if (temp != null) {
        workoutsData.add(temp);
      }
    }

    setState(() {
      _workouts.clear();
      _workouts = workoutsData;
    });

    addWorkoutDetails();
  }

  Future<void> fetchPreviousWorkouts() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      final result = await _userWorkoutsDao.fireBaseFetchPreviousWorkouts(
          FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        _previousWorkouts = result['previousWorkouts'];
      });
      fetchAllWorkouts('All');
    }
  }

  void addWorkoutDetails() {
    _dummyWorkout.clear();
    for (var workout in _workouts) {
      DateTime prevWorkout = _previousWorkouts
          .where((value) => value.workoutId == workout.workoutId)
          .first
          .date;

      // Function to map workout category to the corresponding icon
      SvgPicture _getIconForCategory(String category) {
        int index = officialWorkoutCategories.indexOf(category);
        if (index != -1) {
          return officialFilterCategoryIcons[
              index + 2]; // +2 to skip 'All' and 'Starred'
        }
        return SvgPicture.asset('assets/icons/defaultIcon.svg',
            width: 40, height: 40);
      }

      // Adding a workout to _dummyWorkout with the correct icon
      _dummyWorkout.add({
        'title': workout.name,
        'subtitle': workout.description,
        'duration': workout.duration.toString(),
        'date': formatDate(prevWorkout),
        'icon': _getIconForCategory(workout.category!),
      });
    }
  }

  //For formatting the date to a string format dd/mm/yyyy
  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Dummy data for workouts
  final List<Map<String, dynamic>> _dummyWorkout = [
    {
      'title': 'Legs',
      'subtitle': 'Try to move challenge',
      'duration': '01:01:27',
      'date': '01.11.2024',
      'icon': Icon(Icons.assist_walker,
          color: AppColors.fitnessMainColor, size: 30),
    },
  ];

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
  List<Map<String, dynamic>> _filterWorkouts() {
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
        return _dummyWorkout; // Return all
    }
    // Filter the workouts based on the selected date range
    return _dummyWorkout.where((workout) {
      final DateTime workoutDate =
          DateFormat('dd.MM.yyyy').parse(workout['date']);
      return workoutDate.isAfter(startDate) &&
          workoutDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  List<Widget> _buildWorkoutSections() {
    final filteredWorkouts = _filterWorkouts();

    // Group workouts by month and year
    Map<String, List<Map<String, dynamic>>> workoutsByMonth = {};

    for (var workout in filteredWorkouts) {
      String date = workout['date'];
      String month = date.substring(3, 5);
      String year = date.substring(6, 10);

      String monthYearKey = "$year-$month";

      if (workoutsByMonth[monthYearKey] == null) {
        workoutsByMonth[monthYearKey] = [];
      }
      workoutsByMonth[monthYearKey]!.add(workout);
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
      for (var workout in workoutsByMonth[monthYearKey]!) {
        sections.add(_buildWorkoutLogEntry(
          context,
          title: workout['title'],
          subtitle: workout['subtitle'],
          duration: workout['duration'],
          date: workout['date'],
          icon: workout['icon'],
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

  Widget _buildWorkoutLogEntry(BuildContext context,
      {required String title,
      required String subtitle,
      required String duration,
      required String date,
      required Widget icon}) {
    return InkWell(
      // Box that likes touching.
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DetailedWorkoutLog(
            title: title,
            category: subtitle, // Subtitle? Category? :D
            date: DateFormat('dd.MM.yyyy').parse(date),
            duration: duration,
          ),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              // Workout Icon
              icon,
              const SizedBox(width: 16),
              // Workout Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Workout Duration & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    _isToday(date) ? 'Today' : date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
