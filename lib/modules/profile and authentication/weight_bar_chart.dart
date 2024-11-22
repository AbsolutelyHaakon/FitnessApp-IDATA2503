import 'dart:ffi';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';

class WeightBarChart extends StatelessWidget {
  WeightBarChart({super.key});

  Map<DateTime, int> testData =  {
    DateTime(2024, 1, 1): 97,
    DateTime(2024, 1, 2): 97,
    DateTime(2024, 1, 3): 96,
    DateTime(2024, 1, 4): 97,
    DateTime(2024, 1, 5): 95,
    DateTime(2024, 1, 6): 94,
    DateTime(2024, 1, 7): 95,
    DateTime(2024, 1, 8): 93,
    DateTime(2024, 2, 1): 94,
    DateTime(2024, 2, 2): 90,
    DateTime(2024, 2, 3): 91,
    DateTime(2024, 2, 4): 92,
    DateTime(2024, 2, 5): 91,
    DateTime(2024, 2, 6): 90,
    DateTime(2024, 2, 7): 87,
    DateTime(2024, 2, 8): 84,
    DateTime(2024, 3, 1): 94,
    DateTime(2024, 3, 2): 90,
    DateTime(2024, 3, 3): 91,
    DateTime(2024, 3, 4): 92,
    DateTime(2024, 3, 5): 91,
    DateTime(2024, 3, 6): 90,
    DateTime(2024, 3, 7): 87,
    DateTime(2024, 3, 8): 84,
};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Map<String, List<MapEntry<DateTime, int>>> groupedData = {};
    testData.forEach((date, value) {
      String month = "${date.month}";
      if (groupedData.containsKey(month)) {
        groupedData[month]!.add(MapEntry(date, value));
      } else {
        groupedData[month] = [MapEntry(date, value)];
      }
    });

    List<BarChartGroupData> barGroups = [];
    int xIndex = 0;
    groupedData.forEach((month, entries) {
      entries.forEach((entry) {
        barGroups.add(BarChartGroupData(x: xIndex, barRods: [
          BarChartRodData(toY: entry.value.toDouble(), color: AppColors.fitnessMainColor),
        ],
        ),);
        xIndex++;
      });
    });

    List<String> monthLabels = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];

    double maxY = (testData.values.reduce((a, b) => a > b ? a : b) / 10).ceil() * 10.0;
    double minY = maxY - 20;

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
            child: AspectRatio(aspectRatio: 2.0,
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
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false),),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        int groupSize = groupedData.values.first.length;
                        String month = monthLabels[(index ~/ groupSize) % 12];
                        bool isMiddle = (index % groupSize) == (groupSize ~/ 2);
                        return SideTitleWidget(axisSide: meta.axisSide,
                            child: Text(
                              isMiddle ? month : '',
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),);
                      }
                    ),
                  ),
                ),
            ),
            ),),
    );
  }
}