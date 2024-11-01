import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class CreateExercisePage extends StatefulWidget {
  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  bool _isPublic = false;
  String _selectedCategory = 'Strength';

  final List<String> _categories = ['Strength', 'Cardio', 'Flexibility', 'Balance'];

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  labelStyle: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _videoUrlController,
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  labelStyle: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Public', style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: AppColors.fitnessPrimaryTextColor),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                ),
                dropdownColor: AppColors.fitnessBackgroundColor, // Set the backdrop color to black
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Save exercise functionality
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
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}