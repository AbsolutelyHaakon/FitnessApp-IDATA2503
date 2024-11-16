import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/database/crud/favorite_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
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
///
/// TODO: Remove scheduling elements a make a calendar friendly version of the workouts box

class WorkoutsBox extends StatefulWidget {
  const WorkoutsBox({super.key, required this.workoutMap});

  final Map<Workouts, DateTime> workoutMap;

  String getFormattedDate(DateTime date) {
    String formattedMonth = DateFormat.MMMM().format(date);
    String day = date.day.toString();

    String dayWithSuffix = '$day${getDaySuffix(date.day)}';

    return '$formattedMonth, $dayWithSuffix';
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _WorkoutsBoxState();
  }
}

class _WorkoutsBoxState extends State<WorkoutsBox> {
  final WorkoutDao _workoutDao = WorkoutDao();
  Map<String, bool> _favorites = {};
  final FavoriteWorkoutsDao _favoriteWorkoutsDao = FavoriteWorkoutsDao();

  @override
  void initState() {
    super.initState();

    for (final workout in widget.workoutMap.keys) {
      _favorites[workout.workoutId] = false;
    }

    _favoriteWorkoutsDao.localFetchByUserId(FirebaseAuth.instance.currentUser?.uid ?? '')
        .then((favorites) {
      setState(() {
        _favorites = {
          for (final favorite in favorites)
            favorite.workoutId: true,
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
              child: const Text("Delete",
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
      _favoriteWorkoutsDao.fireBaseDeleteFavoriteWorkout(
          FirebaseAuth.instance.currentUser?.uid ?? '', workoutId);
    } else {
      _favoriteWorkoutsDao.fireBaseCreateFavoriteWorkout(
          FirebaseAuth.instance.currentUser?.uid ?? '', workoutId);
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
        final date = entry.value;
        final isFavorite = _favorites[workout.workoutId] ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Dismissible(
            key: Key(workout.workoutId.toString()),
            direction: workout.userId == FirebaseAuth.instance.currentUser?.uid
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
                      color: AppColors.fitnessModuleColor,
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
                        builder: (context) => PreWorkoutScreen(workout: workout),
                      ),
                    );
                  },
                ),
                if (date == DateTime(1970, 1, 1))
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.green : AppColors.fitnessPrimaryTextColor,
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