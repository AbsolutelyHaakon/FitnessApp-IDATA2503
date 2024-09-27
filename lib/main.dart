import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/navigation_bar.dart';

import 'components/navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomNavigationBar(),
    );
  }
}