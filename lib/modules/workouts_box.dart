import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/database/crud/favorite_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/favorite_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../pages/workout and exercises/pre_workout_screen.dart';

/// Last edited 07/11/2024
/// Last edited by Håkon Svensen Karlsen

class WorkoutsBox extends StatefulWidget {
  bool isHome = false;

  WorkoutsBox({super.key, required this.workoutMap, required this.isHome});

  final Map<Workouts, DateTime> workoutMap;


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

  @override
  void initState() {
    super.initState();
    _userDao
        .getAdminStatus(FirebaseAuth.instance.currentUser?.uid)
        .then((value) {
      setState(() {
        isAdmin = value;
      });
    });
    for (final workout in widget.workoutMap.keys) {
      _favorites[workout.workoutId] = false;
    }
    _favoriteWorkoutsDao
        .localFetchByUserId(FirebaseAuth.instance.currentUser?.uid ?? '')
        .then((favorites) {
      setState(() {
        _favorites = {
          for (final favorite in favorites) favorite.workoutId: true,
        };
      });
    });
  }

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
                style: TextStyle(color: AppColors.fitnessMainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _favorite(String workoutId) {
    if (_favorites[workoutId] ?? false) {
      if (FirebaseAuth.instance.currentUser != null) {
        _favoriteWorkoutsDao.localDeleteByUserIdAndWorkoutId(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.workoutMap.entries.map((entry) {
        final workout = entry.key;
        final isFavorite = _favorites[workout.workoutId] ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Dismissible(
            key: Key(workout.workoutId.toString()),
            direction:
                // Only allow deletion if the user is the owner of the workout or an admin AND it is not one the home page
            (workout.userId == FirebaseAuth.instance.currentUser?.uid ||
                        isAdmin) && !widget.isHome
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
            confirmDismiss: (direction) => _confirmDelete(context),
            onDismissed: (direction) {
              setState(() {
                widget.workoutMap.remove(workout);
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
                      color: widget.isHome ? AppColors.fitnessSecondaryModuleColor : AppColors.fitnessModuleColor,
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
                              const IconText(
                                  text: '500Cal',
                                  color: AppColors.fitnessSecondaryTextColor,
                                  icon: Icons.local_fire_department),
                              const SizedBox(height: 7),
                              const IconText(
                                  text: '45min',
                                  color: AppColors.fitnessSecondaryTextColor,
                                  icon: Icons.access_time),
                              const SizedBox(height: 7),
                              IconText(
                                  text: '${workout.sets} sets',
                                  color: AppColors.fitnessSecondaryTextColor,
                                  icon: Icons.help_outline),
                              const SizedBox(height: 7),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double size = 90;
                            return SvgPicture.asset(
                              'assets/icons/stick_figure.svg',
                              height: size,
                              width: size,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            PreWorkoutScreen(workouts: workout),
                      ),
                    );
                  },
                ),
                  if(!widget.isHome)
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
