import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/favorite_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/favorite_workouts.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/modules/floating_button_component.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/create_workout_page.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_calendar.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_log.dart';
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

  @override
  void initState() {
    super.initState();

    fetchAllWorkouts("All");

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
    final favoriteWorkoutsData = await FavoriteWorkoutsDao().localFetchByUserId(
        FirebaseAuth.instance.currentUser?.uid ?? 'localUser');
    if (!mounted) return;
    setState(() {
      favoriteWorkouts = favoriteWorkoutsData;
    });
  }

  void fetchAllWorkouts(String category) async {
    workoutsMap.clear();
    fetchFavorites();
    workouts = await WorkoutDao().localFetchAllById(
        FirebaseAuth.instance.currentUser?.uid ?? 'localUser');
    if (category != "All" && category != "Starred") {
      workouts =
          workouts.where((element) => element.category == category).toList();
    } else if (category == "Starred") {
      workouts = workouts
          .where((element) => favoriteWorkouts
              .any((favorite) => favorite.workoutId == element.workoutId))
          .toList();
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
    final appBarHeight = MediaQuery.of(context).size.height * 0.09;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workout',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WorkoutLog(isCreatingPost: false),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.history_rounded,
                        size: 30.0,
                        color: AppColors.fitnessMainColor,
                      ),
                    ),
                  ],
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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:
                      List.generate(officialFilterCategories.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = officialFilterCategories[index];
                          fetchAllWorkouts(officialFilterCategories[index]);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: _selectedCategory ==
                                  officialFilterCategories[index]
                              ? AppColors.fitnessPrimaryTextColor
                              : AppColors.fitnessModuleColor,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child:
                              Center(child: officialFilterCategoryIcons[index]),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WorkoutsBox(
                          workoutMap: Map.fromEntries(
                            workoutsMap.entries
                                .where((entry) => entry.key.userId != ''),
                          ),
                          isHome: false,
                        ),
                        if (workoutsMap.entries
                            .where((entry) => entry.key.userId != '')
                            .isNotEmpty)
                          const SizedBox(height: 40),
                        if (workoutsMap.entries
                            .where((entry) => entry.key.userId == '')
                            .isNotEmpty)
                          Center(
                            child: Text(
                              workoutsMap.entries
                                      .where((entry) => entry.key.userId == '')
                                      .isNotEmpty
                                  ? 'Premade Workouts'
                                  : '',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        const SizedBox(height: 10),
                        WorkoutsBox(
                          workoutMap: Map.fromEntries(
                            workoutsMap.entries
                                .where((entry) => entry.key.userId == ''),
                          ),
                          isHome: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showOptions) ...[
            Positioned(
              bottom: 150,
              right: 10,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateWorkoutPage(
                          isAdmin: false,
                        ),
                      ),
                    );
                    if (result == true) {
                      fetchAllWorkouts("All");
                    }
                    _toggleOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
              bottom: 100,
              right: 10,
              child: ScaleTransition(
                scale: _buttonAnimation,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutCalendar(),
                      ),
                    );
                    _toggleOptions();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
          Positioned(
            bottom: 35,
            right: 10,
            child: ToggleOptionsButton(onPressed: _toggleOptions),
          ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
