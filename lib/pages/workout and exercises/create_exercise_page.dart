import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:image_picker/image_picker.dart';

class CreateExercisePage extends StatefulWidget {
  final User? user;

  const CreateExercisePage({super.key, this.user});

  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final exerciseDao = ExerciseDao();
  bool _isPublic = false;
  String _selectedCategory = 'Strength';
  final List<String> _categories = ['Strength', 'Cardio', 'Flexibility', 'Balance'];
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _createExercise() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await exerciseDao.fireBaseCreateExercise(
          _nameController.text,
          _descriptionController.text,
          _selectedCategory,
          _videoUrlController.text,
          !_isPublic,
          widget.user?.uid ?? '',
        );
        Navigator.of(context).pop(true); // Return true to indicate a new exercise was created
      } catch (e) {
        print('Error creating exercise: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
      filled: true,
      fillColor: AppColors.fitnessBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      hintText: label,
      hintStyle: const TextStyle(
          color: AppColors.fitnessSecondaryTextColor,
      ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.fitnessBackgroundColor,
        title: const Text('Create Exercise',
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image, color: AppColors.fitnessMainColor),
            onPressed: _pickImage,
          ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        cursorColor: AppColors.fitnessMainColor,
                        style: const TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _inputDecoration('Exercise Name..'),
                        validator: (value) =>
                            (value?.isEmpty ?? true) ? 'Please enter an exercise name' : null,
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _descriptionController,
                        cursorColor: AppColors.fitnessMainColor,
                        style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                        decoration: _inputDecoration('Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _videoUrlController,
                        cursorColor: AppColors.fitnessMainColor,
                        style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                        decoration: _inputDecoration('Video URL'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category,
                              style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                        )).toList(),
                        onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
                        decoration: _inputDecoration('Category'),
                        dropdownColor: AppColors.fitnessBackgroundColor,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Public', style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                            Switch(
                              value: _isPublic,
                              onChanged: (value) => setState(() => _isPublic = value),
                              activeColor: AppColors.fitnessMainColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 300,
        child: FloatingActionButton(
          onPressed: _createExercise,
          backgroundColor: AppColors.fitnessMainColor,
          child: const Text(
            "Create Exercise",
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
          ),
        ),
      ),
    );
  }
}