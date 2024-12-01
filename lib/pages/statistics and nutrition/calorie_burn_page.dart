import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../database/crud/user_dao.dart';
import '../../database/tables/user_health_data.dart';
import '../../styles.dart';

class CalorieBurnPage extends StatefulWidget {
  const CalorieBurnPage({super.key});

  @override
  _CalorieBurnPageState createState() => _CalorieBurnPageState();
}

class _CalorieBurnPageState extends State<CalorieBurnPage>
    with SingleTickerProviderStateMixin {
  Map<DateTime, int> dailyBurn = <DateTime, int>{}; // Stores daily burn data
  List<MapEntry<DateTime, int>> hourlyBurn = []; // Stores hourly burn data
  double goal = 400; // Example goal in calories
  bool isLoading = false; // Loading state
  late AnimationController _animationController; // Animation controller
  late Animation<double> _animation; // Animation
  late Future<void> _fetchDataFuture; // Future for fetching data
  DateTime today = DateTime.now(); // Today's date
  double todayBurn = 0; // Calories burned today
  double burnPercentage = 0.0; // Burn percentage
  List<FlSpot> cumulativeSpots = []; // Cumulative spots for line chart
  double cumulativeSum = 0; // Cumulative sum of calories burned

  @override
  void initState() {
    super.initState();
    fetchAllUserGoals(); // Fetch user goals
    _fetchDataFuture = fetchBurnData(); // Fetch burn data

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
      var goalInt = userGoalsMap?["calorieBurnTarget"] ?? 400; // Default goal
      setState(() {
        goal = goalInt.toDouble(); // Set goal
      });
    }
  }

  Future<void> fetchBurnData() async {
    todayBurn = 0; // Reset today's burn
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
        if (entry.caloriesBurned == null || entry.caloriesBurned! <= 0) {
          continue; // Skip invalid data
        }
        if (aggregatedData.containsKey(date)) {
          aggregatedData[date] = aggregatedData[date]! + entry.caloriesBurned!;
        } else {
          aggregatedData[date] = entry.caloriesBurned!;
        }
        if (date == todayDate) {
          if (entry.caloriesBurned != null) {
            todayBurn += entry.caloriesBurned!; // Add to today's burn
          }
        }
      }
      setState(() {
        dailyBurn = aggregatedData; // Set daily burn data
        burnPercentage = todayBurn / goal; // Calculate burn percentage

        DateTime now = DateTime.now();
        today = DateTime(now.year, now.month, now.day);

        hourlyBurn = userData
            .where((e) => e.caloriesBurned != null && e.caloriesBurned! >= 1)
            .map((e) => MapEntry(e.date, e.caloriesBurned!))
            .toList();

        hourlyBurn.insert(0, MapEntry(today, 0)); // Add initial entry
      });
    }
  }

  Future<void> _addData() async {
    int calorieBurn = 0; // Initial calorie burn

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Burned Calories',
                  style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      size: 50, color: Colors.red),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            if (calorieBurn > 0)
                              calorieBurn -= 100; // Decrease burn
                          });
                        },
                      ),
                      Text('$calorieBurn cal',
                          style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.fitnessPrimaryTextColor)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            calorieBurn += 100; // Increase burn
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
                    // Save the calorie burn data
                    if (FirebaseAuth.instance.currentUser?.uid != null) {
                      await UserHealthDataDao().fireBaseCreateUserHealthData(
                        FirebaseAuth.instance.currentUser!.uid,
                        null,
                        null,
                        DateTime.now(),
                        null,
                        calorieBurn,
                        null,
                      );
                      fetchBurnData(); // Refresh data
                    }
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.red)),
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
    double maxY = dailyBurn.values.isNotEmpty
        ? dailyBurn.values.reduce((a, b) => a > b ? a : b).toDouble()
        : 3.0; // Max Y value for bar chart

    // Filter hourlyBurn to only include entries from today
    DateTime today = DateTime.now();
    List<MapEntry<DateTime, int>> todayBurnEntries = hourlyBurn.where((entry) {
      return entry.key.year == today.year &&
          entry.key.month == today.month &&
          entry.key.day == today.day;
    }).toList();

    cumulativeSpots.clear();
    cumulativeSum = 0;

    todayBurnEntries
        .sort((a, b) => a.key.hour.compareTo(b.key.hour)); // Sort by hour

    for (var entry in todayBurnEntries) {
      cumulativeSum += entry.value; // Calculate cumulative sum
      cumulativeSpots
          .add(FlSpot(entry.key.hour.toDouble(), cumulativeSum)); // Add spot
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calorie Burn',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.fitnessPrimaryTextColor,
              ),
        ),
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFFCC4848)),
          onPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            TextButton(
              onPressed: () async {
                _addData(); // Add new data
              },
              child: const Text('Add Data',
                  style: TextStyle(color: Color(0xFFCC4848))),
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
                                    value:
                                        _animation.value * (todayBurn / goal),
                                    // Progress indicator
                                    strokeWidth: 18.0,
                                    strokeCap: StrokeCap.round,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFCC4848)),
                                    backgroundColor:
                                        AppColors.fitnessModuleColor,
                                  ),
                                ),
                                Text(
                                  goal - todayBurn >= 0
                                      ? '${(goal - todayBurn).abs()} cal'
                                      : '0.0 cal', // Remaining burn
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'Burn\n\n\n',
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
                                burnPercentage >= goal
                                    ? 'Congratulations!\nGoal Reached!'
                                    : 'Current:\n ${todayBurn.toStringAsFixed(1)} cal \nGoal:\n ${goal.toStringAsFixed(1)} cal',
                                // Display current and goal burn
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
                                color: const Color(0xFFCC4848),
                                barWidth: 4,
                                belowBarData: BarAreaData(
                                    show: true,
                                    color: const Color(0xFFCC4848)
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
                                          color: Color(0xFFCC4848),
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
                              final burn = dailyBurn[DateTime(
                                      date.year, date.month, date.day)] ??
                                  0.0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: burn.toDouble(), // Bar height
                                    color: const Color(0xFFCC4848),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: dailyBurn.entries.map((entry) {
                          DateTime date = entry.key;
                          double burn = entry.value.toDouble();
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
                                  '${burn.toStringAsFixed(1)} cal / ${goal.toStringAsFixed(1)} cal', // Display burn
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: const Color(0xFFCC4848)),
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
