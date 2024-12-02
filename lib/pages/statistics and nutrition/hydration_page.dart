// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../database/crud/user_dao.dart';
import '../../database/tables/user_health_data.dart';
import '../../styles.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  _HydrationPageState createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage>
    with SingleTickerProviderStateMixin {
  Map<DateTime, int> dailyIntake =
      <DateTime, int>{}; // Stores daily water intake
  List<MapEntry<DateTime, int>> hourlyIntake = []; // Stores hourly water intake
  double goal = 2500; // Example goal in milliliters
  bool isLoading = false; // Loading state
  late AnimationController _animationController; // Animation controller
  late Animation<double> _animation; // Animation
  DateTime today = DateTime.now(); // Today's date
  double todayIntakew = 0; // Today's water intake
  double waterPercentage = 0.0; // Percentage of water intake goal achieved
  List<FlSpot> cumulativeSpots = []; // Cumulative water intake spots for graph
  double cumulativeSum = 0; // Cumulative sum of water intake

  @override
  void initState() {
    super.initState();
    fetchAllUserGoals(); // Fetch user goals
// Fetch hydration data

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Animation duration
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Animation curve
    );

    _animationController.addListener(() {
      if (mounted) {
        setState(() {}); // Update state on animation change
      }
    });

    _animationController.forward(); // Start animation
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  Future<void> fetchAllUserGoals() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userGoalsMap = await UserDao()
          .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
      var goalInt =
          userGoalsMap?["waterTarget"] ?? 2500; // Default goal if not set
      setState(() {
        goal = goalInt.toDouble(); // Set goal
      });
    }
  }

  Future<void> fetchHydrationData() async {
    todayIntakew = 0; // Reset today's intake
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);
      List<UserHealthData> userData = userDataMap['userHealthData'];
      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);
      Map<DateTime, int> aggregatedData = {};
      for (var entry in userData) {
        DateTime date =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (entry.waterIntake == null || entry.waterIntake! <= 0) {
          continue; // Skip if no water intake
        }
        if (aggregatedData.containsKey(date)) {
          aggregatedData[date] = aggregatedData[date]! + entry.waterIntake!;
        } else {
          aggregatedData[date] = entry.waterIntake!;
        }
        if (date == todayDate) {
          if (entry.waterIntake != null) {
            todayIntakew += entry.waterIntake!; // Add to today's intake
          }
        }
      }
      setState(() {
        dailyIntake = aggregatedData; // Set daily intake data
        if (goal == 0) {
          goal = 2500; // Default goal if not set
        }
        waterPercentage = todayIntakew / goal; // Calculate percentage
        if (waterPercentage > 1) {
          waterPercentage = 1; // Cap percentage at 1
        }
        DateTime now = DateTime.now();
        today = DateTime(now.year, now.month, now.day);

        hourlyIntake = userData
            .where((e) => e.waterIntake != null && e.waterIntake! >= 1)
            .map((e) => MapEntry(e.date, e.waterIntake!))
            .toList();

        hourlyIntake.insert(0, MapEntry(today, 0)); // Add today's intake
      });
    }
  }

  Future<void> _addData() async {
    int waterIntake = 0; // Initialize water intake

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Water Intake',
                  style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_drink, size: 50, color: Colors.blue),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            if (waterIntake > 0) {
                              waterIntake -= 100; // Decrease intake
                            }
                          });
                        },
                      ),
                      Text('$waterIntake ml',
                          style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.fitnessPrimaryTextColor)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            waterIntake += 100; // Increase intake
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel',
                      style:
                          TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                ),
                TextButton(
                  onPressed: () async {
                    // Save the water intake data
                    if (FirebaseAuth.instance.currentUser?.uid != null) {
                      await UserHealthDataDao().fireBaseCreateUserHealthData(
                        FirebaseAuth.instance.currentUser!.uid,
                        null,
                        null,
                        DateTime.now(),
                        null,
                        null,
                        waterIntake,
                      );
                      fetchHydrationData(); // Refresh data
                    }
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.blue)),
                ),
              ],
              backgroundColor: AppColors.fitnessModuleColor,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double maxY = dailyIntake.values.isNotEmpty
        ? dailyIntake.values.reduce((a, b) => a > b ? a : b).toDouble()
        : 3.0; // Max Y value for bar chart

    // Filter hourlyIntake to only include entries from today
    DateTime today = DateTime.now();
    List<MapEntry<DateTime, int>> todayIntake = hourlyIntake.where((entry) {
      return entry.key.year == today.year &&
          entry.key.month == today.month &&
          entry.key.day == today.day;
    }).toList();

    cumulativeSpots.clear();
    cumulativeSum = 0;

    todayIntake
        .sort((a, b) => a.key.hour.compareTo(b.key.hour)); // Sort by hour

    for (var entry in todayIntake) {
      cumulativeSum += entry.value; // Calculate cumulative sum
      cumulativeSpots
          .add(FlSpot(entry.key.hour.toDouble(), cumulativeSum)); // Add spot
    }

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
            Navigator.of(context).pop(); // Go back
          },
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            TextButton(
              onPressed: () async {
                _addData(); // Add data
              },
              child: const Text('Add Data',
                  style: TextStyle(color: Color(0xFF468CF6))),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 210,
                            height: 210,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 180.0,
                                  height: 180.0,
                                  child: CircularProgressIndicator(
                                    value: _animation.value *
                                        (waterPercentage > 1
                                            ? 1
                                            : waterPercentage),
                                    // Progress indicator
                                    strokeWidth: 18.0,
                                    strokeCap: StrokeCap.round,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF468CF6)),
                                    backgroundColor:
                                        AppColors.fitnessModuleColor,
                                  ),
                                ),
                                Text(
                                  goal - todayIntakew >= 0
                                      ? '${(goal - todayIntakew).abs()} mL'
                                      : '0.0 mL', // Remaining intake
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'Consume\n\n\n',
                                  style: TextStyle(
                                    color: AppColors.fitnessSecondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                waterPercentage >= goal
                                    ? 'Congratulations!\nGoal Reached!'
                                    : 'Current: \n${todayIntakew.toStringAsFixed(1)} mL \nGoal: \n${goal.toStringAsFixed(1)} mL',
                                // Display current and goal intake
                                style: const TextStyle(
                                  color: AppColors.fitnessSecondaryTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 46),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: const FlTitlesData(
                              show: true,
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true, reservedSize: 50),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true, reservedSize: 30),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: cumulativeSpots,
                                // Cumulative spots
                                isCurved: false,
                                color: const Color(0xFF468CF6),
                                barWidth: 4,
                                belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFF468CF6)
                                        .withOpacity(0.3)),
                              ),
                            ],
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: goal,
                                  color: Colors.red,
                                  strokeWidth: 2,
                                  dashArray: [5, 5],
                                  label: HorizontalLineLabel(
                                    show: true,
                                    alignment: Alignment.topRight,
                                    labelResolver: (line) =>
                                        'Goal', // Goal line
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY,
                            // Max Y value for bar chart
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final date = DateTime.now().subtract(
                                        Duration(days: 6 - value.toInt()));
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 5,
                                      child: Text(
                                        DateFormat('MM/dd').format(date),
                                        // Date format
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
                              final date = DateTime.now()
                                  .subtract(Duration(days: 6 - index));
                              final intake = dailyIntake[DateTime(
                                      date.year, date.month, date.day)] ??
                                  0.0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: intake.toDouble(), // Bar height
                                    color: const Color(0xFF468CF6),
                                    width: 16,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: dailyIntake.entries.map((entry) {
                          DateTime date = entry.key;
                          double intake = entry.value.toDouble();
                          String formattedDate = DateFormat('MMM dd, yyyy')
                              .format(date); // Format date
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
                                Text(formattedDate,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                Text(
                                  '${intake.toStringAsFixed(1)} mL / ${goal.toStringAsFixed(1)} mL', // Display intake
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: const Color(0xFF468CF6)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
