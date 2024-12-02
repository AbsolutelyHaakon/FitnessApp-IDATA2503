import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../database/crud/user_dao.dart';
import '../../database/tables/user_health_data.dart';
import '../../styles.dart';

class CalorieIntakePage extends StatefulWidget {
  const CalorieIntakePage({super.key});

  @override
  _CalorieIntakePageState createState() => _CalorieIntakePageState();
}

class _CalorieIntakePageState extends State<CalorieIntakePage>
    with SingleTickerProviderStateMixin {
  Map<DateTime, int> dailyIntake =
  <DateTime, int>{}; // Stores daily calorie intake
  List<MapEntry<DateTime, int>> hourlyIntake =
  []; // Stores hourly calorie intake
  double goal = 2500; // Example goal in milliliters
  bool isLoading = false; // Loading state
  late AnimationController _animationController; // Animation controller
  late Animation<double> _animation; // Animation
  late Future<void> _fetchDataFuture; // Future for fetching data
  DateTime today = DateTime.now(); // Today's date
  double todayIntake = 0; // Today's calorie intake
  double intakePercentage = 0.0; // Percentage of calorie intake goal achieved
  List<FlSpot> cumulativeSpots =
  []; // Cumulative calorie intake spots for graph
  double cumulativeSum = 0; // Cumulative sum of calorie intake

  @override
  void initState() {
    super.initState();
    fetchAllUserGoals(); // Fetch user goals from the database
    _fetchDataFuture = fetchIntakeData(); // Fetch intake data

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add listener to animation controller
    _animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  // Fetch user goals from the database
  Future<void> fetchAllUserGoals() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userGoalsMap = await UserDao()
          .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
      var goalInt = userGoalsMap?["calorieIntakeTarget"] ?? 2000;
      setState(() {
        goal = goalInt.toDouble();
      });
    }
  }

  // Fetch intake data from the database
  Future<void> fetchIntakeData() async {
    todayIntake = 0;
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
        if (entry.caloriesIntake == null || entry.caloriesIntake! <= 0) {
          continue;
        }
        if (aggregatedData.containsKey(date)) {
          aggregatedData[date] = aggregatedData[date]! + entry.caloriesIntake!;
        } else {
          aggregatedData[date] = entry.caloriesIntake!;
        }
        if (date == todayDate) {
          if (entry.caloriesIntake != null) {
            todayIntake += entry.caloriesIntake!;
          }
        }
      }
      setState(() {
        dailyIntake = aggregatedData;
        intakePercentage = todayIntake / goal;

        DateTime now = DateTime.now();
        today = DateTime(now.year, now.month, now.day);

        hourlyIntake = userData
            .where((e) => e.caloriesIntake != null && e.caloriesIntake! >= 1)
            .map((e) => MapEntry(e.date, e.caloriesIntake!))
            .toList();

        hourlyIntake.insert(0, MapEntry(today, 0));
      });
    }
  }

  // Add new calorie intake data
  Future<void> _addData() async {
    int calorieIntake = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Calorie Intake',
                  style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fastfood, size: 50, color: Colors.orange),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.orange),
                        onPressed: () {
                          setState(() {
                            if (calorieIntake > 0) calorieIntake -= 100;
                          });
                        },
                      ),
                      Text('$calorieIntake cal',
                          style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.fitnessPrimaryTextColor)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.orange),
                        onPressed: () {
                          setState(() {
                            calorieIntake += 100;
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel',
                      style:
                      TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                ),
                TextButton(
                  onPressed: () async {
                    // Save the calorie intake data
                    if (FirebaseAuth.instance.currentUser?.uid != null) {
                      await UserHealthDataDao().fireBaseCreateUserHealthData(
                        FirebaseAuth.instance.currentUser!.uid,
                        null,
                        null,
                        DateTime.now(),
                        calorieIntake,
                        null,
                        null,
                      );
                      fetchIntakeData(); // Refresh intake data
                    }
                    Navigator.of(context).pop();
                  },
                  child:
                  const Text('OK', style: TextStyle(color: Colors.orange)),
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
        : 3.0;

    // Filter hourlyIntake to only include entries from today
    DateTime today = DateTime.now();
    List<MapEntry<DateTime, int>> todayIntakeEntries =
    hourlyIntake.where((entry) {
      return entry.key.year == today.year &&
          entry.key.month == today.month &&
          entry.key.day == today.day;
    }).toList();

    cumulativeSpots.clear();
    cumulativeSum = 0;

    todayIntakeEntries.sort((a, b) => a.key.hour.compareTo(b.key.hour));

    for (var entry in todayIntakeEntries) {
      cumulativeSum += entry.value;
      cumulativeSpots.add(FlSpot(entry.key.hour.toDouble(), cumulativeSum));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calorie Intake',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.fitnessPrimaryTextColor,
          ),
        ),
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFFCC7F48)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            TextButton(
              onPressed: () async {
                _addData(); // Add new data
              },
              child: const Text('Add Data',
                  style: TextStyle(color: Color(0xFFCC7F48))),
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
                              _animation.value * (todayIntake / goal),
                              // Progress indicator
                              strokeWidth: 18.0,
                              strokeCap: StrokeCap.round,
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFCC7F48)),
                              backgroundColor:
                              AppColors.fitnessModuleColor,
                            ),
                          ),
                          Text(
                            goal - todayIntake >= 0
                                ? '${(goal - todayIntake).abs()} cal'
                                : '0.0 cal', // Remaining intake
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
                          intakePercentage >= goal
                              ? 'Congratulations!\nGoal Reached!'
                              : 'Current:\n ${todayIntake.toStringAsFixed(1)} cal \nGoal: \n${goal.toStringAsFixed(1)} cal',
                          // Display current and goal intake
                          style: const TextStyle(
                            color: AppColors.fitnessSecondaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
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
                      gridData: FlGridData(show: true),
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
                          color: const Color(0xFFCC7F48),
                          barWidth: 4,
                          belowBarData: BarAreaData(
                              show: true,
                              color: Color(0xFFCC7F48).withOpacity(0.3)),
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
                              style: TextStyle(
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
                                    color: Color(0xFFCC7F48),
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
                              color: Color(0xFFCC7F48),
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
                            '${intake.toStringAsFixed(1)} cal / ${goal.toStringAsFixed(1)} cal', // Display intake
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Color(0xFFCC7F48)),
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