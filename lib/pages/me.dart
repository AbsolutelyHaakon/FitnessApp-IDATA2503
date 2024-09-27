import 'package:flutter/material.dart';

class Me extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
        backgroundColor: Color(0xFF292929),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Me page!',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}