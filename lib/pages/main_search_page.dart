import 'package:fitnessapp_idata2503/pages/social%20and%20account/search_users.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_search.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainSearchPage(),
    );
  }
}

// Main search page widget
class MainSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
  length: 2,
  child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Scaffold(
    body: Column(
      children: [
        Container(
          color: AppColors.fitnessBackgroundColor,
          child: const TabBar(
            indicatorColor: AppColors.fitnessMainColor,
            labelColor: AppColors.fitnessMainColor,
            unselectedLabelColor: AppColors.fitnessPrimaryTextColor,
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Workouts'),
            ],
          ),
        ),
        const Expanded(
          child: TabBarView(
            children: [
              SearchUsers(),
              SearchWorkouts(),
            ],
          ),
        ),
      ],
    ),
    backgroundColor: AppColors.fitnessBackgroundColor,
  ),
  ),
);
  }
}