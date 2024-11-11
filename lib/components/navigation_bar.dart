import 'package:fitnessapp_idata2503/database/tables/exercise.dart';
import 'package:fitnessapp_idata2503/database/tables/workout_exercises.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/during_workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
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
  final User? user;

  const CustomNavigationBar({super.key, this.user});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar>  {
  int _selectedIndex = 0;
  Workouts activeWorkout =
      const Workouts(workoutId: '', name: '', isPrivate: true, userId: '');
  final WorkoutDao _workoutDao = WorkoutDao();

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkForActiveWorkouts() async {
    hasActiveWorkout.value = await _workoutDao.hasActiveWorkouts();
    if (hasActiveWorkout.value) {
      Workouts temp = await _workoutDao.fetchActiveWorkout();
      setState(() {
        activeWorkout = temp;
      });
    }
  }




  Future<Map<Exercises, WorkoutExercises>> fetchExercises() async {
    try {
      Map<Exercises, WorkoutExercises> exerciseMap = {};
      List<Exercises> exercises = await WorkoutDao()
          .localFetchExercisesForWorkout(activeWorkout.workoutId);
      for (final exercise in exercises) {
        final workoutExercise = await WorkoutExercisesDao()
            .localFetchById(activeWorkout.workoutId, exercise.exerciseId);
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
  void initState() {
    super.initState();
    hasActiveWorkout.addListener(() {
      if (hasActiveWorkout.value) {
        _checkForActiveWorkouts();
      }
    });
  }



  @override
@override
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
        if (hasActiveWorkout.value)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                Map<Exercises, WorkoutExercises> exerciseMap = await fetchExercises();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuringWorkoutScreen(
                        workout: activeWorkout, exerciseMap: exerciseMap),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 30,
                color: AppColors.fitnessMainColor,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  'Workout active: ${activeWorkout.name}',
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
    bottomNavigationBar: BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/home.svg',
            width: 20.0,
            height: 20.0,
            color: _selectedIndex == 0
                ? AppColors.fitnessMainColor
                : AppColors.fitnessSecondaryTextColor,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/workout.svg',
            width: 30.0,
            height: 30.0,
            color: _selectedIndex == 1
                ? AppColors.fitnessMainColor
                : AppColors.fitnessSecondaryTextColor,
          ),
          label: 'Workout',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/me.svg',
            width: 25.0,
            height: 25.0,
            color: _selectedIndex == 2
                ? AppColors.fitnessMainColor
                : AppColors.fitnessSecondaryTextColor,
          ),
          label: 'Me',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.fitnessMainColor,
      unselectedItemColor: AppColors.fitnessSecondaryTextColor,
      backgroundColor: AppColors.fitnessBackgroundColor,
      onTap: _onItemTapped,
      iconSize: 30.0,
      unselectedFontSize: 14.0,
    ),
    backgroundColor: AppColors.fitnessBackgroundColor,
  );
}

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return Home(user: widget.user);
      case 1:
        return WorkoutPage(user: widget.user);
      case 2:
        return Me(user: widget.user);
      default:
        return Home(user: widget.user);
    }
  }
}
