import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'workout_calendar.dart';

import '../styles.dart';

class CalendarHomeModule extends StatefulWidget {
  const CalendarHomeModule({super.key});

  @override
  _CalendarHomeModuleState createState() => _CalendarHomeModuleState();
}

class _CalendarHomeModuleState extends State<CalendarHomeModule> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WorkoutCalendar()),
            );
          },
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

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                    _buildWorkoutSlots(),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  List<Widget> _buildWorkoutSlots() {
    List<Map<String, String>> workouts = [
      {'title': 'Leg day', 'time': '12:00 - 13:00'},
      {'title': 'Hike', 'time': '15:00 - 16:00'},
    ];


    return workouts.map((workout) {
      return _buildWorkoutSlot(workout['title']!, workout['time']!);
    }).toList();
  }

  Widget _buildWorkoutSlot(String title, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
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
              fontSize: 16,
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