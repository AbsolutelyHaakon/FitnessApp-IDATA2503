import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/navigation_bar.dart';

import 'database/dummy_data.dart';

void main() async {
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        fontFamily: 'Inter', // Set Inter as the default font
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: CustomNavigationBar(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}