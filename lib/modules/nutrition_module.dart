// lib/modules/nutrition_module.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Nutrition Module which contains an image and text beneath
// Widget to be displayed on the home screen

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

class NutritionModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // Define the action when the button is pressed
        },
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: Color(0xFF1A1B1C),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dining_rounded,
                color: Color(0xFF48CC6D),
                size: 100,
              ),
              Text(
                'Nutrition',
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