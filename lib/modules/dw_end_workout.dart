import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

// Shows the selected workout plan details before deciding to start it
// Displays workout info and potentially a map of the workout route

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

//TODO: Implement map fucntionality
//TODO: Connect it to the persistent storage

class DwEndWorkout extends StatefulWidget {
  const DwEndWorkout({super.key});

  @override
  _DwEndWorkoutState createState() => _DwEndWorkoutState();
}

class _DwEndWorkoutState extends State<DwEndWorkout> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Color(0xFF262626), // Almost the same color
                  width: 1.0, // Very thin
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoButton(
                    onPressed: () {},
                    child: Container(
                      width: 410,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(0xFFCC4848),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "End Workout",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}