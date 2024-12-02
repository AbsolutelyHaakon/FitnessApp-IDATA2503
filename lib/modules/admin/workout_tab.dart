import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/create_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

import '../../database/crud/workout_dao.dart';

/// This class represents the Workout Tab in the admin panel.
/// It allows the admin to view and manage workouts.
class WorkoutTab extends StatefulWidget {
  const WorkoutTab({super.key});

  @override
  _WorkoutTabState createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  // Boolean to toggle between workout and exercise view
  bool _isExerciseView = false;
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  // List to store fetched workouts
  List<Workouts> workouts = [];

  @override
  void initState() {
    super.initState();
    // Fetch public workouts when the widget is initialized
    _fetchPublicWorkouts();
  }

  // Method to fetch public workouts from the database
  void _fetchPublicWorkouts() async {
    workouts.clear();
    final temp = await WorkoutDao().fireBaseFetchPublicWorkouts();
    if (!mounted) return;
    setState(() {
      workouts = temp["workouts"] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search text field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SizedBox(
            height: 70,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: const TextStyle(
                    color: AppColors.fitnessSecondaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide:
                      const BorderSide(color: AppColors.fitnessMainColor),
                ),
              ),
              onChanged: (value) {
                // Implement search functionality here
              },
            ),
          ),
        ),
        // Button to create a new preset workout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateWorkoutPage(
                        isAdmin: true,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchPublicWorkouts();
                  }
                },
                child: const Text(
                  '+ Create Preset Workout',
                  style: TextStyle(
                    color: AppColors.fitnessMainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Display workouts or exercises based on the toggle
        if (!_isExerciseView)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Premade Workouts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    WorkoutsBox(
                      workouts: workouts
                          .where((workout) => workout.userId == '')
                          .toList(),
                      isHome: false,
                      isSearch: false,
                    ),
                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Public Workouts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    WorkoutsBox(
                      workouts: workouts
                          .where((workout) => workout.userId != '')
                          .toList(),
                      isHome: false,
                      isSearch: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
