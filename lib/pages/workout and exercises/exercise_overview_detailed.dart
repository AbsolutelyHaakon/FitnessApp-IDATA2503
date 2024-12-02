// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/tables/exercise.dart';
import '../../styles.dart';

class ExerciseOverviewPage extends StatefulWidget {
  final Exercises exercise; // Marked as final since it's not modified

  const ExerciseOverviewPage(
      {super.key, required this.exercise}); // Added key and super

  @override
  _ExerciseOverviewPageState createState() => _ExerciseOverviewPageState();
}

class _ExerciseOverviewPageState extends State<ExerciseOverviewPage> {
  bool _isEditing = false; // To track if the user is in edit mode
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _categoryController;
  late bool _isPublic; // To track if the exercise is public or private
  bool isAdmin = false; // To track if the user is an admin
  XFile? _imageFile; // To store the selected image file

  final ExerciseDao _exerciseDao = ExerciseDao();

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the exercise data
    _nameController = TextEditingController(text: widget.exercise.name);
    _descriptionController =
        TextEditingController(text: widget.exercise.description);
    _videoUrlController = TextEditingController(text: widget.exercise.videoUrl);
    _categoryController = TextEditingController(text: widget.exercise.category);
    _isPublic = !widget.exercise.isPrivate;
    checkAdminStatus(); // Check if the user is an admin
  }

  @override
  void dispose() {
    // Dispose the text controllers to free up resources
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _toggleEdit() =>
      setState(() => _isEditing = !_isEditing); // Toggle edit mode

  void checkAdminStatus() async {
    // Check if the user is an admin
    if (await UserDao()
        .getAdminStatus(FirebaseAuth.instance.currentUser?.uid)) {
      setState(() {
        isAdmin = true;
      });
    } else {
      setState(() {
        widget.exercise.userId == FirebaseAuth.instance.currentUser?.uid;
      });
    }
  }

  Future<void> _saveChanges() async {
    // Save the changes made to the exercise
    final result = await _exerciseDao.fireBaseUpdateExercise(
        widget.exercise.exerciseId,
        _nameController.text,
        _descriptionController.text,
        _categoryController.text,
        widget.exercise.videoUrl,
        // Implement videoUrl editing
        widget.exercise.imageURL,
        _imageFile,
        // Implement image editing
        !_isPublic,
        widget.exercise.userId);
    if (result.containsKey('exerciseId')) {
      setState(() {
        // Update the exercise data with the new values
        widget.exercise.name = _nameController.text;
        widget.exercise.description = _descriptionController.text;
        widget.exercise.category = _categoryController.text;
        widget.exercise.isPrivate = !_isPublic;
        _isEditing = false; // Exit edit mode
      });
      _showSnackBar('Exercise saved', Icons.check, AppColors.fitnessMainColor);
    }
  }

  void _showSnackBar(String message, IconData icon, Color backgroundColor) {
    // Show a snackbar with a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _pickImage() async {
    // Pick an image from the gallery
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile; // Store the selected image file
      });
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
          onPressed: () =>
              Navigator.of(context).pop(), // Go back to the previous screen
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete,
                  color: AppColors.fitnessWarningColor),
              onPressed: _deleteExercise, // Delete the exercise
            ),
          if (widget.exercise.userId ==
                  FirebaseAuth.instance.currentUser?.uid ||
              isAdmin)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.cancel_outlined : Icons.edit,
                color: AppColors.fitnessMainColor,
              ),
              onPressed: _toggleEdit, // Toggle edit mode
            ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: _buildBody(), // Build the body of the screen
      bottomNavigationBar: _isEditing
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _saveChanges, // Save the changes
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fitnessMainColor,
                ),
                child: const Text('Save',
                    style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
              ),
            )
          : null,
    );
  }

  Future<void> _deleteExercise() async {
    // Show a confirmation dialog before deleting the exercise
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.fitnessModuleColor,
          title: const Text('Confirm Deletion',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          content: const Text('Are you sure you want to delete this exercise?',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Cancel deletion
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Confirm deletion
              child: const Text('OK',
                  style: TextStyle(color: AppColors.fitnessWarningColor)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Delete the exercise if confirmed
      final result =
          await _exerciseDao.fireBaseDeleteExercise(widget.exercise.exerciseId);
      if (result) {
        _showSnackBar(
            'Exercise deleted', Icons.delete, AppColors.fitnessWarningColor);
        Navigator.of(context).pop(); // Go back to the previous screen
      }
    }
  }

  Widget _buildBody() {
    // Build the body of the screen
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _isEditing
                ? TextField(
                    controller: _nameController,
                    style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.fitnessPrimaryTextColor,
                        fontWeight: FontWeight.w900),
                    decoration: _inputDecoration(
                        'Exercise Name'), // Input decoration for the name field
                  )
                : Text(
                    widget.exercise.name,
                    style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.fitnessPrimaryTextColor,
                        fontWeight: FontWeight.w900),
                  ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap:
                _isEditing ? _pickImage : null, // Pick an image if in edit mode
            child: _imageFile != null
                ? Image.file(
                    File(_imageFile!.path),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : widget.exercise.imageURL != null &&
                        widget.exercise.imageURL!.isNotEmpty
                    ? Image.network(
                        widget.exercise.imageURL!,
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        color: AppColors.fitnessSecondaryModuleColor,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image,
                                size: 100, color: AppColors.fitnessMainColor),
                            Text(
                              'No Image',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.fitnessPrimaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryAndPrivacy(), // Build the category and privacy section
                const SizedBox(height: 20),
                _isEditing
                    ? TextField(
                        controller: _descriptionController,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.fitnessPrimaryTextColor),
                        decoration: _inputDecoration(
                            'Description'), // Input decoration for the description field
                        minLines: 1,
                        maxLines: null,
                      )
                    : widget.exercise.description != null &&
                            widget.exercise.description!.isNotEmpty
                        ? Text(
                            widget.exercise.description!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.fitnessPrimaryTextColor,
                                fontWeight: FontWeight.w400),
                          )
                        : Container(
                            padding: const EdgeInsets.all(8.0),
                            width: double.infinity,
                            child: const Text(
                              'No description...',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.fitnessSecondaryTextColor,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndPrivacy() {
    // Build the category and privacy section
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _isEditing
            ? SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: officialWorkoutCategories
                          .contains(_categoryController.text)
                      ? _categoryController.text
                      : null,
                  items: officialWorkoutCategories
                      .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category,
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor))))
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => _categoryController.text = newValue!),
                  decoration: _inputDecoration(
                      'Category'), // Input decoration for the category field
                  dropdownColor: AppColors.fitnessBackgroundColor,
                ),
              )
            : Text(widget.exercise.category ?? '',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.fitnessPrimaryTextColor)),
        if (_isEditing)
          Row(
            children: [
              const Text('Public: ',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.fitnessPrimaryTextColor)),
              Transform.scale(
                scale: .8,
                child: Switch(
                  value: _isPublic,
                  onChanged: (value) => setState(
                      () => _isPublic = value), // Toggle public/private status
                  activeColor: AppColors.fitnessMainColor,
                ),
              )
            ],
          )
        else
          Text(
            _isPublic ? "Public" : "Private",
            style: TextStyle(
                fontSize: 14,
                color: _isPublic
                    ? AppColors.fitnessMainColor
                    : AppColors.fitnessSecondaryTextColor),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        filled: true,
        fillColor: AppColors.fitnessBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintText: label,
        hintStyle: const TextStyle(color: AppColors.fitnessSecondaryTextColor),
      );
}
