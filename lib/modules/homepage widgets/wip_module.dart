import 'package:fitnessapp_idata2503/pages/statistics%20and%20nutrition/hydration_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';

// This module displays a WIP (Work In Progress) widget
// It's used internally for quick access to unfinished modules

class WipModule extends StatefulWidget {
  const WipModule({super.key});

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
          // Navigate to the HydrationPage when the button is pressed
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HydrationPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Slide transition for the page navigation
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
