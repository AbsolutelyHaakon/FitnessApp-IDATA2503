import 'dart:ui';

import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../pages/pre_workout_screen.dart';

// Last edited 27/09/2024
// Last edited by Matti Kjellstadli

class UpcomingWorkoutsBox extends StatefulWidget {
  const UpcomingWorkoutsBox({super.key, required});

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
              Container(
                alignment: Alignment.topRight,
                child: const Text(
                  'September, 27th',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF787878),
                    height: 1.1,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Heading1(text: 'Exercise Title'),
                        Heading2(text: 'Type of exercise'),
                        SizedBox(
                          height: 20,
                        ),
                        IconText(
                            text: 'Icon Data',
                            color: Color(0xFF848484),
                            asset: 'placeholder_icon.svg'),
                        SizedBox(
                          height: 7,
                        ),
                        IconText(
                            text: 'Icon Data',
                            color: Color(0xFF848484),
                            asset: 'placeholder_icon.svg'),
                        SizedBox(
                          height: 7,
                        ),
                        IconText(
                            text: 'Icon Data',
                            color: Color(0xFF848484),
                            asset: 'placeholder_icon.svg'),
                        SizedBox(
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
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
