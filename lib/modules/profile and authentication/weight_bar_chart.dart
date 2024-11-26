import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_health_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../styles.dart';

class WeightBarChart extends StatefulWidget {
  const WeightBarChart({super.key});

  @override
  State<WeightBarChart> createState() => _WeightBarChartState();
}

class _WeightBarChartState extends State<WeightBarChart> {
  late int goalWeight;
  late final weightController = TextEditingController();

  Future<Map<DateTime, int>> getUserHealthData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var returnData = <DateTime, int>{};

      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);

      List<UserHealthData> userData = userDataMap['userHealthData'];

      Map<DateTime, UserHealthData> latestDataPerDay = {};
      for (var entry in userData) {
        DateTime date =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (!latestDataPerDay.containsKey(date) ||
            entry.date.isAfter(latestDataPerDay[date]!.date)) {
          latestDataPerDay[date] = entry;
        }
      }

      latestDataPerDay.forEach((date, entry) {
        if (entry.weight != null && entry.weight != 0) {
          returnData[date] = entry.weight;
        }
      });

      return returnData;
    }
    return {};
  }

  void onAddWeightSave() async {
    int weight = int.parse(weightController.text);
    DateTime date = DateTime.now();

    if (FirebaseAuth.instance.currentUser?.uid != null) {
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
      weightController.clear();
      Navigator.of(context).pop();
      setState(() {});
    }
  }

  Future<int> getGoalWeight() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      try {
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
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<int>(
      future: getGoalWeight(),
      builder: (context, goalWeightSnapshot) {
        if (goalWeightSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (goalWeightSnapshot.hasError) {
          return Center(child: Text('Error: ${goalWeightSnapshot.error}'));
        } else if (!goalWeightSnapshot.hasData) {
          return const Center(child: Text('No goal weight available'));
        }

        final goalWeight = goalWeightSnapshot.data!;

        return FutureBuilder<Map<DateTime, int>>(
          future: getUserHealthData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
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
                      child: addWeightAndGoalDialog(),
                    ),
                    const Center(child: Text('No weight data available'))
                  ]);
            } else {
              List<MapEntry<DateTime, int>> limitedData =
                  snapshot.data!.entries.toList();
              limitedData.sort((a, b) => b.key.compareTo(a.key));
              limitedData = limitedData.take(30).toList();
              limitedData = limitedData.reversed.toList();

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
                    addWeightAndGoalDialog(),
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
