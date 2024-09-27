import 'package:flutter/material.dart';

class Workout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        backgroundColor: Color(0xFF292929),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Workout page!',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}