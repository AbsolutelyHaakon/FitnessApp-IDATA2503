import 'dart:ui';
import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:fitnessapp_idata2503/logic/workout.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../pages/pre_workout_screen.dart';

// Last edited 27/09/2024
// Last edited by Adrian Johansen

enum Type {
  legs,
  chest,
  back,
  arms,
  fullBody,
  other,
}

final Map<Type, String> typeNames = {
  Type.legs: 'Legs',
  Type.chest: 'Chest',
  Type.back: 'Back',
  Type.arms: 'Arms',
  Type.fullBody: 'Full-Body',
};

class UpcomingWorkoutsBox extends StatefulWidget {
  UpcomingWorkoutsBox(
      {super.key,
      required this.title,
      required this.category,
      required this.date});

  String title;
  //TODO: Type category;
  String category;
  DateTime date;

  String getFormattedDate(DateTime date) {
    String formattedMonth = DateFormat.MMMM().format(date);
    String day = date.day.toString();

    String dayWithSuffix = '$day${getDaySuffix(date.day)}';

    return '$formattedMonth, $dayWithSuffix';
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _UpcomingWorkoutsBoxState();
  }
}

class _UpcomingWorkoutsBoxState extends State<UpcomingWorkoutsBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0), // Add right padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text( // Date above workout box
                widget.getFormattedDate(widget.date),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fitnessPrimaryTextColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(top: 10.0), // Add top margin
          child: CupertinoButton(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: Container(
              constraints: const BoxConstraints(minHeight: 80),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              decoration: BoxDecoration(
                color: AppColors.fitnessModuleColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF262626), // Almost the same color
                  width: 1.0, // Very thin
                ),
              ),
              padding: const EdgeInsets.fromLTRB(15, 5, 30, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10), // Top padding above H1
                        Heading1(text: widget.title),
                        Heading2(
                            text: typeNames[widget.category] ??
                                'Unknown Category'),
                        const SizedBox(
                          height: 20,
                        ),
                        const IconText(
                            text: '500Cal',
                            color: AppColors.fitnessSecondaryTextColor,
                            icon: Icons.fireplace),
                        const SizedBox(
                          height: 7,
                        ),
                        const IconText(
                            text: '45min',
                            color: AppColors.fitnessSecondaryTextColor,
                            icon: Icons.access_time),
                        const SizedBox(
                          height: 7,
                        ),
                        const IconText(
                            text: '7 sets',
                            color: AppColors.fitnessSecondaryTextColor,
                            icon: Icons.help_outline),
                        const SizedBox(
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double size = 90;
                      return SvgPicture.asset(
                        'assets/icons/stick_figure.svg',
                        height: size,
                        width: size,
                      );
                    },
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const PreWorkoutScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
