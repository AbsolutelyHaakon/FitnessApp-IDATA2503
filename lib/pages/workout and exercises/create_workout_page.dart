import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/components/ind_exercise_box.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/exercise_selector.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../../database/crud/workout_dao.dart';
import '../../database/tables/exercise.dart';

class CreateWorkoutPage extends StatefulWidget {
  final User? user;

  const CreateWorkoutPage({super.key, this.user});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final FocusNode _descriptionFocusNode = FocusNode();
  bool _isDescriptionFocused = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final WorkoutDao workoutDao = WorkoutDao();
  final WorkoutExercisesDao workoutExercisesDao = WorkoutExercisesDao();
  bool _isPublic = false;

  List<Exercises> selectedExercises = [];
  List<IndExerciseBox> exercises = [];

  final List<String> _categories = [
    'Cardio',
    'Strength',
    'Flexibility',
    'High Intensity',
  ];

  int _intensity = 1;
  String _selectedCategory = 'Cardio';

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

  void _createWorkout() async {
  if (exercises.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Please add at least one exercise to the workout.',textAlign: TextAlign.center, ),
        backgroundColor: AppColors.fitnessWarningColor,
      ),
    );
    return;
  }

  if (_formKey.currentState!.validate()) {
    try {
      final result = await workoutDao.fireBaseCreateWorkout(
          _selectedCategory,
          _descriptionController.text,
          0, // TODO: Implement workout duration
          _intensity,
          !_isPublic,
          widget.user!.uid,
          '', // TODO: Implement workout URL
          _titleController.text,
          true,
          0, // TODO: Implement workout calories
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
      print(e);
      // Optionally, show an error dialog or message here
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _titleController,
                    cursorColor: AppColors.fitnessMainColor,
                    style: Theme.of(context).textTheme.displayLarge,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.fitnessBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Workout Title..',
                      hintStyle: const TextStyle(
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isDescriptionFocused
                      ? MediaQuery.of(context).size.height * 0.2
                      : 60,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    cursorColor: AppColors.fitnessMainColor,
                    style: Theme.of(context).textTheme.displayMedium,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.fitnessBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Description..',
                      hintStyle: const TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(3, (index) {
                          return IconButton(
                            icon: Icon(
                              Icons.whatshot,
                              color: index < _intensity
                                  ? AppColors.fitnessMainColor
                                  : AppColors.fitnessSecondaryTextColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _intensity = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        items: _categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(
                                    color: AppColors.fitnessPrimaryTextColor)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        dropdownColor: AppColors.fitnessBackgroundColor,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          Switch(
                            value: _isPublic,
                            onChanged: (value) {
                              setState(() {
                                _isPublic = value;
                              });
                            },
                            activeColor: AppColors.fitnessMainColor,
                          ),
                          const SizedBox(width: 10),
                          const Text('Public',
                              style: TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseSelectorPage(
                                user: widget.user,
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
                      child: const Text('+ Add Exercise to Workout',
                          style: TextStyle(color: AppColors.fitnessMainColor)),
                    ),
                  ],
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
                          children: exercises,
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
          onPressed: _createWorkout,
          backgroundColor: AppColors.fitnessMainColor,
          child: const Text(
            "Create Workout",
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
          ),
        ),
      ),
    );
  }
}
