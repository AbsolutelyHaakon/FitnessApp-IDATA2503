import 'package:fitnessapp_idata2503/components/Elements/texts.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class CreateWorkoutPage extends StatelessWidget {
  const CreateWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fitnessPrimaryTextColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fitnessBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Workout Title..',
                  hintStyle: const TextStyle(
                    color: AppColors.fitnessSecondaryTextColor,
                  ),
                ),
              ),
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                cursorColor: AppColors.fitnessMainColor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fitnessPrimaryTextColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.fitnessBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Workout Type..',
                  hintStyle: const TextStyle(
                    color: AppColors.fitnessSecondaryTextColor,
                  ),
                ),
              ),
            ),
            const SingleChildScrollView(
              child: Column(
                children: [],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: FloatingActionButton(
              backgroundColor: AppColors.fitnessMainColor,
              onPressed: () {},
              child: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: FloatingActionButton(
                backgroundColor: AppColors.fitnessMainColor,
                onPressed: () {},
                child: const Text('Create Workout'),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: AppColors.fitnessMainColor,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
