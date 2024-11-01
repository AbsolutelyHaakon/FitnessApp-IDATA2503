// lib/modules/nutrition_module.dart
import 'package:fitnessapp_idata2503/styles.dart';
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
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dining_rounded,
                color: AppColors.fitnessMainColor,
                size: 100,
              ),
              Text(
                'Nutrition',
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
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