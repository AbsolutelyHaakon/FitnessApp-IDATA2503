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

class _GeneralTabState extends State<GeneralTab> with TickerProviderStateMixin {
  final UserDao _userDao = UserDao();
  final WorkoutDao _workoutDao = WorkoutDao();
  final ExerciseDao _exerciseDao = ExerciseDao();
  final PostsDao _postsDao = PostsDao();
  final WorkoutExercisesDao _workoutExercisesDao = WorkoutExercisesDao();

  late AnimationController _usersController;
  late AnimationController _workoutsController;
  late AnimationController _exercisesController;
  late AnimationController _postsController;

  late Animation<int> _usersAnimation;
  late Animation<int> _workoutsAnimation;
  late Animation<int> _exercisesAnimation;
  late Animation<int> _postsAnimation;

  @override
  void initState() {
    super.initState();
    _usersController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _workoutsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _exercisesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _postsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _usersAnimation = IntTween(begin: 0, end: 0).animate(_usersController);
    _workoutsAnimation = IntTween(begin: 0, end: 0).animate(_workoutsController);
    _exercisesAnimation = IntTween(begin: 0, end: 0).animate(_exercisesController);
    _postsAnimation = IntTween(begin: 0, end: 0).animate(_postsController);

    fetchStatistics();
  }


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

  Future<void> fetchStatistics() async {
    final usersCount = await _userDao.getUserCount();
    final workoutsCount = await _workoutDao.getWorkoutsCount();
    final exercisesCount = await _exerciseDao.getExercisesCount();
    final postsCount = await _postsDao.getPostsCount();

    setState(() {
      _usersAnimation = IntTween(begin: 0, end: usersCount).animate(_usersController);
      _workoutsAnimation = IntTween(begin: 0, end: workoutsCount).animate(_workoutsController);
      _exercisesAnimation = IntTween(begin: 0, end: exercisesCount).animate(_exercisesController);
      _postsAnimation = IntTween(begin: 0, end: postsCount).animate(_postsController);
    });

    _usersController.forward();
    _workoutsController.forward();
    _exercisesController.forward();
    _postsController.forward();
  }

  @override
  void dispose() {
    _usersController.dispose();
    _workoutsController.dispose();
    _exercisesController.dispose();
    _postsController.dispose();
    super.dispose();
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
              _buildAnimatedStatContainer('Users', _usersAnimation),
              _buildAnimatedStatContainer('Workouts', _workoutsAnimation),
              _buildAnimatedStatContainer('Exercises', _exercisesAnimation),
              _buildAnimatedStatContainer('Posts', _postsAnimation),
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

  Widget _buildAnimatedStatContainer(String label, Animation<int> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
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
                '${animation.value}',
                style: const TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
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