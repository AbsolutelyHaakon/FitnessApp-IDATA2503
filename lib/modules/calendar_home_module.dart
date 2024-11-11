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
        child: CupertinoButton(
          onPressed: () {
            // Define the action to be performed when the button is pressed
          },
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.fitnessModuleColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Row (
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.calendar_today,
                          color: AppColors.fitnessMainColor,
                          size: 80,
                        ),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: const TextStyle(
                            color: AppColors.fitnessPrimaryTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        _buildWorkoutSlot('Leg day', '12:00 - 13:00'),
                        _buildWorkoutSlot('Hike', '15:00 - 16:00'),
                      ],
                    ),
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutSlot(String title, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.fitnessMainColor,
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