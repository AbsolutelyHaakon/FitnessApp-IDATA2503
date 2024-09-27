// lib/modules/nutrition_module.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutLogModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // -> Workout Log
        },
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Add icon here later
              //Icon(
                //Icons.dining_rounded,
                //color: Color(0xFF48CC6D),
                //size: 80,
              //),
              Text(
                'Workout log',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}