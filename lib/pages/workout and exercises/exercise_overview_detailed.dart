import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/tables/exercise.dart';
import '../../styles.dart';

class ExerciseOverviewPage extends StatefulWidget {
  final User? user;
  Exercises exercise;

  ExerciseOverviewPage({this.user, required this.exercise});

  @override
  _ExerciseOverviewPageState createState() => _ExerciseOverviewPageState();
}

class _ExerciseOverviewPageState extends State<ExerciseOverviewPage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoUrlController;
  late TextEditingController _categoryController;
  late bool _isPublic;

  final List<String> _categories = [
    'Strength',
    'Cardio',
    'Flexibility',
    'Balance'
  ];

  final ExerciseDao _exerciseDao = ExerciseDao();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _descriptionController =
        TextEditingController(text: widget.exercise.description);
    _videoUrlController = TextEditingController(text: widget.exercise.videoUrl);
    _categoryController = TextEditingController(text: widget.exercise.category);
    _isPublic = widget.exercise.isPrivate;

  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
  _exerciseDao.fireBaseUpdateExercise(
    widget.exercise.exerciseId,
    _nameController.text,
    _descriptionController.text,
    _categoryController.text,
    widget.exercise.videoUrl, // TODO: Implement videoUrl editing
    widget.exercise.imageURL, // TODO: Implement image editing
    _isPublic,
    widget.user?.uid,
  ).then((result) {
    if (result.containsKey('exerciseId')) {
      setState(() {
        widget.exercise.name = _nameController.text;
        widget.exercise.description = _descriptionController.text;
        widget. exercise.category = _categoryController.text;
        widget.exercise.isPrivate = _isPublic;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Exercise saved'),
            ],
          ),
          backgroundColor: AppColors.fitnessMainColor,
        ),
      );
    }
  });
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
        actions: [
          if (widget.exercise.userId == widget.user!.uid)
            IconButton(
              icon: Icon(_isEditing ? Icons.cancel_outlined : Icons.edit,
                  color: AppColors.fitnessMainColor),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: Column(
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
            )
                : Text(widget.exercise.name,
                style: const TextStyle(
                    fontSize: 32,
                    color: AppColors.fitnessPrimaryTextColor,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          if (widget.exercise.imageURL != null && widget.exercise.imageURL!.isNotEmpty)
            Image.network(
              widget.exercise.imageURL!,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _isEditing
                        ? SizedBox(
                      width: 150, // Set the desired width
                      child: DropdownButtonFormField<String>(
                        value: _categoryController.text,
                        items: _categories
                            .map((category) =>
                            DropdownMenuItem(
                              value: category,
                              child: Text(category,
                                  style: const TextStyle(
                                      color: AppColors
                                          .fitnessPrimaryTextColor)),
                            ))
                            .toList(),
                        onChanged: (newValue) =>
                            setState(
                                    () => _categoryController.text = newValue!),
                        decoration: _inputDecoration('Category'),
                        dropdownColor: AppColors.fitnessBackgroundColor,
                      ),
                    )
                        : Text(widget.exercise.category ?? '',
                        style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.fitnessPrimaryTextColor)),
                    if (_isEditing)
                      Row(
                        children: [
                          const Text('Public: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.fitnessPrimaryTextColor)),
                          Transform.scale(
                            scale: .8,
                            child: Switch(
                              value: _isPublic,
                              onChanged: (value) {
                                setState(() {
                                  _isPublic = value;
                                });
                              },
                              activeColor: AppColors.fitnessMainColor,
                            ),
                          )
                        ],
                      )
                    else
                      Text(widget.exercise.isPrivate ? "Public" : "Private",
                          style: TextStyle(
                              fontSize: 14,
                              color: widget.exercise.isPrivate
                                  ? AppColors.fitnessMainColor
                                  : AppColors.fitnessSecondaryTextColor)),
                  ],
                ),
                const SizedBox(height: 20),
                _isEditing
                    ? TextField(
                  controller: _descriptionController,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w500,
                    color: AppColors
                        .fitnessPrimaryTextColor,
                  ),
                  minLines: 1,
                  maxLines: null,
                )
                    : Text(widget.exercise.description ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.fitnessPrimaryTextColor,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isEditing
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveChanges,
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

  InputDecoration _inputDecoration(String label) =>
      InputDecoration(
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
}
