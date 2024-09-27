// lib/modules/nutrition_module.dart
import 'package:fitnessapp_idata2503/pages/pre_workout_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Module for showing the workout plan for today
// If there is no workout planned for the day, it will display a "no workout today" message

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

//TODO: Link this to the actual calendar once persistent storage is implemented
//TODO: Set a default message if there is no workout planned for the day
class TodayModule extends StatelessWidget {
  const TodayModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Open pre workout page
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const PreWorkoutScreen(),
            ),
          );
        },
        child: Container(
          width: 410,
          height: 200,
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            CupertinoIcons.calendar_today,
            color: Color(0xFF48CC6D),
            size: 100,
          ),
        ),
      ),

    );
  }
}