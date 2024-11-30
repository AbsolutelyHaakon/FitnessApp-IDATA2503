import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:fitnessapp_idata2503/pages/main_search_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/social_feed.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/during_workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitnessapp_idata2503/pages/home.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/me.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/globals.dart';

import '../database/crud/workout_dao.dart';
import '../database/crud/workout_exercises_dao.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0; // Index of the selected navigation item
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao(); // DAO for user workouts
  final WorkoutDao _workoutDao = WorkoutDao(); // DAO for workouts
  bool localHasActiveWorkout = false; // Flag to check if there's an active workout

  @override
  void initState() {
    super.initState();
    _checkForActiveWorkouts(); // Check for active workouts when the widget is initialized
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return; // If the tapped item is already selected, do nothing
    }
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  Future<void> _checkForActiveWorkouts() async {
    final temp = await _userWorkoutsDao.fetchActiveUserWorkout();
    if (temp != null) {
      hasActiveWorkout.value = true;
      activeUserWorkoutId.value = temp.userId;
      activeWorkoutId.value = temp.workoutId;
      activeWorkoutName.value = temp.name;
      setState(() {
        localHasActiveWorkout = true; // Set the flag to true if there's an active workout
      });
    } else {
      final temp2 = await _workoutDao.fetchActiveWorkout();
      if (temp2 != null) {
        hasActiveWorkout.value = true;
        activeWorkoutId.value = temp2.workoutId;
        activeWorkoutName.value = temp2.name;
        setState(() {
          localHasActiveWorkout = true; // Set the flag to true if there's an active workout
        });
      } else if (hasActiveWorkout.value) {
        setState(() {
          localHasActiveWorkout = true; // Set the flag to true if there's an active workout
        });
      } else {
        setState(() {
          localHasActiveWorkout = false; // Set the flag to false if there's no active workout
        });
      }
    }
  }

  Future<Map<Exercises, WorkoutExercises>> fetchExercises() async {
    try {
      Map<Exercises, WorkoutExercises> exerciseMap = {};
      List<Exercises> exercises = await WorkoutDao()
          .localFetchExercisesForWorkout(activeWorkoutId.value);
      for (final exercise in exercises) {
        final workoutExercise = await WorkoutExercisesDao()
            .localFetchById(activeWorkoutId.value, exercise.exerciseId);
        if (workoutExercise != null) {
          exerciseMap[exercise] = workoutExercise; // Add the exercise to the map
        }
      }
      return exerciseMap; // Return the map of exercises
    } catch (e) {
      print('Error fetching exercises: $e'); // Print an error message if fetching exercises fails
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 70), // Spacer
                Expanded(
                  child: _getSelectedPage(_selectedIndex), // Display the selected page
                ),
              ],
            ),
          ),
          if (hasActiveWorkout.value || localHasActiveWorkout)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  Map<Exercises, WorkoutExercises> exerciseMap =
                      await fetchExercises(); // Fetch the exercises

                  var userWorkout = await _userWorkoutsDao.localFetchById(
                      FirebaseAuth.instance.currentUser?.uid ?? '',
                      activeWorkoutId.value);

                  if (userWorkout == null) {
                    userWorkout = UserWorkouts(
                      userWorkoutId: '1',
                      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                      workoutId: activeWorkoutId.value,
                      date: DateTime.now(),
                      isActive: true,
                    );
                    await _userWorkoutsDao.localCreate(userWorkout); // Create a new user workout if it doesn't exist
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DuringWorkoutScreen(
                        userWorkouts: userWorkout!,
                        exerciseMap: exerciseMap,
                      ),
                    ),
                  ).then((result) {
                    _checkForActiveWorkouts(); // Check for active workouts after returning from the workout screen
                  });
                  ;
                },
                child: Container(
                  width: double.infinity,
                  height: 30,
                  color: AppColors.fitnessMainColor, // Background color
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Workout active: ${activeWorkoutName.value}', // Display the active workout name
                    style: const TextStyle(
                      color: AppColors.fitnessPrimaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.fitnessModuleColor, // Border color
              width: 1.0, // Border width
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0), // Padding
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.house_fill,
                  size: 25.0,
                  color: _selectedIndex == 0
                      ? AppColors.fitnessMainColor
                      : AppColors.fitnessSecondaryTextColor,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.news_solid,
                  size: 25.0,
                  color: _selectedIndex == 1
                      ? AppColors.fitnessMainColor
                      : AppColors.fitnessSecondaryTextColor,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/workout.svg',
                  width: 30.0,
                  height: 30.0,
                  color: _selectedIndex == 2
                      ? AppColors.fitnessMainColor
                      : AppColors.fitnessSecondaryTextColor,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.search,
                  size: 25.0,
                  color: _selectedIndex == 3
                      ? AppColors.fitnessMainColor
                      : AppColors.fitnessSecondaryTextColor,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.person_fill,
                  size: 25.0,
                  color: _selectedIndex == 4
                      ? AppColors.fitnessMainColor
                      : AppColors.fitnessSecondaryTextColor,
                ),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex, // Current selected index
            selectedItemColor: AppColors.fitnessMainColor, // Color of the selected item
            unselectedItemColor: AppColors.fitnessSecondaryTextColor, // Color of the unselected items
            backgroundColor: Colors.black, // Background color
            onTap: _onItemTapped, // Handle item tap
            iconSize: 20.0, // Icon size
            selectedFontSize: 12.0, // Font size of the selected item
            unselectedFontSize: 10.0, // Font size of the unselected items
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor, // Background color
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return const Home(); // Home page
      case 1:
        return const SocialFeed(); // Social feed page
      case 2:
        return const WorkoutPage(); // Workout page
      case 3:
        return MainSearchPage(); // Search page
      case 4:
        return FirebaseAuth.instance.currentUser?.uid != null
            ? ProfilePage(userId: FirebaseAuth.instance.currentUser!.uid) // Profile page
            : const Me(); // Me page
      default:
        return const Home(); // Default to home page
    }
  }
}