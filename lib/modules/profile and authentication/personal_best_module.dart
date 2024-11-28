import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/ind_personal_best_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalBestModule extends StatelessWidget {
  const PersonalBestModule({super.key});

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
            FutureBuilder<Map<String, dynamic>>(
              future: _getPersonalBests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading personal bests'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No personal bests found'));
                } else {
                  final personalBests = snapshot.data!;
                  final firstFivePersonalBests =
                      personalBests.entries.take(5).toList();
                  final svgIcons = [
                    "assets/icons/medal1.svg",
                    "assets/icons/medal2.svg",
                    "assets/icons/medal3.svg",
                    "",
                    "",
                  ];
                  final medalColors = [
                    Colors.yellow.shade500,
                    Colors.grey.shade500,
                    Colors.brown.shade500,
                    Colors.transparent,
                    Colors.transparent,
                  ];
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
                        Column(
                          children: firstFivePersonalBests
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.fitnessSecondaryModuleColor
                                        .withOpacity(0.6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            svgIcons[index],
                                            height: 24,
                                            width: 24,
                                            color: medalColors[index],
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            item.key,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${item.value} kg',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {},
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
