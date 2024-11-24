import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_health_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';

class WeightBarChart extends StatelessWidget {
  WeightBarChart({super.key});

  Map<DateTime, int> testData = {
    DateTime(2024, 1, 1): 1,
    DateTime(2024, 1, 2): 2,
    DateTime(2024, 1, 3): 3,
    DateTime(2024, 1, 4): 4,
    DateTime(2024, 1, 5): 5,
    DateTime(2024, 1, 6): 6,
    DateTime(2024, 1, 7): 7,
    DateTime(2024, 1, 8): 8,
    DateTime(2024, 2, 1): 9,
    DateTime(2024, 2, 2): 10,
    DateTime(2024, 2, 3): 11,
    DateTime(2024, 2, 4): 12,
    DateTime(2024, 2, 5): 13,
    DateTime(2024, 2, 6): 14,
    DateTime(2024, 2, 7): 15,
    DateTime(2024, 2, 8): 16,
    DateTime(2024, 3, 1): 17,
    DateTime(2024, 3, 2): 18,
    DateTime(2024, 3, 3): 19,
    DateTime(2024, 3, 4): 20,
    DateTime(2024, 3, 5): 21,
    DateTime(2024, 3, 6): 22,
    DateTime(2024, 3, 7): 23,
    DateTime(2024, 3, 8): 24,
    DateTime(2024, 4, 7): 25,
    DateTime(2024, 4, 8): 26,
    DateTime(2024, 5, 7): 27,
    DateTime(2024, 5, 8): 28,
    DateTime(2024, 6, 7): 29,
    DateTime(2024, 6, 8): 30,
    DateTime(2024, 6, 6): 31,
    DateTime(2024, 6, 5): 32,
    DateTime(2024, 6, 4): 33,
    DateTime(2024, 6, 3): 34,
    DateTime(2024, 6, 2): 35,
    DateTime(2024, 6, 1): 36,
    DateTime(2024, 7, 7): 37,
    DateTime(2024, 7, 8): 38,
    DateTime(2024, 7, 6): 39,
    DateTime(2024, 7, 5): 40,
    DateTime(2024, 7, 4): 41,
    DateTime(2024, 7, 3): 42,
    DateTime(2024, 7, 2): 43,
    DateTime(2024, 7, 1): 44,
  };

  Future<Map<DateTime, int>> getUserHealthData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var returnData = <DateTime, int>{};

      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);
      List<UserHealthData> userData = userDataMap['userHealthData'];

      print('Fetched user data: ${userData.length} entries');

      for (var entry in userData) {
        print('Entry: ${entry.date} - ${entry.weight}');
        returnData[entry.date] = entry.weight;
      }
      print('Return data: $returnData');
      return returnData;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Map<DateTime, int>>(
      future: getUserHealthData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          List<MapEntry<DateTime, int>> limitedData =
              snapshot.data!.entries.toList();
          limitedData.sort((a, b) => b.key.compareTo(a.key));
          limitedData = limitedData.take(30).toList();
          limitedData = limitedData.reversed.toList();

          Map<String, List<MapEntry<DateTime, int>>> groupedData = {};
          limitedData.forEach((entry) {
            String month = "${entry.key.month}";
            if (groupedData.containsKey(month)) {
              groupedData[month]!.add(entry);
            } else {
              groupedData[month] = [entry];
            }
          });

          List<BarChartGroupData> barGroups = [];
          int xIndex = 0;
          groupedData.forEach((month, entries) {
            bool isEvenMonth = int.parse(month) % 2 == 0;
            Color barColor = isEvenMonth
                ? AppColors.fitnessMainColor
                : AppColors.fitnessMainColor.withOpacity(0.7);
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
                          10) /
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.fitnessModuleColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF262626),
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: AspectRatio(
                aspectRatio: 2.0,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    minY: minY,
                    gridData: const FlGridData(show: false),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    alignment: BarChartAlignment.start,
                    groupsSpace: 2,
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index < limitedData.length) {
                                DateTime date = limitedData[index].key;
                                String month = monthLabels[date.month - 1];
                                int monthCount =
                                    groupedData["${date.month}"]!.length;
                                int middleIndex = (monthCount / 2).floor();
                                int startIndex = limitedData.indexWhere(
                                    (entry) => entry.key.month == date.month);
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
                              return const SizedBox.shrink();
                            }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
