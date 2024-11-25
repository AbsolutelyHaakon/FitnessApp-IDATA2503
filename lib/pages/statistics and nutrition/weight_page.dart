import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_health_data_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../database/crud/user_dao.dart';
import '../../database/tables/user_health_data.dart';
import '../../styles.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  _WeightPageState createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage>
    with SingleTickerProviderStateMixin {
  Map<DateTime, int> dailyIntake = <DateTime, int>{};
  double goal = 0;
  int weightGoal = 0;
  int weightInitial = 0;
  int todayWeight = 0;
  double weightPercentage = 0;
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchAllUserGoals();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchAllUserGoals() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userGoalsMap = await UserDao()
          .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
      weightGoal = userGoalsMap?["weightTarget"] ?? 1;
      weightInitial = userGoalsMap?["weightInitial"] ?? 1;

      setState(() {
        goal = weightGoal.toDouble();
      });

      await fetchHydrationData();
    }
  }

  Future<void> fetchHydrationData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      var userDataMap = await UserHealthDataDao()
          .fireBaseFetchUserHealthData(FirebaseAuth.instance.currentUser!.uid);
      List<UserHealthData> userData = userDataMap['userHealthData'];
      DateTime today = DateTime.now();
      DateTime todayDate = DateTime(today.year, today.month, today.day);

      Map<DateTime, int> aggregatedData = {};
      todayWeight = 0;
      for (var entry in userData) {
        DateTime date =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        if (entry.weight == null || entry.weight! <= 0) {
          continue;
        }
        if (date == todayDate) {
          if (entry.weight < 300 && entry.weight > 30) {
            todayWeight = entry.weight;
          }
        }
        if (aggregatedData.containsKey(date)) {
          aggregatedData[date] = aggregatedData[date]! + entry.weight!;
        } else {
          aggregatedData[date] = entry.weight!;
        }
      }
      setState(() {
        dailyIntake = {};
        for (var entry in userData) {
          if (entry.weight == null || entry.weight! <= 0) {
            continue;
          }
          DateTime date =
              DateTime(entry.date.year, entry.date.month, entry.date.day);
          if (dailyIntake.containsKey(date)) {
            dailyIntake[date] = entry.weight! > dailyIntake[date]!
                ? entry.weight!
                : dailyIntake[date]!;
          } else {
            dailyIntake[date] = entry.weight!;
          }
        }
        if ((weightInitial - todayWeight).abs() <
            (weightInitial - weightGoal).abs()) {
          weightPercentage = (weightInitial - todayWeight).abs() /
              (weightInitial - weightGoal).abs();
        } else {
          weightPercentage = (todayWeight - weightInitial).abs() /
              (weightGoal - weightInitial).abs();
        }
        if (weightPercentage.isInfinite) {
          weightPercentage = 1;

        }
      });
    }
  }

  Future<void> _addData() async {
    int newWeight = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Set New Weight'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.line_weight, size: 50, color: Colors.blue),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          newWeight = index;
                        });
                      },
                      children: List<Widget>.generate(200, (int index) {
                        return Center(
                          child: Text('$index Kg'),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Save the weight data
                    if (FirebaseAuth.instance.currentUser?.uid != null) {
                      await UserHealthDataDao().fireBaseCreateUserHealthData(
                          FirebaseAuth.instance.currentUser!.uid,
                          null,
                          newWeight,
                          DateTime.now(),
                          null,
                          null,
                          null);
                      fetchHydrationData();
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Weight',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.fitnessPrimaryTextColor,
                    ),
              ),
              titleSpacing: 40,
              backgroundColor: AppColors.fitnessBackgroundColor,
              leading: IconButton(
                icon: const Icon(CupertinoIcons.back,
                    color: AppColors.fitnessMainColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                if (FirebaseAuth.instance.currentUser != null)
                  TextButton(
                    onPressed: () async {
                      _addData();
                    },
                    child: const Text('Add Data',
                        style: TextStyle(color: AppColors.fitnessMainColor)),
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
                                              weightPercentage,
                                          strokeWidth: 18.0,
                                          strokeCap: StrokeCap.round,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                      Color>(
                                                  AppColors.fitnessMainColor),
                                          backgroundColor:
                                              AppColors.fitnessModuleColor,
                                        ),
                                      ),
                                      Text(
                                        weightInitial == weightGoal
                                            ? '0 Kg'
                                            :
                                        weightInitial > weightGoal
                                            ? '${(weightInitial - weightGoal - (weightInitial - todayWeight)).abs().toStringAsFixed(1)} Kg'
                                            : '${(weightGoal - weightInitial - (todayWeight - weightInitial)).abs().toStringAsFixed(1)} Kg',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        weightInitial > weightGoal
                                            ? 'Lose\n\n\n'
                                            : 'Gain\n\n\n',
                                        style: const TextStyle(
                                          color: AppColors
                                              .fitnessSecondaryTextColor,
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
                                      weightPercentage >= 1
                                          ? 'Congratulations!\n Goal Reached!'
                                          : 'Current: ${todayWeight.toStringAsFixed(1)} Kg \nGoal: ${goal.toStringAsFixed(1)} Kg',
                                      style: const TextStyle(
                                        color:
                                            AppColors.fitnessSecondaryTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 46),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                minY: dailyIntake.values.isNotEmpty
                                    ? dailyIntake.values
                                        .reduce((a, b) => a < b ? a : b)
                                        .toDouble()
                                    : 0.0,
                                maxY: dailyIntake.values.isNotEmpty
                                    ? dailyIntake.values
                                        .reduce((a, b) => a > b ? a : b)
                                        .toDouble()
                                    : 3.0,
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
                                            style: const TextStyle(
                                              color: AppColors.fitnessMainColor,
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
                                        toY: intake.toDouble(),
                                        color: AppColors.fitnessMainColor,
                                        width: 16,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ],
                                  );
                                }),
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
                                        labelResolver: (line) => 'Goal',
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
                          const SizedBox(height: 16),
                          Column(
                            children: dailyIntake.entries.map((entry) {
                              DateTime date = entry.key;
                              double intake = entry.value.toDouble();
                              String formattedDate =
                                  DateFormat('MMM dd, yyyy').format(date);
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.fitnessModuleColor,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                    Text(
                                      '${intake.toStringAsFixed(1)} Kg / ${goal.toStringAsFixed(1)} Kg',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color:
                                                  AppColors.fitnessMainColor),
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
