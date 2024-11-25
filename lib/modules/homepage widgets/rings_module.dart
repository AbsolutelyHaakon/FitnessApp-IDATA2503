import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/pages/statistics%20and%20nutrition/calorie_burn_page.dart';
import 'package:fitnessapp_idata2503/pages/statistics%20and%20nutrition/weight_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/crud/user_health_data_dao.dart';
import '../../database/tables/user_health_data.dart';
import '../../pages/statistics and nutrition/calorie_intake_page.dart';
import '../../pages/statistics and nutrition/hydration_page.dart';

// Module for displaying ring widgets as a progress bar
// Used to display progress in a certain category
// Examples: BMI, Calories, Body fat, etc.

// Last edited 27/09/2024
// Last edited by Matti Kjellstadli

//TODO: Implement the actual progress values as persistent values
//TODO: Link the values up to the actual data

class RingsModule extends StatefulWidget {
  const RingsModule({super.key});

  @override
  _RingsModuleState createState() => _RingsModuleState();
}

class _RingsModuleState extends State<RingsModule> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isDisposed = false;

  double waterPercentage = 0.01;
  double caloriePercentage = 0.01;
  double weightPercentage = 0.01;
  double calorieBurnPercentage = 0.01;

  int waterGoal = 2000;
  int calorieGoal = 2000;
  int weightGoal = 70;
  int calorieBurnGoal = 2000;
  int weightInitial = 0;

  @override
  void initState() {
    super.initState();
    fetchAllUserGoals();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.addListener(() {
      if (!_isDisposed) {
        setState(() {});
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchAllUserGoals() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userGoalsMap = await UserDao()
          .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
      waterGoal = (userGoalsMap?["waterTarget"] ?? 1) == 0
          ? 2500
          : userGoalsMap?["waterTarget"] ?? 2500;
      calorieGoal = (userGoalsMap?["caloriesTarget"] ?? 1) == 0
          ? 2200
          : userGoalsMap?["caloriesTarget"] ?? 2200;
      weightGoal = (userGoalsMap?["weightTarget"] ?? 1) == 0
          ? 10
          : userGoalsMap?["weightTarget"] ?? 10;
      calorieBurnGoal = (userGoalsMap?["caloriesBurnedTarget"] ?? 1) == 0
          ? 2500
          : userGoalsMap?["caloriesBurnedTarget"] ?? 400;
      weightInitial = (userGoalsMap?["weightInitial"] ?? 1) == 0
          ? 10
          : userGoalsMap?["weightInitial"] ?? 1;
    }

    fetchAllRingData();
  }

  Future<void> fetchAllRingData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);
      List<UserHealthData> userData = userDataMap['userHealthData'];

      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);
      int todayIntakew = 0;
      int todaycb = 0;
      int todayc = 0;
      int todayWeight = 0;

      for (var entry in userData) {
        DateTime date =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (date == todayDate) {
          if (entry.waterIntake != null) {
            todayIntakew += entry.waterIntake!;
          }
          if (entry.caloriesBurned != null) {
            todaycb += entry.caloriesBurned!;
          }
          if (entry.caloriesIntake != null) {
            todayc += entry.caloriesIntake!;
          }
          if (entry.weight < 300 && entry.weight > 30) {
            todayWeight = entry.weight;
          }
        }
      }

      if (!_isDisposed) {
        setState(() {
          waterPercentage = todayIntakew / waterGoal;
          calorieBurnPercentage = todaycb / calorieBurnGoal;
          caloriePercentage = todayc / calorieGoal;
          if (todayWeight < weightGoal) {
            weightPercentage =
                (weightInitial - todayWeight) / (weightInitial - weightGoal);
          } else {
            weightPercentage =
                (todayWeight - weightInitial) / (weightGoal - weightInitial);
          }
          if (weightPercentage.isInfinite) {
            weightPercentage = 1;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.fitnessSecondaryModuleColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRingButton(
              context,
              'KG',
              weightPercentage,
              const Color(0xFF48CC6D),
              WeightPage(),
            ),
            const SizedBox(width: 10),
            _buildRingButton(
              context,
              'Cal',
              caloriePercentage,
              const Color(0xFFCC7F48),
              CalorieIntakePage(),
            ),
            const SizedBox(width: 10),
            _buildRingButton(
              context,
              'Water\nGoal',
              waterPercentage,
              const Color(0xFF11ABFF),
              HydrationPage(),
            ),
            const SizedBox(width: 10),
            _buildRingButton(
              context,
              'Cal\nBurn',
              calorieBurnPercentage,
              const Color(0xFFCC4848),
              CalorieBurnPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingButton(BuildContext context, String label, double percentage,
      Color color, Widget page) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60.0,
              height: 60.0,
              child: CircularProgressIndicator(
                value: _animation.value * percentage,
                strokeWidth: 8.0,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: AppColors.fitnessModuleColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
