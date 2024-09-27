import 'dart:ui';

import 'package:fitnessapp_idata2503/components/Elements/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UpcomingWorkoutsBox extends StatefulWidget {
  const UpcomingWorkoutsBox({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UpcomingWorkoutsBoxState();
  }
}

class _UpcomingWorkoutsBoxState extends State<UpcomingWorkoutsBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minHeight: 180),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 50, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day and Time',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFFFFF),
                    height: 1.1,
                  ),
                ),
                Text(
                  'Type of exercise, sets',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF848484),
                      height: 1.1),
                ),
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
              double size = 90; // Use height as width
              return SvgPicture.asset(
                'assets/icons/stick_figure.svg',
                height: size,
                width: size,
              );
            },
          ),
        ],
      ),
    );
  }
}
