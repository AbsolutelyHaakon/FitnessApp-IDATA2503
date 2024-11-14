import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/modules/calendar_home_module.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/rings_module.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/wip_module.dart';
import 'package:fitnessapp_idata2503/modules/workout_log_module.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/tables/workout.dart';
import '../modules/date_picker.dart';
import '../modules/homepage widgets/community_module.dart';
import 'package:fitnessapp_idata2503/database/Initialization/get_data_from_server.dart';
import 'social and account/me.dart';

class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
const double commonPadding = 16.0;
const double rowSpacing = 28.0;

class _HomeState extends State<Home> {
  final GetDataFromServer _getDataFromServer = GetDataFromServer();

Map<Workouts, DateTime> workoutMap = {
  new Workouts(workoutId: 'sanjdsadnaslkdnaksl', name: 'Leg day', isPrivate: true, userId: 'user123'): DateTime(1970, 1, 1),
};

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _buildHeader(formattedDate),

              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: WorkoutsBox(workoutMap: workoutMap),
              ),

              _buildModuleRow(
                leftChild: CommunityModule(),
                rightChild: RingsModule(),
              ),
              const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: CalendarHomeModule()
              ),
              _buildModuleRow(
                leftChild: WorkoutLogModule(),
                rightChild: WipModule(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Home',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          _buildProfileAvatar(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () => _navigateToProfile(),
      child: const CircleAvatar(
        radius: 17,
        backgroundImage: NetworkImage(
          'https://media.istockphoto.com/id/1388253782/photo/positive-successful-millennial-business-professional-man-head-shot-portrait.jpg?s=612x612&w=0&k=20&c=uS4knmZ88zNA_OjNaE_JCRuq9qn3ycgtHKDKdJSnGdY=',
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Me(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }



  Widget _buildModuleRow({
    required Widget leftChild,
    required Widget rightChild,
    double topPadding = rowSpacing,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: commonPadding, right: commonPadding, top: topPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: leftChild),
          const SizedBox(width: commonPadding),
          Expanded(child: rightChild),
        ],
      ),
    );
  }
}
