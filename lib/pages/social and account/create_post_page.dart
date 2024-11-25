import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../database/crud/posts_dao.dart';
import '../../styles.dart';

/// CreatePostPage which allows the user to create a post
///
/// Last edited: 13.11.2024
/// Last edited by: Håkon Karlsen
///
/// TODO: Implement post creation logic
/// TODO: Implement attach exercise logic

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  String? _message;
  Map<String,String> _workoutStats = {};
  String? _workoutId;
  String? _location;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLocationFieldVisible = false;
  final FocusNode _locationFocusNode = FocusNode();
  bool _isSubmitting = false;

  final PostsDao _postsDao = PostsDao();

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
      _workoutId,
      _location,
      null,
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
    if (_workoutId == null) { return;}

    await UserWorkoutsDao().fireBaseFetchUserWorkoutById(_workoutId!).then((userWorkout) {
      if (userWorkout != null) {
        if (userWorkout.statistics == null) {return;}
        String stats = userWorkout.statistics!;

        int setCount = 0;

        jsonDecode(stats).forEach((key, value) {
          setCount++;
        });

        print(setCount);

        _workoutStats['Sets'] = setCount.toString();
        _workoutStats['Duration'] = userWorkout.duration.toString();
      }
    });
  }

Future<void> _showStatsSelectionDialog() async {
  final Map<String, String> selectedStats = Map.from(_workoutStats);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select up to 3 stats',
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._workoutStats.entries.map((entry) {
                  return CheckboxListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
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
                    value: selectedStats.containsKey(entry.key),
                    checkColor: AppColors.fitnessPrimaryTextColor,
                    activeColor: AppColors.fitnessMainColor,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (selectedStats.length < 3) {
                            selectedStats[entry.key] = entry.value;
                          }
                        } else {
                          selectedStats.remove(entry.key);
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
                        _workoutId = result;
                      });
                      await _buildWorkoutStats();
                      await _showStatsSelectionDialog();
                    }
                  },
                  child: const Text('Attach Different Workout',
                      style: TextStyle(color: AppColors.fitnessMainColor)),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _workoutStats = selectedStats;
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: AppColors.fitnessMainColor)),
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
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back,
            color: AppColors.fitnessMainColor),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
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
                          if (_workoutStats.isNotEmpty)
                            Row(
                              children: _workoutStats.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: AppColors.fitnessPrimaryTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        entry.value,
                                        style: const TextStyle(
                                          color: AppColors.fitnessSecondaryTextColor,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          if (_workoutStats.isEmpty) const Spacer(),
                          TextButton(
                            onPressed: () async {
                              if (_workoutId != null) {
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
                                    _workoutStats.clear();
                                    _workoutId = result;
                                  });
                                  await _buildWorkoutStats();
                                  await _showStatsSelectionDialog();
                                }
                              }
                            },
                            child: Text(
                              _workoutId != null
                                  ? 'Edit Stats'
                                  : 'Attach Workout >',
                              style: TextStyle(
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
