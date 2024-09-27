import 'package:fitnessapp_idata2503/modules/rings_module.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modules/nutrition_module.dart';
import '../modules/today_module.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 90),
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    color: Color(0xFF434343),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 35.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TodayModule(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NutritionModule(),
                RingsModule(),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF000000),
    );
  }
}