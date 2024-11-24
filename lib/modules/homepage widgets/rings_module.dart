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


class _RingsModuleState extends State<RingsModule> {

  double waterPercentage = 0.01;
  double caloriePercentage = 0.01;
  double weightPercentage = 0.01;
  double calorieBurnPercentage = 0.01;

  int waterGoal = 2000;
  int calorieGoal = 2000;
  int weightGoal = 70;
  int calorieBurnGoal = 2000;

  @override
  void initState() {
    super.initState();
    fetchAllUserGoals();
  }

  Future<void> fetchAllUserGoals() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userGoalsMap = await UserDao().fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
      waterGoal = userGoalsMap?["waterTarget"] ?? 1;
      calorieGoal = userGoalsMap?["caloriesTarget"] ?? 1;
      weightGoal = userGoalsMap?["weightTarget"] ?? 1;
      calorieBurnGoal = userGoalsMap?["caloriesBurnedTarget"] ?? 1;
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
        DateTime date = DateTime(
            entry.date.year, entry.date.month, entry.date.day);
        if (date == todayDate && entry.waterIntake != null) {
          todayIntakew += entry.waterIntake!;
          todaycb += entry.caloriesBurned!;
          todayc += entry.caloriesIntake!;
          todayWeight += entry.weight!;
        }
      }

      setState(() {
        waterPercentage = todayIntakew / waterGoal;
        calorieBurnPercentage = todaycb / calorieBurnGoal;
        caloriePercentage = todayc / calorieGoal;
        weightPercentage = todayWeight / weightGoal;
      });

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
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        WeightPage(),
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
                        value: weightPercentage,
                        // Example progress value
                        strokeWidth: 8.0,
                        strokeCap: StrokeCap.round,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.fitnessMainColor),
                        backgroundColor: AppColors.fitnessModuleColor,
                      ),
                    ),
                    const Text(
                      'KG',
                      style: TextStyle(
                        color: AppColors.fitnessMainColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CalorieIntakePage(),
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
                        value: caloriePercentage,
                        // Example progress value
                        strokeWidth: 8.0,
                        strokeCap: StrokeCap.round,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                        backgroundColor: AppColors.fitnessModuleColor,
                      ),
                    ),
                    const Text(
                      'Cal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        HydrationPage(),
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
                        value: waterPercentage,
                        // Example progress value
                        strokeWidth: 8.0,
                        strokeCap: StrokeCap.round,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF11ABFF)),
                        backgroundColor: AppColors.fitnessModuleColor,
                      ),
                    ),
                    const Text(
                      'Water\nGoal',
                      style: TextStyle(
                        color: Color(0xFF11ABFF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CalorieBurnPage(),
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
                        value: calorieBurnPercentage,
                        // Example progress value
                        strokeWidth: 8.0,
                        strokeCap: StrokeCap.round,
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFCC4848)),
                        backgroundColor: AppColors.fitnessModuleColor,
                      ),
                    ),
                    const Text(
                      'Cal\nBurn',
                      style: TextStyle(
                        color: Color(0xFFCC4848),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
