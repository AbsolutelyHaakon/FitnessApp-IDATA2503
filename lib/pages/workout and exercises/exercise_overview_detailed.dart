import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/tables/exercise.dart';
import '../../styles.dart';

class ExerciseOverviewPage extends StatefulWidget {
  final User? user;
  Exercises exercise;

  ExerciseOverviewPage({this.user,required this.exercise});

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
    //TODO: IMPLEMENT THIS
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
              icon: Icon(_isEditing ? Icons.check : Icons.edit,
                  color: AppColors.fitnessMainColor),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Exercise Name',
                        labelStyle: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                  )
                : Text(widget.exercise.name,
                    style: const TextStyle(
                        fontSize: 36,
                        color: AppColors.fitnessPrimaryTextColor)),
            const SizedBox(height: 20),
            _isEditing
                ? TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                  )
                : Text('Description: ${widget.exercise.description}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.fitnessPrimaryTextColor)),
            SizedBox(height: 10),
            _isEditing
                ? TextField(
                    controller: _videoUrlController,
                    decoration: const InputDecoration(
                        labelText: 'Video URL',
                        labelStyle: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                  )
                : Text('Video URL: ${widget.exercise.videoUrl}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.fitnessPrimaryTextColor)),
            SizedBox(height: 10),
            _isEditing
                ? TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(
                            color: AppColors.fitnessPrimaryTextColor)),
                  )
                : Text('Category: ${widget.exercise.category}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.fitnessPrimaryTextColor)),
            const SizedBox(height: 10),
            _isEditing
                ? Row(
                    children: [
                      const Text('Public: ',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.fitnessPrimaryTextColor)),
                      Switch(
                          value: _isPublic,
                          onChanged: (value) {
                            setState(() {
                              _isPublic = value;
                            });
                          },
                          activeColor: AppColors.fitnessMainColor),
                    ],
                  )
                : Text('Public: ${widget.exercise.isPrivate ? "Yes" : "No"}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.fitnessPrimaryTextColor)),
          ],
        ),
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
}
