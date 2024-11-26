import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/crud/exercise_dao.dart';
import '../../database/tables/exercise.dart';
import 'create_exercise_page.dart';
import 'exercise_overview_detailed.dart';

/// Page to select exercises to add to a workout
/// The user can select exercises from their own exercises and public exercises
/// The user can also create a new exercise
/// The user can view an overview of an exercise by clicking on it
/// The user can add or remove exercises from the workout
///
/// Last Edited: 26/11/2024
/// Last Edited by: Håkon Svensen Karlsen

class ExerciseSelectorPage extends StatefulWidget {
  final List<Exercises> selectedExercises;

  const ExerciseSelectorPage({super.key, required this.selectedExercises});

  @override
  _ExerciseSelectorPageState createState() => _ExerciseSelectorPageState();
}


class _ExerciseSelectorPageState extends State<ExerciseSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  final ExerciseDao exerciseDao = ExerciseDao();
  final Map<String, Exercises> _selectedExercisesMap = {};
  List<Exercises> _allUserExercises = [];
  List<Exercises> _allPublicExercises = [];

  @override
  void initState() {
    super.initState();
    for (Exercises exercise in widget.selectedExercises) {
      _selectedExercisesMap[exercise.exerciseId!] = exercise;
    }
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final result = await exerciseDao
        .localFetchAllExercises(FirebaseAuth.instance.currentUser?.uid);
    setState(() {
      // Populate the list of exercises with users private exercises
      if (FirebaseAuth.instance.currentUser != null) {
        _allUserExercises = result['exercises']
            .where((exercise) =>
                exercise.userId == FirebaseAuth.instance.currentUser?.uid)
            .cast<Exercises>()
            .toList();
      }
      // Populate the list of exercises with public exercises
      _allPublicExercises = result['exercises']
          .where((exercise) => exercise.isPrivate == false)
          .where((exercise) =>
              exercise.userId != FirebaseAuth.instance.currentUser?.uid)
          .cast<Exercises>()
          .toList();
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
          title: Text(
            'Select Exercises',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.fitnessPrimaryTextColor,
                ),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.fitnessMainColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            if (FirebaseAuth.instance.currentUser != null)
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateExercisePage(),
                    ),
                  );
                  if (result == true) {
                    _fetchExercises(); // Reload exercises if a new exercise was created
                  }
                },
                child: const Text('Create Exercise',
                    style: TextStyle(color: AppColors.fitnessMainColor)),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  cursorColor: AppColors.fitnessPrimaryTextColor,
                  style: const TextStyle(
                      color: AppColors.fitnessPrimaryTextColor, fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Search for exercises',
                    labelStyle: TextStyle(
                        color: AppColors.fitnessPrimaryTextColor, fontSize: 20),
                    filled: true,
                    fillColor: AppColors.fitnessBackgroundColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.fitnessModuleColor),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.fitnessPrimaryTextColor),
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                    hintText: 'Workout Title..',
                    hintStyle: TextStyle(
                      color: AppColors.fitnessSecondaryTextColor,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
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
                                    _selectedExercisesMap
                                        .remove(exercise.exerciseId!);
                                  });
                                },
                                child: Chip(
                                  label: Text(
                                    exercise.name,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
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
                    if (FirebaseAuth.instance.currentUser != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Exercises',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
                if (FirebaseAuth.instance.currentUser != null)
                  const SizedBox(height: 16),
                if (FirebaseAuth.instance.currentUser?.uid != null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.fitnessModuleColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    constraints: const BoxConstraints(minHeight: 100),
                    child: _allUserExercises.isEmpty
                        ? Center(
                            child: Text(
                              'No exercises available.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _allUserExercises.length,
                              itemBuilder: (context, index) {
                                Exercises exercise = _allUserExercises[index];
                                if (_searchController.text.isEmpty ||
                                    exercise.name.toLowerCase().contains(
                                        _searchController.text.toLowerCase())) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.fitnessPrimaryTextColor,
                                        backgroundColor: AppColors
                                            .fitnessSecondaryModuleColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 12.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExerciseOverviewPage(
                                                    exercise: exercise),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            exercise.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _selectedExercisesMap.containsKey(
                                                      exercise.exerciseId!)
                                                  ? Icons.remove
                                                  : Icons.add,
                                              color: AppColors.fitnessMainColor,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (_selectedExercisesMap
                                                    .containsKey(
                                                        exercise.exerciseId!)) {
                                                  _selectedExercisesMap.remove(
                                                      exercise.exerciseId!);
                                                } else {
                                                  _selectedExercisesMap[exercise
                                                      .exerciseId!] = exercise;
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            )),
                  ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Premade Exercises',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fitnessModuleColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  constraints: const BoxConstraints(minHeight: 40),
                  child: _allPublicExercises.isEmpty
                      ? Center(
                          child: Text(
                            'No exercises available.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allPublicExercises.length,
                          itemBuilder: (context, index) {
                            Exercises exercise = _allPublicExercises[index];
                            if (_searchController.text.isEmpty ||
                                exercise.name.toLowerCase().contains(
                                    _searchController.text.toLowerCase())) {
                              return ListTile(
                                title: Text(
                                  exercise.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    _selectedExercisesMap
                                            .containsKey(exercise.exerciseId!)
                                        ? Icons.remove
                                        : Icons.add,
                                    color: AppColors.fitnessMainColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_selectedExercisesMap
                                          .containsKey(exercise.exerciseId!)) {
                                        _selectedExercisesMap
                                            .remove(exercise.exerciseId!);
                                      } else {
                                        _selectedExercisesMap[
                                            exercise.exerciseId!] = exercise;
                                      }
                                    });
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ExerciseOverviewPage(
                                              exercise: exercise),
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
            child: Text(
              'Add to Workout',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
      ),
    );
  }
}
