import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/crud/exercise_dao.dart';
import '../../database/tables/exercise.dart';
import 'create_exercise_page.dart';
import 'exercise_overview_detailed.dart'; // Import the detailed overview page

class ExerciseSelectorPage extends StatefulWidget {
  final User? user;
  final List<Exercises> selectedExercises;

  const ExerciseSelectorPage(
      {super.key, this.user, required this.selectedExercises});

  @override
  _ExerciseSelectorPageState createState() => _ExerciseSelectorPageState();
}

class _ExerciseSelectorPageState extends State<ExerciseSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  final ExerciseDao exerciseDao = ExerciseDao();
  Map<String, Exercises> _selectedExercisesMap = {};
  List<Exercises> _allExercises = [];

  @override
  void initState() {
    super.initState();
    for (Exercises exercise in widget.selectedExercises) {
      _selectedExercisesMap[exercise.exerciseId!] = exercise;
    }
    print("selected exercises: ${_selectedExercisesMap.values.toList()}");
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final result = await exerciseDao.fetchAllExercises(widget.user!.uid);
    setState(() {
      _allExercises = result['exercises'].cast<Exercises>();
    });
  }

  Future<bool> _onWillPop() async {
    // Custom logic when back button is pressed
    Navigator.pop(context, _selectedExercisesMap.values.toList());
    return false; // Prevent default back button behavior
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.fitnessBackgroundColor,
          title: const Text('Select Exercises',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.fitnessMainColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 40.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  cursorColor: AppColors.fitnessMainColor,
                  style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  decoration: const InputDecoration(
                    labelText: 'Search for exercises',
                    labelStyle: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.fitnessMainColor),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    if (_selectedExercisesMap.values.toList().isEmpty)
                      const SizedBox(height: 48.0),
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 4.0,
                      children: _selectedExercisesMap.values
                          .map((exercise) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedExercisesMap.remove(exercise.exerciseId!);
                                  });
                                },
                                child: Chip(
                                  label: Text(
                                    exercise.name,
                                    style: const TextStyle(
                                        color: AppColors.fitnessPrimaryTextColor),
                                  ),
                                  backgroundColor: AppColors.fitnessMainColor,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Exercises',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateExercisePage(user: widget.user),
                            ),
                          );
                          if (result == true) {
                            _fetchExercises(); // Reload exercises if a new exercise was created
                          }
                        },
                        child: const Text('+ Add New Exercise',
                            style: TextStyle(color: AppColors.fitnessMainColor)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    // Makes the ListView use only as much height as its children
                    physics: const NeverScrollableScrollPhysics(),
                    // Disables scrolling to avoid conflicting with parent's scrolling
                    itemCount: _allExercises.length,
                    itemBuilder: (context, index) {
                      Exercises exercise = _allExercises[index];
                      if (_searchController.text.isEmpty ||
                          exercise.name.toLowerCase().contains(_searchController.text.toLowerCase())) {
                        return ListTile(
                          title: Text(
                            exercise.name,
                            style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              _selectedExercisesMap.containsKey(exercise.exerciseId!)
                                  ? Icons.remove
                                  : Icons.add,
                              color: AppColors.fitnessMainColor,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_selectedExercisesMap.containsKey(exercise.exerciseId!)) {
                                  _selectedExercisesMap.remove(exercise.exerciseId!);
                                } else {
                                  _selectedExercisesMap[exercise.exerciseId!] = exercise;
                                }
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseOverviewPage(exercise: exercise, user: widget.user),
                              ),
                            );
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Premade Exercises',
                    style: TextStyle(
                      color: AppColors.fitnessPrimaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 300,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context, _selectedExercisesMap.values.toList());
            },
            backgroundColor: AppColors.fitnessMainColor,
            child: const Text(
              'Add to Workout',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
            ),
          ),
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
      ),
    );
  }
}