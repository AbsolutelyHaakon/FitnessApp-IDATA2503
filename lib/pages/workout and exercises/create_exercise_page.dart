import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:image_picker/image_picker.dart';

// This page allows users to create a new exercise
class CreateExercisePage extends StatefulWidget {
  const CreateExercisePage({super.key});

  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  // Controllers for the text fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final exerciseDao = ExerciseDao();
  bool _isPublic = false;
  String _selectedCategory = 'Strength';
  final List<String> _categories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Balance'
  ];
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  // Function to create a new exercise
  Future<void> _createExercise() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await exerciseDao.fireBaseCreateExercise(
          _nameController.text,
          _descriptionController.text,
          _selectedCategory,
          _videoUrlController.text,
          _selectedImage,
          !_isPublic,
          FirebaseAuth.instance.currentUser?.uid ?? '',
        );
        Navigator.of(context)
            .pop(true); // Return true to indicate a new exercise was created
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: AppColors.fitnessPrimaryTextColor),
                  const SizedBox(width: 8),
                  Text('Error creating exercise: $e'),
                ],
              ),
              backgroundColor: AppColors.fitnessWarningColor
            ),
          );
      }
    }
  }

  // Function to show the category picker
  void _showCategoryPicker(BuildContext context) {
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
              _selectedCategory = _categories[index];
            });
          },
          children: _categories.map((String value) {
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

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Function to create input decoration for text fields
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
        title: Text(
          'Create Exercise',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.fitnessPrimaryTextColor,
              ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                      // Text field for exercise name
                      TextFormField(
                        controller: _nameController,
                        cursorColor: AppColors.fitnessMainColor,
                        style: const TextStyle(
                            color: AppColors.fitnessPrimaryTextColor,
                            fontSize: 25),
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name',
                          labelStyle: TextStyle(
                              color: AppColors.fitnessMainColor, fontSize: 25),
                          filled: true,
                          fillColor: AppColors.fitnessBackgroundColor,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.fitnessModuleColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.fitnessPrimaryTextColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 12.0),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          hintText: 'Exercise Name..',
                          hintStyle: TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text field for exercise description
                          Flexible(
                            child: TextFormField(
                              controller: _descriptionController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              cursorColor: AppColors.fitnessPrimaryTextColor,
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor,
                                  fontSize: 16),
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                labelStyle: TextStyle(
                                    color: AppColors.fitnessMainColor,
                                    fontSize: 14),
                                filled: true,
                                fillColor: AppColors.fitnessBackgroundColor,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.fitnessModuleColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.fitnessMainColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
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
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Text field for video URL
                          Expanded(
                            child: TextFormField(
                              controller: _videoUrlController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              cursorColor: AppColors.fitnessPrimaryTextColor,
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor,
                                  fontSize: 16),
                              decoration: const InputDecoration(
                                labelText: 'Video URL',
                                labelStyle: TextStyle(
                                    color: AppColors.fitnessMainColor,
                                    fontSize: 14),
                                filled: true,
                                fillColor: AppColors.fitnessBackgroundColor,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.fitnessModuleColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.fitnessMainColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 12.0),
                                errorStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                hintText: 'Video URL',
                                hintStyle: TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Info button for video URL
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: AppColors.fitnessMainColor),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.black,
                                    title: const Text('Info',
                                        style: TextStyle(color: Colors.white)),
                                    content: const Text(
                                        'This video can be used to help anyone trying to do this workout with an instructional video.',
                                        style: TextStyle(color: Colors.white)),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Category picker
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showCategoryPicker(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 16.0),
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
                          const SizedBox(width: 16),
                          // Button to pick an image
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image,
                                  color: AppColors.fitnessPrimaryTextColor),
                              label: const Text(
                                'Add Image',
                                style: TextStyle(
                                    color: AppColors.fitnessPrimaryTextColor),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.fitnessMainColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Display selected image
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.file(
                              File(_selectedImage!.path),
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Public switch
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
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