import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/community_module.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/searchUsers.dart';
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
import '../database/tables/workout.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  bool localHasActiveWorkout = false;

  @override
  void initState() {
    super.initState();
    _checkForActiveWorkouts();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
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
        localHasActiveWorkout = true;
      });
    } else {
      final temp2 = await _workoutDao.fetchActiveWorkout();
      if (temp2 != null) {
        hasActiveWorkout.value = true;
        activeWorkoutId.value = temp2.workoutId;
        activeWorkoutName.value = temp2.name;
        setState(() {
          localHasActiveWorkout = true;
        });
      } else if (hasActiveWorkout.value) {
        setState(() {
          localHasActiveWorkout = true;
        });
      } else {
        setState(() {
          localHasActiveWorkout = false;
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
          exerciseMap[exercise] = workoutExercise;
        }
      }
      return exerciseMap;
    } catch (e) {
      print('Error fetching exercises: $e');
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
                const SizedBox(height: 70),
                Expanded(
                  child: _getSelectedPage(_selectedIndex),
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
                      await fetchExercises();

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
                    await _userWorkoutsDao.localCreate(userWorkout);
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
                    _checkForActiveWorkouts();
                  });
                  ;
                },
                child: Container(
                  width: double.infinity,
                  height: 30,
                  color: AppColors.fitnessMainColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Workout active: ${activeWorkoutName.value}',
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
              color: AppColors.fitnessModuleColor, // Adjust the color as needed
              width: 1.0, // Adjust the width as needed
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          // Adjust the value as needed
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
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.fitnessMainColor,
            unselectedItemColor: AppColors.fitnessSecondaryTextColor,
            backgroundColor: Colors.black,
            onTap: _onItemTapped,
            iconSize: 20.0,
            selectedFontSize: 12.0,
            unselectedFontSize: 10.0,
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return const Home();
      case 1:
        return const SocialFeed();
      case 2:
        return const WorkoutPage();
      case 3:
        return const SearchUsers();
      case 4:
        return const Me();
      default:
        return const Home();
    }
  }
}
