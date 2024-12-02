import 'package:fitnessapp_idata2503/pages/social%20and%20account/search_users.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_search.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

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
            dividerColor: AppColors.fitnessBackgroundColor,
            labelColor: AppColors.fitnessMainColor,
            indicatorColor: AppColors.fitnessMainColor,
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