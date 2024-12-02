import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class CustomAppBar {
  static AppBar buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false, // align title to the left
      titleSpacing: 40, // space between title and leading icon
      backgroundColor: AppColors.fitnessBackgroundColor, // set background color
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor), // back icon
        onPressed: () {
          Navigator.of(context).pop(); // go back to the previous screen
        },
      ),
    );
  }
}