import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class CustomAppBar {
  static AppBar buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: 40,
      backgroundColor: AppColors.fitnessBackgroundColor,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}