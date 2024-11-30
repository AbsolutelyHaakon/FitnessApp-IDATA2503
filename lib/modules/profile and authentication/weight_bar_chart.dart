import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_health_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';

/// This class represents a bar chart for displaying the user's weight data.
class WeightBarChart extends StatefulWidget {
  const WeightBarChart({super.key});

  @override
  State<WeightBarChart> createState() => _WeightBarChartState();
}

class _WeightBarChartState extends State<WeightBarChart> {
  late int goalWeight; // Variable to store the user's goal weight
  late final weightController = TextEditingController(); // Controller for the weight input field

  /// Fetches the user's health data from Firebase.
  Future<Map<DateTime, int>> getUserHealthData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var returnData = <DateTime, int>{};

      // Fetch user health data from Firebase
      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);

      List<UserHealthData> userData = userDataMap['userHealthData'];

      // Get the latest data per day
      Map<DateTime, UserHealthData> latestDataPerDay = {};
      for (var entry in userData) {
        DateTime date =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (!latestDataPerDay.containsKey(date) ||
            entry.date.isAfter(latestDataPerDay[date]!.date)) {
          latestDataPerDay[date] = entry;
        }
      }

      // Filter out entries with weight data
      latestDataPerDay.forEach((date, entry) {
        if (entry.weight != null && entry.weight != 0) {
          returnData[date] = entry.weight;
        }
      });

      return returnData;
    }
    return {};
  }

  /// Saves the weight data entered by the user.
  void onAddWeightSave() async {
    int weight = int.parse(weightController.text); // Get the weight from the input field
    DateTime date = DateTime.now(); // Get the current date

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      // Save the weight data to Firebase
      await UserHealthDataDao().fireBaseCreateUserHealthData(
          FirebaseAuth.instance.currentUser!.uid,
          null,
          weight,
          date,
          null,
          null,
          null);
      UserDao().fireBaseUpdateUserData(
        FirebaseAuth.instance.currentUser!.uid,
        '',
        0,
        weight,
        0,
        0,
        null,
        null,
        0,
        0,
        0,
      );
      weightController.clear(); // Clear the input field
      Navigator.of(context).pop(); // Close the dialog
      setState(() {}); // Refresh the UI
    }
  }

  /// Fetches the user's goal weight from Firebase.
  Future<int> getGoalWeight() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      try {
        // Fetch user data from Firebase
        var userDataMap = await UserDao()
            .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);

        if (userDataMap != null && userDataMap.containsKey('weightTarget')) {
          return userDataMap['weightTarget'];
        }
      } catch (e) {
        print('Error fetching goal weight: $e');
      }
    }
    return 0;
  }

  /// Displays a dialog for adding weight and setting a goal weight.
  Widget addWeightAndGoalDialog() {
    return CupertinoButton(
      child: const Text(
        'Add Weight',
        style: TextStyle(color: AppColors.fitnessMainColor),
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext builder) {
              return AlertDialog(
                backgroundColor: AppColors.fitnessModuleColor,
                title: const Text('Insert Weight'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        cursorColor: Colors.white,
                        controller: weightController,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle:
                              TextStyle(fontSize: 20, color: Colors.white),
                          suffixStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.fitnessMainColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.fitnessMainColor),
                          ),
                          labelText: 'Weight (kg)',
                          hintText: 'Enter your weight',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: onAddWeightSave,
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get the screen width

    return FutureBuilder<int>(
      future: getGoalWeight(), // Fetch the goal weight
      builder: (context, goalWeightSnapshot) {
        if (goalWeightSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading indicator
        } else if (goalWeightSnapshot.hasError) {
          return Center(child: Text('Error: ${goalWeightSnapshot.error}')); // Show error message
        } else if (!goalWeightSnapshot.hasData) {
          return const Center(child: Text('No goal weight available')); // Show message if no goal weight
        }

        final goalWeight = goalWeightSnapshot.data!; // Get the goal weight

        return FutureBuilder<Map<DateTime, int>>(
          future: getUserHealthData(), // Fetch the user health data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Show loading indicator
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Show error message
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.fitnessModuleColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF262626),
                          width: 1.0,
                        ),
                      ),
                      child: addWeightAndGoalDialog(), // Show dialog to add weight
                    ),
                    const Center(child: Text('No weight data available')) // Show message if no weight data
                  ]);
            } else {
              List<MapEntry<DateTime, int>> limitedData =
                  snapshot.data!.entries.toList();
              limitedData.sort((a, b) => b.key.compareTo(a.key)); // Sort data by date
              limitedData = limitedData.take(30).toList(); // Limit to 30 entries
              limitedData = limitedData.reversed.toList(); // Reverse the list

              // Group data by month and year
              Map<String, List<MapEntry<DateTime, int>>> groupedData = {};
              limitedData.forEach((entry) {
                String monthYear = "${entry.key.month}-${entry.key.year}";
                if (groupedData.containsKey(monthYear)) {
                  groupedData[monthYear]!.add(entry);
                } else {
                  groupedData[monthYear] = [entry];
                }
              });

              List<BarChartGroupData> barGroups = [];
              int xIndex = 0;
              groupedData.forEach((month, entries) {
                bool isEvenMonth = int.parse(month.split('-')[0]) % 2 == 0;
                Color barColor = isEvenMonth
                    ? AppColors.fitnessMainColor
                    : AppColors.fitnessMainColor.withOpacity(0.6);
                entries.forEach((entry) {
                  barGroups.add(
                    BarChartGroupData(
                      x: xIndex,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: barColor,
                        ),
                      ],
                    ),
                  );
                  xIndex++;
                });
              });

              List<String> monthLabels = [
                "jan",
                "feb",
                "mar",
                "apr",
                "may",
                "jun",
                "jul",
                "aug",
                "sep",
                "oct",
                "nov",
                "dec"
              ];

              double maxY = ((limitedData
                                  .map((entry) => entry.value)
                                  .reduce((a, b) => a > b ? a : b) +
                              5) /
                          10)
                      .ceil() *
                  10.0;
              double minY = (limitedData
                              .map((entry) => entry.value)
                              .reduce((a, b) => a < b ? a : b) /
                          10)
                      .floor() *
                  10.0;

              return Container(
                width: screenWidth * 0.9,
                padding: const EdgeInsets.only(bottom: 20),
                height: 270,
                decoration: BoxDecoration(
                  color: AppColors.fitnessModuleColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF262626),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    addWeightAndGoalDialog(), // Show dialog to add weight
                    AspectRatio(
                      aspectRatio: 2.0,
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} kg',
                                  const TextStyle(
                                      color: AppColors.fitnessMainColor),
                                );
                              },
                            ),
                          ),
                          rangeAnnotations: RangeAnnotations(
                            horizontalRangeAnnotations: [
                              if (goalWeight != 0 &&
                                  goalWeight.toDouble() >= minY &&
                                  goalWeight.toDouble() <= maxY)
                                HorizontalRangeAnnotation(
                                  y1: goalWeight.toDouble(),
                                  y2: goalWeight.toDouble() - 1,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                            ],
                          ),
                          maxY: maxY,
                          minY: minY,
                          gridData: const FlGridData(show: false),
                          backgroundColor: Colors.white.withOpacity(0.05),
                          alignment: BarChartAlignment.start,
                          groupsSpace: 2,
                          barGroups: barGroups,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()} kg');
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              axisNameWidget: Text(''),
                              axisNameSize: 40,
                            ),
                            topTitles: const AxisTitles(
                              axisNameWidget: Text('Weight Progress'),
                              axisNameSize: 25,
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  int index = value.toInt();
                                  if (index < limitedData.length) {
                                    DateTime date = limitedData[index].key;
                                    String monthYear =
                                        "${date.month}-${date.year}";
                                    String month = monthLabels[date.month - 1];
                                    int monthCount =
                                        groupedData[monthYear]!.length;
                                    int middleIndex = (monthCount / 2).floor();
                                    int startIndex = limitedData.indexWhere(
                                        (entry) =>
                                            "${entry.key.month}-${entry.key.year}" ==
                                            monthYear);
                                    if (monthCount % 2 == 0) {
                                      if (index == startIndex + middleIndex) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            month,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (index == startIndex + middleIndex) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            month,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}