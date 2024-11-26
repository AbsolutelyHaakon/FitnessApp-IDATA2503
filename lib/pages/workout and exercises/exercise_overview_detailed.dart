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

  const ExerciseOverviewPage({Key? key, required this.exercise})
      : super(key: key); // Added key and super

  @override
  _ExerciseOverviewPageState createState() => _ExerciseOverviewPageState();
}

class _ExerciseOverviewPageState extends State<ExerciseOverviewPage> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _categoryController;
  late bool _isPublic;
  bool isAdmin = false;
  XFile? _imageFile;

  final ExerciseDao _exerciseDao = ExerciseDao();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _descriptionController =
        TextEditingController(text: widget.exercise.description);
    _videoUrlController = TextEditingController(text: widget.exercise.videoUrl);
    _categoryController = TextEditingController(text: widget.exercise.category);
    _isPublic = !widget.exercise.isPrivate;
    checkAdminStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _toggleEdit() => setState(() => _isEditing = !_isEditing);

  void checkAdminStatus() async {
    if (await UserDao().getAdminStatus(FirebaseAuth.instance.currentUser?.uid)) {
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
        widget.exercise.name = _nameController.text;
        widget.exercise.description = _descriptionController.text;
        widget.exercise.category = _categoryController.text;
        widget.exercise.isPrivate = _isPublic;
        _isEditing = false;
      });
      _showSnackBar('Exercise saved', Icons.check);
    }
  }

  void _showSnackBar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.fitnessMainColor,
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.exercise.userId == FirebaseAuth.instance.currentUser?.uid || isAdmin)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.cancel_outlined : Icons.edit,
                color: AppColors.fitnessMainColor,
              ),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: _buildBody(),
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

  Widget _buildBody() {
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
                    decoration: _inputDecoration('Exercise Name'),
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
            onTap: _isEditing ? _pickImage : null,
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
                _buildCategoryAndPrivacy(),
                const SizedBox(height: 20),
                _isEditing
                    ? TextField(
                        controller: _descriptionController,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.fitnessPrimaryTextColor),
                        decoration: _inputDecoration('Description'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _isEditing
            ? SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: officialWorkoutCategories.contains(_categoryController.text)
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
                  decoration: _inputDecoration('Category'),
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
                  onChanged: (value) => setState(() => _isPublic = value),
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