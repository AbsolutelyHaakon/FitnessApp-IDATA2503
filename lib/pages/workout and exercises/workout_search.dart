import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class SearchWorkouts extends StatefulWidget {
  const SearchWorkouts({super.key});

  @override
  State<SearchWorkouts> createState() => _SearchWorkoutsState();
}

class _SearchWorkoutsState extends State<SearchWorkouts> {
  final WorkoutDao _workoutDao = WorkoutDao();
  List<Workouts> _allWorkouts = [];
  List<Workouts> _filteredWorkouts = [];
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getWorkouts(); // Fetch workouts when the widget is initialized
  }

  // Fetch workouts from the database
  Future<void> getWorkouts() async {
    try {
      final fetchedWorkouts = await _workoutDao.fireBaseFetchPublicWorkouts();
      setState(() {
        _allWorkouts = fetchedWorkouts["workouts"]
                ?.where((user) =>
                    user.userId != FirebaseAuth.instance.currentUser?.uid)
                .toList() ??
            [];
        _filteredWorkouts = _allWorkouts;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // Filter workouts based on the search query
  void _filterUsers(String query) {
    setState(() {
      _filteredWorkouts = _allWorkouts
          .where((workout) =>
              workout.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          color: AppColors.fitnessBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search workouts...',
                    border: OutlineInputBorder(),
                    enabledBorder: InputBorder.none,
                    prefixIcon:
                        Icon(Icons.search, color: AppColors.fitnessMainColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  style: const TextStyle(
                      color: AppColors.fitnessPrimaryTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
                  onChanged: _filterUsers, // Filter workouts as the user types
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: WorkoutsBox(
                    workouts: _filteredWorkouts, // Display filtered workouts
                    isHome: false,
                    isSearch: true,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
