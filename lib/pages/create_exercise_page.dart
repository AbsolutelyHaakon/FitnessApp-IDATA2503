import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateExercisePage extends StatefulWidget {
  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedExercises = [];
  List<String> _allExercises = ['Push Up', 'Squat', 'Pull Up', 'Bench Press', 'Leg Extensions', 'Hammercurls'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.fitnessBackgroundColor,
        title: const Text('Create Exercise',
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
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
                  if (_selectedExercises.isEmpty)
                    const SizedBox(height: 48.0), // Display this SizedBox if _selectedExercises is empty
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 4.0,
                    children: _selectedExercises
                        .map((exercise) => Chip(
                              label: Text(
                                exercise,
                                style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                              ),
                              backgroundColor: AppColors.fitnessMainColor,
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Add new exercise functionality
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
                    String exercise = _allExercises[index];
                    if (_searchController.text.isEmpty ||
                        exercise.toLowerCase().contains(_searchController.text.toLowerCase())) {
                      return ListTile(
                        title: Text(exercise,
                            style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                        trailing: IconButton(
                          icon: Icon(
                            _selectedExercises.contains(exercise) ? Icons.remove : Icons.add,
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
                      // Add to workout functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fitnessMainColor,
                    ),
                    child: const Text('Add to Workout',
                        style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
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