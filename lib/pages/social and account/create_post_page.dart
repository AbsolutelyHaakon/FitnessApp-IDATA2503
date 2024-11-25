import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../database/crud/posts_dao.dart';
import '../../styles.dart';

/// CreatePostPage which allows the user to create a post
///
/// Last edited: 13.11.2024
/// Last edited by: Håkon Karlsen
///
/// TODO: Implement post creation logic
/// TODO: Implement attach exercise logic

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  String? _message;
  List<String> _workoutStats = [];
  String? _workoutId;
  String? _location;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLocationFieldVisible = false;
  final FocusNode _locationFocusNode = FocusNode();
  bool _isSubmitting = false;

  final PostsDao _postsDao = PostsDao();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _createPost() async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _postsDao.fireBaseCreatePost(
      _message,
      _selectedImage,
      "", // TODO: implement workout
      _location,
      _workoutStats,
      FirebaseAuth.instance.currentUser!.uid,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (result['success']) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
            style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.fitnessWarningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: AppColors.fitnessModuleColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: AppColors.fitnessModuleColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          style: const TextStyle(
                            color: AppColors.fitnessPrimaryTextColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'What\'s on your mind?',
                            hintStyle: const TextStyle(
                              color: AppColors.fitnessSecondaryTextColor,
                            ),
                          ),
                          onSaved: (value) {
                            _message = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Handle attach exercise logic
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.fitnessMainColor,
                          ),
                          child: const Text('Attach Workout >'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: _selectedImage != null
                                  ? Stack(
                                      children: [
                                        Image.file(
                                          File(_selectedImage!.path),
                                          height: 250,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedImage = null;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: AppColors.fitnessModuleColor,
                                      child: Center(
                                        child: Container(
                                          width: 220,
                                          height: 120,
                                          color: AppColors.fitnessSecondaryModuleColor,
                                          child: const Icon(
                                            Icons.image,
                                            color: AppColors.fitnessPrimaryTextColor,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _isLocationFieldVisible
                    ? Row(
                        children: [
                          Transform.scale(
                            scale: 0.7,
                            child: const Icon(Icons.location_on, color: AppColors.fitnessMainColor),
                          ),
                          Expanded(
                            child: TextFormField(
                              focusNode: _locationFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Location",
                                hintStyle: const TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                ),
                              ),
                              style: const TextStyle(
                                color: AppColors.fitnessPrimaryTextColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                              onSaved: (value) {
                                _location = value;
                              },
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isLocationFieldVisible = true;
                            });
                            Future.delayed(Duration(milliseconds: 100), () {
                              FocusScope.of(context).requestFocus(_locationFocusNode);
                            });
                          },
                          child: const Text(
                            '+ Add location',
                            style: TextStyle(color: AppColors.fitnessMainColor),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 300,
        child: FloatingActionButton(
          backgroundColor: AppColors.fitnessMainColor,
          onPressed: _isSubmitting
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _createPost();
                  }
                },
          child: _isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.fitnessPrimaryTextColor),
                )
              : const Text(
                  'Create Post',
                  style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
