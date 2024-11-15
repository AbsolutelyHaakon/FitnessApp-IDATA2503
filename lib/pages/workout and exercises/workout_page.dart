import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/favorite_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/favorite_workouts.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/create_workout_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../database/crud/user_workouts_dao.dart';
import '../../database/crud/workout_dao.dart';
import '../../database/tables/workout.dart';

/// The WorkoutPage is the main page for the workout section of the app.
/// Shows all workouts the user has
/// Let's the user create a new workout
/// Let's the user select a workout to start
/// Let's the user select a date to workout
///
/// @Last Edited: 08.11.2024
/// @Last Edited By: Håkon Svensen Karlsen

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _addIconController;
  late Animation<double> _addIconAnimation;
  late Animation<double> _buttonAnimation;
  bool _showOptions = false;
  List<Workouts> workouts = [];
  Map<Workouts, DateTime> workoutsMap = {};
  String _selectedCategory = 'All';

  List<FavoriteWorkouts> favoriteWorkouts = [];
  final FavoriteWorkoutsDao favoriteWorkoutsDao = FavoriteWorkoutsDao();

  final List<String> categories = ['All', 'Starred', 'Legs', 'Abs', 'Upper Body', 'Cardio', 'Outdoors'];
  final List<SvgPicture> categoryIcons = [
    SvgPicture.asset('assets/icons/allIcon.svg', width: 40, height: 40),
    SvgPicture.asset('assets/icons/starIcon.svg', width: 25, height: 25),
    SvgPicture.asset('assets/icons/lowerBodyIcon.svg', width: 40, height: 40),
    SvgPicture.asset('assets/icons/absIcon.svg', width: 40, height: 40),
    SvgPicture.asset('assets/icons/upperBodyIcon.svg', width: 40, height: 40),
    SvgPicture.asset('assets/icons/runnerIcon.svg', width: 40, height: 40),
    SvgPicture.asset('assets/icons/hikerIcon.svg', width: 40, height: 40),
  ];

  @override
  void initState() {
    super.initState();

    // These actions are only done if a user is logged in
    fetchAllWorkouts("All");

    // Animation controllers for floating button widget
    _addIconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addIconAnimation =
        Tween<double>(begin: 0, end: 0.25).animate(_addIconController);
    _buttonAnimation = CurvedAnimation(
      parent: _addIconController,
      curve: Curves.easeInOut,
    );
  }

  void fetchFavorites() async {
    favoriteWorkouts.clear();
    final favoriteWorkoutsData = await FavoriteWorkoutsDao().localFetchByUserId(FirebaseAuth.instance.currentUser?.uid);
    if (!mounted) return;
    setState(() {
      favoriteWorkouts = favoriteWorkoutsData;
    });
  }

  void fetchAllWorkouts(String category) async {
    workoutsMap.clear();
    fetchFavorites();
    workouts = await WorkoutDao().localFetchAllById(FirebaseAuth.instance.currentUser?.uid);
    if (category != "All" && category != "Starred") {
      workouts = workouts.where((element) => element.category == category).toList();
    } else if(category == "Starred") {
      workouts = workouts.where((element) => favoriteWorkouts.any((favorite) => favorite.workoutId == element.workoutId)).toList();
    }
    if (!mounted) return;
    setState(() {
      for (var workout in workouts) {
        workoutsMap[workout] = DateTime(1970, 1, 1);
      }
    });
  }


  @override
  void dispose() {
    _addIconController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    if (!mounted) return;
    setState(() {
      _showOptions = !_showOptions;
    });
    if (_addIconController.isCompleted) {
      _addIconController.reverse();
    } else {
      _addIconController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Select a workout to begin',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),

                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(categories.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = categories[index];
                          fetchAllWorkouts(categories[index]);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: _selectedCategory == categories[index]
                              ?  AppColors.fitnessMainColor
                              : AppColors.fitnessModuleColor,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(child: categoryIcons[index]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: WorkoutsBox(
                      workoutMap: workoutsMap,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showOptions) ...[
            Positioned(
              bottom: 180,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateWorkoutPage(),
                      ),
                    );
                    if (result == true) {
                      workoutsMap.clear();
                      fetchAllWorkouts("All");
                    }
                    _toggleOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fitnessMainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Create New',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.fitnessBackgroundColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 130,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () {
                    // Redirect to another page (not created yet)
                    _toggleOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fitnessMainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Choose Preset',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      enableDrag: true,
                      builder: (context) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: AppColors.fitnessBackgroundColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.6,
                            widthFactor: 1,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Select a date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                // Add more widgets as needed
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    _toggleOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.fitnessMainColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      floatingActionButton: FloatingActionButton(
        heroTag: 'toggleOptions',
        backgroundColor: AppColors.fitnessMainColor,
        shape: const CircleBorder(),
        onPressed: _toggleOptions,
        child: AnimatedBuilder(
          animation: _addIconAnimation,
          child: const Icon(Icons.add, color: Colors.black),
          builder: (context, child) {
            return Transform.rotate(
              angle: _addIconAnimation.value * 3.14159,
              child: child,
            );
          },
        ),
      ),
    );
  }
}