import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class IndPersonalBestModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Bests',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.fitnessBackgroundColor,
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: const Center(
        child: Text('Hi there, you stink!'),
      ),
    );
  }
}
