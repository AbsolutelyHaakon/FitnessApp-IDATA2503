import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/pages/home.dart';
import 'package:fitnessapp_idata2503/pages/workout.dart';
import 'package:fitnessapp_idata2503/pages/me.dart';
import 'package:fitnessapp_idata2503/components/navigation_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: CustomNavigationBar(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}