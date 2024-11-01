import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/pages/create_workout_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/pages/account_setup.dart';

import '../pages/exercise_selector.dart';
import '../styles.dart';

// Module for displaying a WIP widget
// Used internally only for quick access to unfinished modules
// TO BE REMOVED BEFORE RELEASE

// Last edited: 31/10/2024
// Last edited by: Håkon Svensen Karlsen

class WipModule extends StatefulWidget {
  final User? user;
  const WipModule({super.key, this.user});
  @override
  State<WipModule> createState() => _WipModuleState();
}

class _WipModuleState extends State<WipModule> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                   ExerciseSelectorPage(user: widget.user),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFF262626), // Almost the same color
              width: 1.0, // Very thin
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.hammer_fill,
                color: AppColors.fitnessMainColor,
                size: 100,
              ),
              Text(
                'WIP',
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontWeight: FontWeight.w500,
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
