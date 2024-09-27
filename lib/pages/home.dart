import 'package:fitnessapp_idata2503/modules/rings_module.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 27.0,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: Color(0xFF292929),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TodayModule(),
            SizedBox(height: 10),
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
      backgroundColor: Color(0xFF292929),
    );
  }
}