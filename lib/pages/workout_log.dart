import 'package:fitnessapp_idata2503/pages/account_setup.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutLog extends StatefulWidget {
  const WorkoutLog({super.key});

  @override
  State<WorkoutLog> createState() {
    return _WorkoutLogState();
  }
}

class _WorkoutLogState extends State<WorkoutLog> {

  bool isAscending = false; //isDescending = true :D
  String _selectedFilter = '7d'; // Set default filter to 7days
  final List<String> _filterOptions = ['24hrs','7d', '30d', '365d', 'All',];

  final List<Map<String, dynamic>> _workouts = [
    {
      'title': 'Legs',
      'subtitle': 'Try to move challenge',
      'duration': '01:01:27',
      'date': '18.09.2024',
      'icon': Icons.assist_walker,
    },
    {
      'title': 'Hike',
      'subtitle': '0.10 km',
      'duration': '00:30:20',
      'date': '17.09.2024',
      'icon': Icons.hiking,
    },
    {
      'title': 'Arms & Chest',
      'subtitle': 'Push',
      'duration': '01:39:41',
      'date': '30.08.2024',
      'icon': Icons.fitness_center,
    },
    {
      'title': 'Arms',
      'subtitle': 'Pull',
      'duration': '01:00:00',
      'date': '15.07.2024',
      'icon': Icons.personal_injury,
    },
    {
      'title': 'Arms',
      'subtitle': 'Pull',
      'duration': '01:00:00',
      'date': '15.06.2024',
      'icon': Icons.personal_injury,
    },
    {
      'title': 'Arms',
      'subtitle': 'Pull',
      'duration': '01:00:00',
      'date': '15.07.2023',
      'icon': Icons.personal_injury,
    },
    {
      'title': 'Arms',
      'subtitle': 'Pull',
      'duration': '01:00:00',
      'date': '15.08.1999',
      'icon': Icons.personal_injury,
    },
    {
      'title': 'Arms',
      'subtitle': 'Pull',
      'duration': '01:00:00',
      'date': '15.08.1964',
      'icon': Icons.personal_injury,
    },
    {
      'title': 'Arms',
      'subtitle': 'Pull',
      'duration': '01:00:00',
      'date': '15.08.2002',
      'icon': Icons.personal_injury,
    },
  ];

  // Function to map month number to month name
  String _getMonthName(String monthNumber) {
    const List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    int monthIndex = int.parse(monthNumber) - 1;
    return monthNames[monthIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.fitnessBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
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
                    child: Text(value, style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                    //_filterWorkouts(); //TODO: Implement a function that displays the workout within the selected date range.
                  });
                },
              ),
              IconButton(
                icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: isAscending ? AppColors.fitnessPrimaryTextColor : AppColors.fitnessMainColor),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Workout log',
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
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

  List<Widget> _buildWorkoutSections() {
    // Group workouts by month and year
    Map<String, List<Map<String, dynamic>>> workoutsByMonth = {};

    for (var workout in _workouts) {
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
          style: const TextStyle(
            color: AppColors.fitnessPrimaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
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

  Widget _buildWorkoutLogEntry(BuildContext context,
      {required String title,
        required String subtitle,
        required String duration,
        required String date,
        required IconData icon}) {
    return InkWell(
      onTap: () {
        //Temporary using AccountSetupPage
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const AccountSetupPage(), // Replace this with the new detailed workout log page later.
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
              Icon(icon, color: AppColors.fitnessMainColor, size: 30),
              const SizedBox(width: 16),
              // Workout info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.fitnessPrimaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
                    style: const TextStyle(
                      color: AppColors.fitnessPrimaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.fitnessSecondaryTextColor,
                      fontSize: 10,
                    ),
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
