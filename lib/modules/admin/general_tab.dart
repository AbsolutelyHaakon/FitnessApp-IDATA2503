// lib/modules/admin/general_tab.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class GeneralTab extends StatefulWidget {
  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  final UserDao _userDao = UserDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  final ExerciseDao _exerciseDao = ExerciseDao();
  final PostsDao _postsDao = PostsDao();
  final WorkoutExercisesDao _workoutExercisesDao = WorkoutExercisesDao();

  int _users = 0;
  int _workouts = 0;
  int _exercises = 0;
  int _posts = 0;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    _userDao.getUserCount().then((value) {
      setState(() {
        _users = value;
      });
    });
    _workoutDao.getWorkoutsCount().then((value) {
      setState(() {
        _workouts = value;
      });
    });
    _exerciseDao.getExercisesCount().then((value) {
      setState(() {
        _exercises = value;
      });
    });
    _postsDao.getPostsCount().then((value) {
      setState(() {
        _posts = value;
      });
    });
  }

  // TODO: ADD MORE LOGIC HERE
  _removeInactiveData() {
    _removeInactiveWorkoutExercises();
  }

  _removeInactiveWorkoutExercises() async {
  final allWorkouts = await _workoutDao
      .getAllWorkouts(FirebaseAuth.instance.currentUser?.uid);
  final result = await _workoutExercisesDao.fireBaseDeleteInactiveWorkoutExercises(allWorkouts);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result['message'], style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
      backgroundColor: result['success'] ? AppColors.fitnessMainColor : AppColors.fitnessWarningColor,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatContainer('Users', '$_users'),
              _buildStatContainer('Workouts', '$_workouts'),
              _buildStatContainer('Exercises', '$_exercises'),
              _buildStatContainer('Posts', '$_posts'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return _buildButton(
                  text: 'Remove Inactive Data',
                  icon: Icons.delete,
                  onPressed: () {
                    _removeInactiveData();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatContainer(String label, String number) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.fitnessModuleColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            number,
            style: const TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      {required String text,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.fitnessPrimaryTextColor),
        label: Text(
          text,
          style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fitnessModuleColor,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
