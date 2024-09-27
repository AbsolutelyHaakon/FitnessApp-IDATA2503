import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Shows the selected workout plan details before deciding to start it
// Displays workout info and potentially a map of the workout route

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

//TODO: Implement map fucntionality
//TODO: Connect it to the persistent storage

class WorkoutPlanModule extends StatelessWidget {
  const WorkoutPlanModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(

        children: [
          const SizedBox(height: 40),
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1B1C),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 90),
          CupertinoButton(
              onPressed: () {  },
            child: Container(
              width: 410,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF48CC6D),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text("Start Workout",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}