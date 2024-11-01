import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/components/ind_exercise_box.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_exercises_dao.dart';
import 'package:fitnessapp_idata2503/pages/exercise_selector.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../database/crud/workout_dao.dart';
import '../database/tables/exercise.dart';

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

  List<IndExerciseBox> exercises = [];

  createIndExerciseBox(String exerciseName) {
    return IndExerciseBox(
      key: ValueKey(exerciseName),
      exerciseName: exerciseName,
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
    if (_formKey.currentState!.validate()) {
      try {
        final result = await workoutDao.createWorkout(
          '', //TODO: IMPLEMENT WORKOUT CATEGORY
          _descriptionController.text,
          0, //TODO: IMPLEMENT WORKOUT DURATION
          0, //TODO: IMPLEMENT WORKOUT INTENSITY
          true, //TODO: IMPLEMENT WORKOUT PRIVATE
          widget.user!.uid,
          '', //TODO: IMPLEMENT WORKOUT URL
          _titleController.text,
          true
        );
        for (var exercise in exercises) {
           workoutExercisesDao.createWorkoutExercise(
            result!,
            exercise.exerciseName,
            0, //TODO: IMPLEMENT REPS
            0, //TODO: IMPLEMENT SETS
          );
        }
      } catch (e) {
        print(e);
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fitnessPrimaryTextColor,
                    ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fitnessPrimaryTextColor,
                    ),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExerciseSelectorPage(user: widget.user),
                        ),
                      );
                      if (result != null && result is List<Exercises>) {
                        for (var exercise in result) {
                          setState(() {
                            exercises.add(createIndExerciseBox(exercise.name));
                          });
                        }
                      }
                    },
                    child: const Text('+ Add Exercise to Workout',
                        style: TextStyle(color: AppColors.fitnessMainColor)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 300,
                  child: ReorderableListView(
                    proxyDecorator:
                        (Widget child, int index, Animation<double> animation) {
                      return Transform.scale(
                        scale: 1.05,
                        child: Material(
                          child: child,
                          color: Colors.transparent,
                          shadowColor:
                              AppColors.fitnessBackgroundColor.withOpacity(0.3),
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
          child: const Text("Create Workout"),
        ),
      ),
    );
  }
}