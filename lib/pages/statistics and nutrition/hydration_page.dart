import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../database/tables/user_health_data.dart';
import '../../styles.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  _HydrationPageState createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage> {
  Map<DateTime, int> dailyIntake = <DateTime, int>{};
  List<MapEntry<DateTime, int>> hourlyIntake = [];
  final double goal = 2.0; // Example goal in liters
  bool isLoading = false;
  final UserHealthDataDao _userHealthDataDao = UserHealthDataDao();

  @override
  void initState() {
    super.initState();
    fetchHydrationData();
  }

  Future<void> fetchHydrationData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);
      List<UserHealthData> userData = userDataMap['userHealthData'];
      Map<DateTime, int> aggregatedData = {};
      for (var entry in userData) {
        DateTime date =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (aggregatedData.containsKey(date)) {
          aggregatedData[date] = aggregatedData[date]! + entry.waterIntake!;
        } else {
          aggregatedData[date] = entry.waterIntake!;
        }
      }
      setState(() {
        dailyIntake = aggregatedData;
        hourlyIntake =
            userData.map((e) => MapEntry(e.date, e.waterIntake!)).toList();
      });
    } else {
      // Example data
      dailyIntake = {
        DateTime.now().subtract(Duration(days: 6)): 1,
        DateTime.now().subtract(Duration(days: 5)): 12,
        DateTime.now().subtract(Duration(days: 4)): 12,
        DateTime.now().subtract(Duration(days: 3)): 12,
        DateTime.now().subtract(Duration(days: 2)): 111,
        DateTime.now().subtract(Duration(days: 1)): 123,
        DateTime.now(): 1,
      };
      hourlyIntake = [
        MapEntry(DateTime.now().subtract(Duration(hours: 6)), 1),
        MapEntry(DateTime.now().subtract(Duration(hours: 5)), 12),
        MapEntry(DateTime.now().subtract(Duration(hours: 4)), 12),
        MapEntry(DateTime.now().subtract(Duration(hours: 3)), 12),
        MapEntry(DateTime.now().subtract(Duration(hours: 2)), 111),
        MapEntry(DateTime.now().subtract(Duration(hours: 1)), 123),
        MapEntry(DateTime.now(), 1),
      ];
    }
  }

@override
Widget build(BuildContext context) {
  double maxY = dailyIntake.values.isNotEmpty ? dailyIntake.values.reduce((a, b) => a > b ? a : b).toDouble() : 3.0;

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Hydration',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.fitnessPrimaryTextColor,
        ),
      ),
      titleSpacing: 40,
      backgroundColor: AppColors.fitnessBackgroundColor,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: Color(0xFF468CF6)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        if (FirebaseAuth.instance.currentUser != null)
          TextButton(
            onPressed: () async {},
            child: const Text('Add Data',
                style: TextStyle(color: Color(0xFF468CF6))),
          ),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: hourlyIntake
                          .map((e) => FlSpot(e.key.hour.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: const Color(0xFF468CF6),
                      barWidth: 4,
                      belowBarData: BarAreaData(
                          show: true,
                          color: Color(0xFF468CF6).withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now()
                              .subtract(Duration(days: 6 - value.toInt()));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 5,
                            child: Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(
                                color: Color(0xFF468CF6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    final date = DateTime.now().subtract(Duration(days: 6 - index));
                    final intake = dailyIntake[DateTime(date.year, date.month, date.day)] ?? 0.0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: intake.toDouble(),
                          color: Color(0xFF468CF6),
                          width: 16,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: dailyIntake.entries.map((entry) {
                DateTime date = entry.key;
                double intake = entry.value.toDouble();
                String formattedDate = DateFormat('MMM dd, yyyy').format(date);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.fitnessModuleColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formattedDate, style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        '${intake.toStringAsFixed(1)} L / ${goal.toStringAsFixed(1)} L',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Color(0xFF468CF6)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
    backgroundColor: AppColors.fitnessBackgroundColor,
  );
}
}
