import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/modules/rings_module.dart';
import 'package:fitnessapp_idata2503/modules/wip_module.dart';
import 'package:fitnessapp_idata2503/modules/workout_log_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/upcoming_workouts_box.dart';
import '../modules/community_module.dart';
import 'package:fitnessapp_idata2503/database/Initialization/get_data_from_server.dart';

class Home extends StatefulWidget {
  final User? user;
  const Home({super.key, this.user});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final GetDataFromServer _getDataFromServer = GetDataFromServer();

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 90),
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: AppColors.fitnessSecondaryTextColor,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 35.0,
                      color: AppColors.fitnessPrimaryTextColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: UpcomingWorkoutsBox(
                  title: 'First Workout!',
                  category: 'Full Body',
                  date: DateTime.now(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CommunityModule(),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: RingsModule(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 32.0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: WorkoutLogModule(),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: WipModule(user: widget.user),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _getDataFromServer.syncExercises(widget.user?.uid ?? '');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sync completed')),
                        );
                      },
                      child: Text('Sync Data From Firebase'),
                    ),
                  ],
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