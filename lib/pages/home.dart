import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/rings_module.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/wip_module.dart';
import 'package:fitnessapp_idata2503/modules/workout_log_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modules/workouts_box.dart';
import '../modules/homepage widgets/community_module.dart';
import 'package:fitnessapp_idata2503/database/Initialization/get_data_from_server.dart';

import 'me.dart';

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
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 70),
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
                          padding: EdgeInsets.only(left: 20.0),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, top: 90.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(

                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const Me(),
                            transitionsBuilder:
                                (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 17,
                        backgroundImage: NetworkImage(
                            'https://media.istockphoto.com/id/1388253782/photo/positive-successful-millennial-business-professional-man-head-shot-portrait.jpg?s=612x612&w=0&k=20&c=uS4knmZ88zNA_OjNaE_JCRuq9qn3ycgtHKDKdJSnGdY='),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 16.0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CommunityModule(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RingsModule(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 32.0, bottom: 0),
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
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
