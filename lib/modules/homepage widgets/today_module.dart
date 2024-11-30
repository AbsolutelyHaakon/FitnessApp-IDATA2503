import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// This module displays the workout plan for today
// If there is no workout planned, it will show a "no workout today" message
// TODO: Link this to the actual calendar once persistent storage is implemented
// TODO: Set a default message if there is no workout planned for the day
class TodayModule extends StatelessWidget {
  const TodayModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Open pre workout page
          // TODO: Implement navigation to pre workout page
        },
        child: Container(
          width: 400, // Width of the container
          height: 200, // Height of the container
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor, // Background color of the container
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          child: const Icon(
            CupertinoIcons.calendar_today, // Icon to represent today's workout
            color: AppColors.fitnessMainColor, // Color of the icon
            size: 100, // Size of the icon
          ),
        ),
      ),
    );
  }
}