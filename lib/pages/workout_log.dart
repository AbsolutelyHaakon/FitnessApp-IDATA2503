import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutLog extends StatefulWidget {
  const WorkoutLog({super.key});

  @override
  State<WorkoutLog> createState() {
    return _WorkoutLogState();
  }
}

class _WorkoutLogState extends State<WorkoutLog> {
  final List<Map<String, dynamic>> _workouts = [
    {
      'title': 'Legs',
      'subtitle': 'Legday pls help',
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
        backgroundColor: const Color(0xFF292929),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF48CC6D)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
            // Workout Log Section
            Container(
              color: const Color(0xFF292929),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildWorkoutSections(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF292929),
    );
  }

  List<Widget> _buildWorkoutSections() {
    // Group workouts by month and year
    Map<String, List<Map<String, dynamic>>> workoutsByMonth = {};

    for (var workout in _workouts) {
      String date = workout['date'];
      String month = date.substring(3, 5);
      String year = date.substring(6, 10);

      String monthYearKey = "$month $year";

      if (workoutsByMonth[monthYearKey] == null) {
        workoutsByMonth[monthYearKey] = [];
      }
      workoutsByMonth[monthYearKey]!.add(workout);
    }

    List<Widget> sections = [];
    workoutsByMonth.forEach((monthYearKey, workouts) {
      // Split month and year
      String monthNumber = monthYearKey.split(' ')[0];
      String monthName = _getMonthName(monthNumber);
      String year = monthYearKey.split(' ')[1];

      sections.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          "$monthName $year",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ));
      for (var workout in workouts) {
        sections.add(_buildWorkoutLogEntry(
          context,
          title: workout['title'],
          subtitle: workout['subtitle'],
          duration: workout['duration'],
          date: workout['date'],
          icon: workout['icon'],
        ));
      }
    });

    return sections;
  }

  Widget _buildWorkoutLogEntry(BuildContext context,
      {required String title,
        required String subtitle,
        required String duration,
        required String date,
        required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Workout Icon
            Icon(icon, color: const Color(0xFF48CC6D), size: 50), // Adjusted size
            const SizedBox(width: 16),
            // Workout info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
