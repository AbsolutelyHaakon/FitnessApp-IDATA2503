import 'package:fitnessapp_idata2503/modules/rings_module.dart';
import 'package:flutter/material.dart';
import '../modules/nutrition_module.dart';
import '../modules/today_module.dart';

// Landing page for the user
// Contains widgets to direct the user to specific pages
// The top bar is supposed to show a progress bar based on the user's progress
// Secondly, a calendar widget showing today´s workout plan
// Further down there are also these widgets planned:
// - A nutrition widget
// - An intake widget showing BMI, calories, and water intake as radial progress bars
// - A way to access the workout logs of previous

// Last edited: 27/09/2024
// Last edited by: All

//TODO: Create the progress bar as it´s own module
//TODO: Create the workout log page and their corresponding modules

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 27.0,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: Color(0xFF292929),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TodayModule(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NutritionModule(),
                RingsModule(),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}