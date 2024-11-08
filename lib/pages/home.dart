import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/rings_module.dart';
import 'package:fitnessapp_idata2503/modules/homepage%20widgets/wip_module.dart';
import 'package:fitnessapp_idata2503/modules/workout_log_module.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modules/homepage widgets/community_module.dart';
import 'package:fitnessapp_idata2503/database/Initialization/get_data_from_server.dart';
import 'social and account/me.dart';

class Home extends StatefulWidget {
  final User? user;

  const Home({super.key, this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GetDataFromServer _getDataFromServer = GetDataFromServer();

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
              _buildModuleRow(
                leftChild: CommunityModule(),
                rightChild: RingsModule(),
              ),
              _buildModuleRow(
                leftChild: WorkoutLogModule(),
                rightChild: WipModule(user: widget.user),
                topPadding: 12.0,
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
        pageBuilder: (context, animation, secondaryAnimation) => Me(user: widget.user),
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
    double topPadding = 16.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: topPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: leftChild),
          const SizedBox(width: 8),
          Expanded(child: rightChild),
        ],
      ),
    );
  }
}
