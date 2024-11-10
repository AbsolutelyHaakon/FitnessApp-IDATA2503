import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHomeModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          DateFormat('EEEE, MMM dd').format(DateTime.now()),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}