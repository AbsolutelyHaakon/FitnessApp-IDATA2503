import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../styles.dart';

class CalendarHomeModule extends StatelessWidget {
  const CalendarHomeModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWorkoutSlot('Workout 1', 'Monday, 10:00 AM'),
                _buildWorkoutSlot('Workout 2', 'Wednesday, 2:00 PM'),
                _buildWorkoutSlot('Workout 3', 'Friday, 6:00 PM'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutSlot(String title, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.fitnessSecondaryModuleColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}