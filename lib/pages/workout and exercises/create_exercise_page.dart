import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class CreateExercisePage extends StatefulWidget {
  final User? user;

  const CreateExercisePage({super.key, this.user});

  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final ExerciseDao exerciseDao = ExerciseDao();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPublic = false;
  String _selectedCategory = 'Strength';

  final List<String> _categories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Balance'
  ];

  Future<void> _createExercise() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await exerciseDao.createExercise(
          _nameController.text,
          _descriptionController.text,
          _selectedCategory,
          _videoUrlController.text,
          !_isPublic,
          widget.user!.uid,
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.fitnessBackgroundColor,
        title: const Text('Create Exercise',
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  cursorColor: AppColors.fitnessMainColor,
                  style:
                      const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    labelStyle:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.fitnessMainColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an exercise name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  cursorColor: AppColors.fitnessMainColor,
                  style:
                      const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.fitnessMainColor),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _videoUrlController,
                  cursorColor: AppColors.fitnessMainColor,
                  style:
                      const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  decoration: const InputDecoration(
                    labelText: 'Video URL',
                    labelStyle:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.fitnessMainColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category,
                          style: const TextStyle(
                              color: AppColors.fitnessPrimaryTextColor)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle:
                        TextStyle(color: AppColors.fitnessPrimaryTextColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.fitnessMainColor),
                    ),
                  ),
                  dropdownColor: AppColors.fitnessBackgroundColor,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Public',
                        style: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                    Switch(
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    await _createExercise();
                    Navigator.of(context).pop(true); // Return true to indicate a new exercise was created
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fitnessMainColor,
                  ),
                  child: const Text('Save Exercise',
                      style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
