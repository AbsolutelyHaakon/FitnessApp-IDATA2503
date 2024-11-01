import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/crud/exercise_dao.dart';
import '../database/tables/exercise.dart';
import 'create_exercise_page.dart';

class ExerciseSelectorPage extends StatefulWidget {
  final User? user;

  const ExerciseSelectorPage({super.key, this.user});

  @override
  _ExerciseSelectorPageState createState() => _ExerciseSelectorPageState();
}

class _ExerciseSelectorPageState extends State<ExerciseSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  final ExerciseDao exerciseDao = ExerciseDao();
  List<Exercises> _selectedExercises = [];
  List<Exercises> _allExercises = [];

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final result = await exerciseDao.fetchAllExercises(widget.user!.uid);
    setState(() {
      _allExercises = result['exercises'].cast<Exercises>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                style:
                    const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Search for exercises',
                  labelStyle:
                      TextStyle(color: AppColors.fitnessPrimaryTextColor),
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
                  if (_selectedExercises.isEmpty) const SizedBox(height: 48.0),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 4.0,
                    children: _selectedExercises
                        .map((exercise) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedExercises.remove(exercise);
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
              const SizedBox(height: 0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateExercisePage(user: widget.user),
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
              const SizedBox(height: 16),
              Container(
                height: 400.0, // Set a fixed height for the ListView
                child: ListView.builder(
                  itemCount: _allExercises.length,
                  itemBuilder: (context, index) {
                    Exercises exercise = _allExercises[index];
                    if (_searchController.text.isEmpty ||
                        exercise.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase())) {
                      return ListTile(
                        title: Text(exercise.name,
                            style: const TextStyle(
                                color: AppColors.fitnessPrimaryTextColor)),
                        trailing: IconButton(
                          icon: Icon(
                            _selectedExercises.contains(exercise)
                                ? Icons.remove
                                : Icons.add,
                            color: AppColors.fitnessMainColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_selectedExercises.contains(exercise)) {
                                _selectedExercises.remove(exercise);
                              } else {
                                _selectedExercises.add(exercise);
                              }
                            });
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedExercises);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fitnessMainColor,
                    ),
                    child: const Text('Add to Workout',
                        style: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}