import 'dart:ui';

import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/logic/upcoming_workouts_list.dart';
import 'package:fitnessapp_idata2503/logic/workout.dart';
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
      required this.date,
      required this.workouts});

  String title;
  Type category;
  DateTime date;
  List<Workout> workouts;

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
    return CupertinoButton(
        child: Container(
          constraints: const BoxConstraints(minHeight: 180),
          width: 400,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1B1C),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 50, 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.getFormattedDate(widget.date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF787878),
                            height: 1.1,
                          ),
                        ),
                        Heading1(text: widget.title),
                        Heading2(
                            text: typeNames[widget.category] ??
                                'Unknown Category'),
                        const SizedBox(
                          height: 20,
                        ),
                        const IconText(
                            text: 'Icon Data',
                            color: Color(0xFF848484),
                            asset: 'placeholder_icon.svg'),
                        const SizedBox(
                          height: 7,
                        ),
                        const IconText(
                            text: 'Icon Data',
                            color: Color(0xFF848484),
                            asset: 'placeholder_icon.svg'),
                        const SizedBox(
                          height: 7,
                        ),
                        const IconText(
                            text: 'Icon Data',
                            color: Color(0xFF848484),
                            asset: 'placeholder_icon.svg'),
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
        });
  }
}
