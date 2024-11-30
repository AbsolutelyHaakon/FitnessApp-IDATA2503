import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/ind_exercise_box.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/exercise_selector.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../database/crud/workout_dao.dart';
import '../../database/tables/exercise.dart';

class CreateWorkoutPage extends StatefulWidget {
  final bool isAdmin;
  final Workouts? preWorkout;

  CreateWorkoutPage({super.key, required this.isAdmin, this.preWorkout});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final FocusNode _TitleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  bool _isDescriptionFocused = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final WorkoutDao workoutDao = WorkoutDao();
  final WorkoutExercisesDao workoutExercisesDao = WorkoutExercisesDao();
  final UserDao userDao = UserDao();
  bool _isPublic = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  List<Exercises> selectedExercises = [];
  List<IndExerciseBox> exercises = [];

  int _intensity = 1;
  String _selectedCategory = 'Cardio';
  Duration _duration = Duration.zero;
  int _calories = 0;
  bool _isLoading = false;

  // Function to create an individual exercise box
  createIndExerciseBox(Exercises exercise) {
    return IndExerciseBox(
      key: ValueKey(exercise),
      exerciseId: exercise.exerciseId ?? '',
      exerciseName: exercise.name,
      repsController: TextEditingController(),
      setsController: TextEditingController(),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkForPreData();
    _descriptionFocusNode.addListener(() {
      setState(() {
        _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Check if there is pre-existing data to populate the form
  _checkForPreData() {
    if (widget.preWorkout != null) {
      _titleController.text = widget.preWorkout!.name;
      _descriptionController.text = widget.preWorkout!.description!;
      _intensity = widget.preWorkout!.intensity!;
      _isPublic = !widget.preWorkout!.isPrivate!;
      _duration = Duration(minutes: widget.preWorkout!.duration!);
      _calories = widget.preWorkout!.calories!;
      if (widget.preWorkout!.imageURL != null){
        _selectedImage = XFile(widget.preWorkout!.imageURL!);
      }
      _selectedCategory = widget.preWorkout!.category!;
      workoutDao
          .localFetchExercisesForWorkout(widget.preWorkout!.workoutId!)
          .then((value) {
        setState(() {
          for (var exercise in value) {
            selectedExercises.add(exercise);
            exercises.add(createIndExerciseBox(exercise));
          }
        });
      });
    }
  }

// Function to create or update a workout
  Future<void> _createWorkout() async {
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text(
            'Please add at least one exercise to the workout.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.fitnessWarningColor,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate() && widget.preWorkout == null) {
      String? user = FirebaseAuth.instance.currentUser?.uid;
      user ??= "localUser";
      if (await userDao
              .getAdminStatus(FirebaseAuth.instance.currentUser?.uid) &&
          widget.isAdmin) {
        user = "";
      }
      try {
        final result = await workoutDao.fireBaseCreateWorkout(
          _selectedCategory,
          _descriptionController.text,
          _duration.inMinutes,
          _intensity,
          !_isPublic,
          user,
          _selectedImage,
          _titleController.text,
          true,
          _calories,
          exercises.length, // Number of exercises / sets
        );

        for (var exercise in exercises) {
          final reps = int.tryParse(exercise.repsController.text) ?? 0;
          final sets = int.tryParse(exercise.setsController.text) ?? 0;
          workoutExercisesDao.fireBaseCreateWorkoutExercise(
            result!,
            exercise.exerciseId,
            reps,
            sets,
            exercises.indexOf(exercise),
          );
        }

        // Only pop after workout creation succeeds
        Navigator.pop(context, true);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        // Optionally, show an error dialog or message here
      }
    } else if (_formKey.currentState!.validate() && widget.preWorkout != null) {
      await workoutDao.firebaseUpdateWorkout(
        widget.preWorkout!.workoutId,
        _selectedCategory,
        _descriptionController.text,
        _duration.inMinutes,
        _intensity,
        !_isPublic,
        FirebaseAuth.instance.currentUser?.uid ?? "localUser",
        _selectedImage,
        _titleController.text,
        true,
        _calories,
        exercises.length, // Number of exercises / sets
      );

      if (widget.preWorkout!.workoutId == null) {
        return;
      }
      await workoutExercisesDao.deleteAllWorkoutExercisesNotInList(
          selectedExercises, widget.preWorkout!.workoutId!);

      for (var exercise in exercises) {
        print("exercise: ${exercise.exerciseId}");
        print("exercise index: ${exercises.indexOf(exercise)}");
        final reps = int.tryParse(exercise.repsController.text) ?? 0;
        final sets = int.tryParse(exercise.setsController.text) ?? 0;
        await workoutExercisesDao.fireBaseCreateWorkoutExercise(
          widget.preWorkout!.workoutId,
          exercise.exerciseId,
          reps,
          sets,
          exercises.indexOf(exercise),
        );
      }
      Navigator.pop(context, widget.preWorkout);
    }
  }

  // Function to show category picker
  void _showCategoryPicker(BuildContext context) {
    _descriptionFocusNode.unfocus();
    _TitleFocusNode.unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: AppColors.fitnessBackgroundColor,
        child: CupertinoPicker(
          backgroundColor: AppColors.fitnessBackgroundColor,
          itemExtent: 32.0,
          onSelectedItemChanged: (int index) {
            setState(() {
              _selectedCategory = officialWorkoutCategories[index];
            });
          },
          children: officialWorkoutCategories.map((String value) {
            return Center(
              child: Text(
                value,
                style:
                    const TextStyle(color: AppColors.fitnessPrimaryTextColor),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Function to show intensity picker
  void _showIntensityPicker(BuildContext context) {
    _descriptionFocusNode.unfocus();
    _TitleFocusNode.unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: AppColors.fitnessBackgroundColor,
        child: CupertinoPicker(
          backgroundColor: AppColors.fitnessBackgroundColor,
          itemExtent: 32.0,
          onSelectedItemChanged: (int index) {
            setState(() {
              _intensity = index + 1;
            });
          },
          children: const [
            Center(
                child: Text('Low',
                    style:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor))),
            Center(
                child: Text('Medium',
                    style:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor))),
            Center(
                child: Text('High',
                    style:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor))),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    _descriptionFocusNode.unfocus();
    _TitleFocusNode.unfocus();
    int selectedHours = 0;
    int selectedMinutes = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: AppColors.fitnessBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CupertinoPicker(
                backgroundColor: AppColors.fitnessBackgroundColor,
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  selectedHours = index;
                },
                children: List<Widget>.generate(24, (int index) {
                  return Center(
                    child: Text(
                      '$index hr',
                      style: const TextStyle(
                          color: AppColors.fitnessPrimaryTextColor),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: AppColors.fitnessBackgroundColor,
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  selectedMinutes = index;
                },
                children: List<Widget>.generate(60, (int index) {
                  return Center(
                    child: Text(
                      '$index min',
                      style: const TextStyle(
                          color: AppColors.fitnessPrimaryTextColor),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _duration = Duration(hours: selectedHours, minutes: selectedMinutes);
      });
    });
  }

  void _showCaloriesPicker(BuildContext context) {
    _descriptionFocusNode.unfocus();
    _TitleFocusNode.unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: AppColors.fitnessBackgroundColor,
        child: CupertinoPicker(
          backgroundColor: AppColors.fitnessBackgroundColor,
          itemExtent: 32.0,
          onSelectedItemChanged: (int index) {
            setState(() {
              _calories = index * 20;
            });
          },
          children: List<Widget>.generate(101, (int index) {
            return Center(
              child: Text(
                '${index * 20} cal',
                style:
                    const TextStyle(color: AppColors.fitnessPrimaryTextColor),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    } else {
      print("No image selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.preWorkout == null ? 'Create Workout' : 'Edit Workout',
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseSelectorPage(
                      selectedExercises: selectedExercises),
                ),
              );
              setState(() {
                selectedExercises.clear();
                exercises.clear();
              });
              if (result != null && result is List<Exercises>) {
                setState(() {
                  for (var exercise in result) {
                    selectedExercises.add(exercise);
                    exercises.add(createIndExerciseBox(exercise));
                  }
                });
              }
            },
            child: const Text('Add Exercise',
                style: TextStyle(color: AppColors.fitnessMainColor)),
          ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _titleController,
                    focusNode: _TitleFocusNode,
                    cursorColor: AppColors.fitnessMainColor,
                    style: const TextStyle(
                        color: AppColors.fitnessPrimaryTextColor, fontSize: 25),
                    decoration: const InputDecoration(
                      labelText: 'Workout Title',
                      labelStyle: TextStyle(
                          color: AppColors.fitnessMainColor, fontSize: 25),
                      filled: true,
                      fillColor: AppColors.fitnessBackgroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.fitnessModuleColor),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppColors.fitnessPrimaryTextColor),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 12.0),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                      hintText: 'Workout Title..',
                      hintStyle: TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a workout title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isDescriptionFocused
                      ? MediaQuery.of(context).size.height * 0.1
                      : 60,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.fitnessPrimaryTextColor,
                    style: const TextStyle(
                        color: AppColors.fitnessPrimaryTextColor, fontSize: 16),
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(
                          color: AppColors.fitnessMainColor, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.fitnessBackgroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.fitnessModuleColor),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.fitnessMainColor),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 12.0),
                      errorStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                      hintText: 'Description..',
                      hintStyle: TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                      ),
                    ),
                    onEditingComplete: () {
                      _descriptionFocusNode.unfocus();
                    },
                  ),
                ),
                if (FirebaseAuth.instance.currentUser?.uid != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      height: _selectedImage != null ? 250 : 150,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          if (_selectedImage != null)
                            Positioned.fill(
                              child: _selectedImage!.path.startsWith('http')
                                  ? Image.network(
                                _selectedImage!.path,
                                fit: BoxFit.cover,
                              )
                                  : Image.file(
                                File(_selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(
                            height: _selectedImage != null ? 250 : 150,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .fitnessBackgroundColor
                                    .withOpacity(
                                        _selectedImage != null ? 0 : 1.0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: _selectedImage != null
                                          ? Colors.transparent
                                          : AppColors.fitnessModuleColor,
                                      width: 1),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image, color: AppColors.fitnessMainColor),
                                      Text(
                                        _selectedImage != null ? 'Change Image' : 'Add Image',
                                        style: TextStyle(color: AppColors.fitnessMainColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          'Intensity',
                          style: TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showIntensityPicker(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.fitnessModuleColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _intensity == 1
                                          ? 'Low'
                                          : _intensity == 2
                                              ? 'Medium'
                                              : 'High',
                                      style: const TextStyle(
                                          color: AppColors
                                              .fitnessPrimaryTextColor),
                                    ),
                                    const Icon(
                                      CupertinoIcons.chevron_down,
                                      color: AppColors.fitnessPrimaryTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _showCategoryPicker(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: AppColors.fitnessModuleColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedCategory,
                                    style: const TextStyle(
                                        color:
                                            AppColors.fitnessPrimaryTextColor),
                                  ),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    color: AppColors.fitnessPrimaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: FirebaseAuth.instance.currentUser?.uid != null
                              ? 20
                              : 0),
                      if (FirebaseAuth.instance.currentUser?.uid != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Public',
                                style: TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              value: _isPublic,
                              onChanged: (value) {
                                setState(() {
                                  _isPublic = value;
                                });
                              },
                              activeColor: AppColors.fitnessMainColor,
                            ),
                          ],
                        ),
                      if (_isPublic) const SizedBox(height: 20),
                      if (_isPublic)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                'Duration',
                                style: TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showDurationPicker(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.fitnessModuleColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_duration.inHours} hr ${_duration.inMinutes % 60} min',
                                        style: const TextStyle(
                                            color: AppColors
                                                .fitnessPrimaryTextColor),
                                      ),
                                      const Icon(
                                        CupertinoIcons.chevron_down,
                                        color:
                                            AppColors.fitnessPrimaryTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (_isPublic) const SizedBox(height: 20),
                      if (_isPublic)
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                'Expected Calories Burned',
                                style: TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showCaloriesPicker(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.fitnessModuleColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$_calories cal',
                                        style: const TextStyle(
                                            color: AppColors
                                                .fitnessPrimaryTextColor),
                                      ),
                                      const Icon(
                                        CupertinoIcons.chevron_down,
                                        color:
                                            AppColors.fitnessPrimaryTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: MediaQuery.of(context).size.height - 300,
                  child: exercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No exercises selected..',
                            style: TextStyle(
                                color: AppColors.fitnessSecondaryModuleColor,
                                fontSize: 16),
                          ),
                        )
                      : ReorderableListView(
                          proxyDecorator: (Widget child, int index,
                              Animation<double> animation) {
                            return Transform.scale(
                              scale: 1.05,
                              child: Material(
                                child: child,
                                color: Colors.transparent,
                                shadowColor: AppColors.fitnessBackgroundColor
                                    .withOpacity(0.3),
                                elevation: 6,
                              ),
                            );
                          },
                          scrollDirection: Axis.vertical,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = exercises.removeAt(oldIndex);
                              exercises.insert(newIndex, item);
                            });
                          },
                          children: exercises.map((exercise) {
                            return Container(
                              key: ValueKey(exercise.exerciseId),
                              child: exercise,
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 300,
        child: FloatingActionButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await _createWorkout();
                  setState(() {
                    _isLoading = false;
                  });
                },
          backgroundColor: AppColors.fitnessMainColor,
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.fitnessPrimaryTextColor),
                )
              : Text(
                  widget.preWorkout == null
                      ? "Create Workout"
                      : "Update Workout",
                  style:
                      const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                ),
        ),
      ),
    );
  }
}
