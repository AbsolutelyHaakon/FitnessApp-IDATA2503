import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/personal_bests_list.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/personal_best_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// This class represents the Personal Bests module on the profile page.
/// It fetches and displays the user's top 5 personal bests and provides a button to view more.
class PersonalBestModule extends StatelessWidget {
  const PersonalBestModule({super.key});

  // Fetches the personal bests from the database
  Future<Map<String, dynamic>> _getPersonalBests() async {
    return UserWorkoutsDao()
        .fireBaseGetPersonalBests(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.fitnessModuleColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.fitnessModuleColor,
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Using FutureBuilder to fetch and display personal bests
            FutureBuilder<Map<String, dynamic>>(
              future: _getPersonalBests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while fetching data
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Show error message if there is an error
                  return const Center(
                      child: Text('Error loading personal bests'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Show message if no personal bests are found
                  return const Center(child: Text('No personal bests found'));
                } else {
                  // Display the top 5 personal bests
                  final personalBests = snapshot.data!;
                  final firstFivePersonalBests = (personalBests.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                      .take(5)
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Bests',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Display each personal best in a PersonalBestBox
                        Column(
                          children: firstFivePersonalBests
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return PersonalBestBox(
                              index: index,
                              item: item,
                            );
                          }).toList(),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Navigate to the PersonalBestsList page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonalBestsList(
                                    personalBests:
                                        personalBests.entries.toList(),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'View more',
                              style:
                                  TextStyle(color: AppColors.fitnessMainColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            // Refresh button to update personal bests
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  UserWorkoutsDao().fireBaseSetPersonalBests(
                      FirebaseAuth.instance.currentUser!.uid);
                },
                icon: const Icon(Icons.refresh_rounded),
                color: AppColors.fitnessMainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}