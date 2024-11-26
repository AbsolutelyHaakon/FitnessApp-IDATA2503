import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Page for setting up the user account
// Shown right after they register
// User can set their name, weight, weight goal, and height

// Last edited: 31/10/2024
// Last edited by: Håkon Svensen Karlsen
class AccountSetupPage extends StatefulWidget {
  const AccountSetupPage({super.key});

  @override
  _AccountSetupPageState createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _weightGoalController = TextEditingController();
  final _heightController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  void _updateUserData() {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      UserDao().fireBaseUpdateUserData(
        FirebaseAuth.instance.currentUser?.uid ?? '',
        _nameController.text,
        double.tryParse(_heightController.text) ?? 0,
        int.tryParse(_weightController.text) ?? 0,
        int.tryParse(_weightGoalController.text) ?? 0,
        int.tryParse(_weightController.text) ?? 0,
        _image,
        null,
        null,
        null,
        null,
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.fitnessBackgroundColor,
    body: Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to FitnessApp!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fitnessPrimaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Let\'s get started by setting up your account, making some goals, and choosing your workout plan.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fitnessPrimaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            _image == null ? AppColors.fitnessMainColor : null,
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path))
                            : null,
                        child: _image == null
                            ? const Icon(Icons.camera_alt,
                                size: 30,
                                color: AppColors.fitnessPrimaryTextColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fitnessBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Name',
                          hintStyle: const TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
                          ),
                        ),
                        style: const TextStyle(
                            color: AppColors.fitnessPrimaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Height (cm)',
                      style: TextStyle(color: AppColors.fitnessMainColor),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        width: 100,
                        height: 50,
                        child: CupertinoPicker(
                          itemExtent: 32.0,
                          scrollController:
                              FixedExtentScrollController(initialItem: 70),
                          onSelectedItemChanged: (int index) {
                            _heightController.text = (index + 100).toString();
                          },
                          children: List<Widget>.generate(171, (int index) {
                            return Center(
                              child: DefaultTextStyle(
                                style: const TextStyle(color: Colors.white),
                                child: Text('${index + 100}'),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Weight (kg)',
                      style: TextStyle(color: AppColors.fitnessMainColor),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: CupertinoPicker(
                          scrollController:
                              FixedExtentScrollController(initialItem: 40),
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            _weightController.text = (index + 30).toString();
                          },
                          children: List<Widget>.generate(270, (int index) {
                            return Center(
                              child: Text('${index + 30}',
                                  style: const TextStyle(
                                      color:
                                          AppColors.fitnessPrimaryTextColor)),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Weight Goal (kg)',
                      style: TextStyle(color: AppColors.fitnessMainColor),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: CupertinoPicker(
                          scrollController:
                              FixedExtentScrollController(initialItem: 40),
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            _weightGoalController.text =
                                (index + 30).toString();
                          },
                          children: List<Widget>.generate(270, (int index) {
                            return Center(
                              child: Text('${index + 30}',
                                  style: const TextStyle(
                                      color:
                                          AppColors.fitnessPrimaryTextColor)),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your name'),
                  backgroundColor: AppColors.fitnessWarningColor,
                ),
              );
            } else {
              _updateUserData();
              Navigator.of(context).pop();
            }
          },
          backgroundColor: AppColors.fitnessMainColor,
          child: const Text(
            "Create Profile",
            style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
          ),
        ),
      ),
    ),
  );
}
}
