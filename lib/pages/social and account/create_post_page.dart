import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../database/crud/posts_dao.dart';
import '../../styles.dart';

/// CreatePostPage which allows the user to create a post
///
///
/// TODO: Implement post creation logic
/// TODO: Implement attach exercise logic

class CreatePostPage extends StatefulWidget {
  final UserWorkouts? userWorkout;

  const CreatePostPage({super.key, this.userWorkout});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  String? _message;
  Map<String, String> _workoutStats = {};
  Map<String, String> displayedStats = {};
  String? _userWorkoutId;
  String? _location;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLocationFieldVisible = false;
  final FocusNode _locationFocusNode = FocusNode();
  bool _isSubmitting = false;

  final PostsDao _postsDao = PostsDao();

  @override
  void initState() {
    super.initState();
    if (widget.userWorkout != null) {
      _userWorkoutId = widget.userWorkout!.userWorkoutId;
      _buildWorkoutStats();
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _createPost() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _postsDao.fireBaseCreatePost(
      _message,
      _selectedImage,
      _userWorkoutId,
      _location,
      displayedStats,
      FirebaseAuth.instance.currentUser!.uid,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (result['success']) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
            style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.fitnessWarningColor,
        ),
      );
    }
  }

  Future<void> _buildWorkoutStats() async {
    if (_userWorkoutId == null) {
      return;
    }

    await UserWorkoutsDao()
        .fireBaseFetchUserWorkoutById(_userWorkoutId!)
        .then((userWorkout) {
      if (userWorkout != null) {
        if (userWorkout.statistics == null) {
          return;
        }

        calculateStatistics(userWorkout);
        calculateDuration(userWorkout);
      }
    });
  }

  void calculateStatistics(UserWorkouts userWorkout) {
    if (userWorkout.statistics == null) {
      return;
    }

    String stats = userWorkout.statistics!;
    Map<String, dynamic> decodedStats = jsonDecode(stats);

    // First, calculate the amount of sets
    // You could use the Workout's "sets" field,
    // but this one takes into account changing of the sets during the workout
    int setCount = 0;

    int maxWeightOverall = 0;
    Map<String, int> maxWeightPerExercise = {};

    decodedStats.forEach((exercise, sets) {
      int maxWeightForExercise = 0;
      setCount++;

      for (var set in sets) {
        int weight = set['weight'];
        if (weight > maxWeightForExercise) {
          maxWeightForExercise = weight;
        }
      }

      maxWeightPerExercise[exercise] = maxWeightForExercise;

      if (maxWeightForExercise > maxWeightOverall) {
        maxWeightOverall = maxWeightForExercise;
      }
    });

    _workoutStats['Sets'] = setCount.toString();
    _workoutStats['Max Weight'] = '$maxWeightOverall kg';
    maxWeightPerExercise.forEach((exercise, maxWeight) {
     _workoutStats[exercise] = '$maxWeight kg';
    });

    print('Stats: $stats');
  }

  void calculateDuration(UserWorkouts userWorkout) {
    if (userWorkout.duration == null) {
      return;
    }
    int durationInMinutes = userWorkout.duration!.toInt();
    int hours = durationInMinutes ~/ 60;
    int minutes = durationInMinutes % 60;
    String formattedDuration =
        hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    _workoutStats['Duration'] = formattedDuration;
  }

Future<void> _showStatsSelectionDialog() async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select up to 3 stats',
            style: TextStyle(
                color: AppColors.fitnessPrimaryTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._workoutStats.entries.map((entry) {
                    return CheckboxListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${entry.key}: ',
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17)),
                          Text(entry.value,
                              style: const TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15)),
                        ],
                      ),
                      value: displayedStats.containsKey(entry.key),
                      checkColor: AppColors.fitnessPrimaryTextColor,
                      activeColor: AppColors.fitnessMainColor,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (displayedStats.length < 3) {
                              displayedStats[entry.key] = entry.value;
                            }
                          } else {
                            displayedStats.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const WorkoutLog(isCreatingPost: true),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _workoutStats.clear();
                          _userWorkoutId = result;
                        });
                        await _buildWorkoutStats();
                        await _showStatsSelectionDialog();
                      }
                    },
                    child: const Text('Attach Different Workout',
                        style: TextStyle(color: AppColors.fitnessMainColor)),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                displayedStats = displayedStats;
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK',
                style: TextStyle(color: AppColors.fitnessMainColor)),
          ),
        ],
        backgroundColor: AppColors.fitnessModuleColor,
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.fitnessPrimaryTextColor,
          ),
        ),
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_userWorkoutId != null) {
                await _showStatsSelectionDialog();
              } else {
                final result =
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WorkoutLog(
                        isCreatingPost: true),
                  ),
                );
                if (result != null) {
                  setState(() {
                    displayedStats.clear();
                    _workoutStats.clear();
                    _userWorkoutId = result;
                  });
                  await _buildWorkoutStats();
                  await _showStatsSelectionDialog();
                }
              }
            },
            child: Text(_userWorkoutId != null
                ? 'Edit Stats'
                : 'Attach Workout >',
                style: const TextStyle(color: AppColors.fitnessMainColor)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: AppColors.fitnessModuleColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: AppColors.fitnessModuleColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          style: const TextStyle(
                            color: AppColors.fitnessPrimaryTextColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'What\'s on your mind?',
                            hintStyle: const TextStyle(
                              color: AppColors.fitnessSecondaryTextColor,
                            ),
                          ),
                          onSaved: (value) {
                            _message = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (displayedStats.isNotEmpty)
                              Row(
                                children: displayedStats.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: AppColors
                                                .fitnessSecondaryTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: AppColors
                                                .fitnessPrimaryTextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (displayedStats.isNotEmpty)
                            TextButton(
                              onPressed: () async {
                                // TODO: MAKE THIS NAVIGATE TO THE WORKOUT ITSELF
                              },
                              child: const Text(
                                'View >',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.fitnessMainColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: _selectedImage != null
                                  ? Stack(
                                      children: [
                                        Image.file(
                                          File(_selectedImage!.path),
                                          height: 250,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedImage = null;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: AppColors.fitnessModuleColor,
                                      child: Center(
                                        child: Container(
                                          width: 220,
                                          height: 120,
                                          color: AppColors
                                              .fitnessSecondaryModuleColor,
                                          child: const Icon(
                                            Icons.image,
                                            color: AppColors
                                                .fitnessPrimaryTextColor,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _isLocationFieldVisible
                    ? Row(
                        children: [
                          Transform.scale(
                            scale: 0.7,
                            child: const Icon(Icons.location_on,
                                color: AppColors.fitnessMainColor),
                          ),
                          Expanded(
                            child: TextFormField(
                              focusNode: _locationFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Location",
                                hintStyle: const TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                ),
                              ),
                              style: const TextStyle(
                                color: AppColors.fitnessPrimaryTextColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                              onSaved: (value) {
                                _location = value;
                              },
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isLocationFieldVisible = true;
                            });
                            Future.delayed(Duration(milliseconds: 100), () {
                              FocusScope.of(context)
                                  .requestFocus(_locationFocusNode);
                            });
                          },
                          child: const Text(
                            '+ Add location',
                            style: TextStyle(color: AppColors.fitnessMainColor),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 300,
        child: FloatingActionButton(
          backgroundColor: AppColors.fitnessMainColor,
          onPressed: _isSubmitting
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _createPost();
                  }
                },
          child: _isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.fitnessPrimaryTextColor),
                )
              : const Text(
                  'Create Post',
                  style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
