// lib/pages/account_setup.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:flutter/material.dart';

// Page for setting up the user account
// Shown right after they register
// User can set their name, weight, weight goal, and height

// Last edited: 31/10/2024
// Last edited by: Håkon Svensen Karlsen
class AccountSetupPage extends StatefulWidget {
  final User? user;
  const AccountSetupPage({super.key, this.user});

  @override
  _AccountSetupPageState createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _weightGoalController = TextEditingController();
  final _heightController = TextEditingController();


  void _updateUserData() {
    print("adrian sin key: ${widget.user?.uid}");
    if (_formKey.currentState!.validate()) {
      UserDao().updateUserData(
        widget.user?.uid ?? '',
        _nameController.text,
        double.tryParse(_heightController.text) ?? 0.0,
        double.tryParse(_weightController.text) ?? 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Set background color here
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 100.0),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Let\'s get started by setting up your account, making some goals, and choosing your workout plan.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Color(0xFF48CC6D)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF48CC6D)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    labelStyle: TextStyle(color: Color(0xFF48CC6D)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF48CC6D)),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Weight Goal (kg)',
                    labelStyle: TextStyle(color: Color(0xFF48CC6D)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF48CC6D)),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight goal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    labelStyle: TextStyle(color: Color(0xFF48CC6D)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF48CC6D)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF48CC6D)),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                const Text(
                  'What would you like to do next?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _updateUserData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CC6D),
                  ),
                  child: const Text('Create a Workout',
                    style: TextStyle(color: Colors.white),),

                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle browse social feed action
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CC6D),
                  ),
                  child: const Text('Browse Social Feed',
                    style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}