import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/texts.dart';
import 'package:fitnessapp_idata2503/database/crud/favorite_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/favorite_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../pages/workout and exercises/pre_workout_screen.dart';

class WorkoutsBox extends StatefulWidget {
  final bool isHome;
  final bool isSearch;
  final List<Workouts> workouts;
  final bool isToday;

  // Constructor for WorkoutsBox
  const WorkoutsBox({
    super.key,
    required this.workouts,
    required this.isHome,
    required this.isSearch,
    required this.isToday,
  });

  @override
  State<StatefulWidget> createState() {
    return _WorkoutsBoxState();
  }
}

class _WorkoutsBoxState extends State<WorkoutsBox> {
  final WorkoutDao _workoutDao = WorkoutDao();
  Map<String, bool> _favorites = {};
  final FavoriteWorkoutsDao _favoriteWorkoutsDao = FavoriteWorkoutsDao();
  final UserDao _userDao = UserDao();
  bool isAdmin = false;
  String intensity = '';

  @override
  void initState() {
    super.initState();
    // Check if the user is an admin
    _userDao
        .getAdminStatus(FirebaseAuth.instance.currentUser?.uid)
        .then((value) {
      if (mounted) {
        setState(() {
          isAdmin = value;
        });
      }
    });
    // Fetch favorite workouts for the current user
    _favoriteWorkoutsDao
        .localFetchByUserId(FirebaseAuth.instance.currentUser?.uid ?? '')
        .then((favorites) {
      if (mounted) {
        setState(() {
          _favorites = {
            for (final favorite in favorites) favorite.workoutId: true,
          };
        });
      }
    });

    for (final workout in widget.workouts) {
      getIntensityLevel(workout);
    }
  }

  void getIntensityLevel(Workouts workout) {
    switch (workout.intensity) {
      case 1:
        intensity = 'Low';
        break;
      case 2:
        intensity = 'Medium';
        break;
      case 3:
        intensity = 'High';
        break;
      default:
        intensity = 'Unknown';
        break;
    }
  }

  // Get the icon for a specific category
  SizedBox _getIconForCategory(String category) {
    int index = officialWorkoutCategories.indexOf(category);
    double size = 85;
    if (index != -1) {
      return SizedBox(
        width: size,
        height: size,
        child: officialFilterCategoryIcons[
            index + 2], // +2 to skip 'All' and 'Starred'
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset('assets/icons/allIcon.svg'),
    );
  }

  // Show a confirmation dialog for deleting a workout
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion",
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          content: const Text("Are you sure you want to delete this workout?"),
          backgroundColor: AppColors.fitnessModuleColor,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: AppColors.fitnessWarningColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Toggle favorite status for a workout
  void _favorite(String workoutId) {
    if (_favorites[workoutId] ?? false) {
      if (FirebaseAuth.instance.currentUser != null) {
        _favoriteWorkoutsDao.fireBaseDeleteFavoriteWorkout(
            FirebaseAuth.instance.currentUser?.uid ?? '', workoutId);
      }

      _favoriteWorkoutsDao.localDeleteByUserIdAndWorkoutId(
          FirebaseAuth.instance.currentUser?.uid ?? 'localUser', workoutId);
    } else {
      if (FirebaseAuth.instance.currentUser != null) {
        _favoriteWorkoutsDao.fireBaseCreateFavoriteWorkout(
            FirebaseAuth.instance.currentUser?.uid ?? '', workoutId);
      }

      _favoriteWorkoutsDao.localCreate(FavoriteWorkouts(
        favoriteWorkoutId: '1',
        userId: FirebaseAuth.instance.currentUser?.uid ?? 'localUser',
        workoutId: workoutId,
      ));
    }
    setState(() {
      _favorites[workoutId] = !(_favorites[workoutId] ?? false);
    });
  }

  // Build the UI for the workouts list
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.workouts.map((workout) {
        final isFavorite = _favorites[workout.workoutId] ?? false;

        return Padding(
          padding: EdgeInsets.only(bottom: widget.isHome ? 10.0 : 20.0),
          child: Dismissible(
            key: Key(workout.workoutId.toString()),
            direction:
                // Only allow deletion if the user is the owner of the workout or an admin AND it is not one the home page
                (workout.userId == FirebaseAuth.instance.currentUser?.uid ||
                            isAdmin) &&
                        !widget.isHome
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
            confirmDismiss: (direction) => _confirmDelete(context),
            onDismissed: (direction) {
              setState(() {
                widget.workouts.remove(workout);
                _workoutDao.fireBaseDeleteWorkout(workout.workoutId);
              });
            },
            background: Container(
              color: AppColors.fitnessWarningColor,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(top: 40, bottom: 20),
              child: const Icon(
                Icons.delete,
                color: AppColors.fitnessPrimaryTextColor,
              ),
            ),
            child: Stack(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 80),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: widget.isHome
                          ? AppColors.fitnessModuleColor
                          : AppColors.fitnessModuleColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.fromLTRB(25, 15, 30, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Heading1(text: workout.name),
                              Heading2(text: workout.category ?? 'No category'),
                              const SizedBox(height: 20),
                              IconText(
                                  text: workout.sets == 1
                                      ? '${workout.sets} set'
                                      : '${workout.sets} sets',
                                  color: AppColors.fitnessSecondaryTextColor,
                                  icon: Icons.help_outline),
                              const SizedBox(height: 7),
                              if (workout.calories != 0)
                                IconText(
                                    text: '${workout.calories} Cal',
                                    color: AppColors.fitnessSecondaryTextColor,
                                    icon: Icons.local_fire_department),
                              if (workout.calories == 0)
                                IconText(
                                    text: '$intensity Intensity',
                                    color: AppColors.fitnessSecondaryTextColor,
                                    icon: Icons.local_fire_department),
                              const SizedBox(height: 7),
                              if (workout.duration != 0)
                                IconText(
                                    text: '${workout.duration} min',
                                    color: AppColors.fitnessSecondaryTextColor,
                                    icon: Icons.access_time),
                              const SizedBox(height: 7),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        _getIconForCategory(workout.category ?? 'No category'),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  onPressed: () async {
                    if (widget.isToday) {
                      final userWorkout =
                          await UserWorkoutsDao().localFetchTodaysWorkout();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PreWorkoutScreen(
                            userWorkouts: userWorkout,
                            isSearch: widget.isSearch,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => PreWorkoutScreen(
                            workouts: workout,
                            isSearch: widget.isSearch,
                          ),
                        ),
                      );
                    }
                  },
                ),
                if (!widget.isHome && !widget.isSearch)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.green
                            : AppColors.fitnessPrimaryTextColor,
                      ),
                      onPressed: () => _favorite(workout.workoutId),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
