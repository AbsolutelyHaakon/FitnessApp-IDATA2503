import 'package:fitnessapp_idata2503/modules/break_timer_module.dart';
import 'package:flutter/material.dart';

class Me extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
        backgroundColor: Color(0xFF292929),
      ),
      body: const Center(
        child: BreakTimerModule()
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}