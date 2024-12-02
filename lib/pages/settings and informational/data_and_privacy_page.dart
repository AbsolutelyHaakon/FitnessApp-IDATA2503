import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/exercise_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/modules/workouts_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// This page handles data and privacy settings for the user
class DataAndPrivacyPage extends StatefulWidget {
  const DataAndPrivacyPage({super.key});

  @override
  _DataAndPrivacyPageState createState() => _DataAndPrivacyPageState();
}

class _DataAndPrivacyPageState extends State<DataAndPrivacyPage>
    with SingleTickerProviderStateMixin {
  bool isCloudBackupEnabled = true; // Flag to check if cloud backup is enabled
  bool _viewDataPressed =
      false; // Flag to check if "View Your Data" button is pressed
  bool _isLoadingData = false; // Flag to check if data is loading
  Map<String, dynamic> _allData = {}; // Map to store all data
  late TabController _tabController; // Controller for tab navigation

  final UserDao _userDao = UserDao(); // DAO for user data
  final userId = FirebaseAuth.instance.currentUser?.uid; // User ID

  Map<String, dynamic> userData = {}; // Map to store user data
  List<Workouts> workoutData = []; // Map to store workout data
  Map<String, dynamic> exerciseData = {}; // Map to store exercise data

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        length: 2, vsync: this); // Initialize tab controller with 2 tabs
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose tab controller
    super.dispose();
  }

  // Function to fetch all data
  Future<void> _fetchData() async {
    if (userId != null) {
      await _fetchUserData(); // Fetch user data
      await fetchWorkoutData(); // Fetch workout data
      await fetchExerciseData(); // Fetch exercise data
    }
  }

  // Function to fetch user data
  Future<void> _fetchUserData() async {
    final temp = await _userDao.fireBaseGetUserData(userId!);
    setState(() {
      userData = temp ?? {"error": "No Data"}; // Set user data or error message
    });
  }

  Future<void> fetchWorkoutData() async {
    final temp = await WorkoutDao().fireBaseFetchAllWorkouts(userId!);
    setState(() {
      workoutData = temp['workouts']; // Set workout data
    });
  }

  Future<void> fetchExerciseData() async {
    final temp = await ExerciseDao().fireBaseFetchAllExercisesFromFireBase(userId!);
    setState(() {
      exerciseData = temp; // Set exercise data
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: AppColors.fitnessBackgroundColor,
          backgroundColor:
              AppColors.fitnessBackgroundColor, // Background color of app bar
          title: const Text('Data and Privacy',
              style: TextStyle(
                  color:
                      AppColors.fitnessPrimaryTextColor)), // Title of app bar
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.fitnessMainColor), // Back button
            onPressed: () =>
                Navigator.of(context).pop(), // Go back to previous page
          ),
          bottom: TabBar(
            controller: _tabController,
            // Tab controller
            indicator: const BoxDecoration(),
            // Tab indicator
            labelColor: AppColors.fitnessMainColor,
            // Color of selected tab label
            unselectedLabelColor: AppColors.fitnessSecondaryTextColor,
            // Color of unselected tab label
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            // Style of selected tab label
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            // Style of unselected tab label
            tabs: const [
              Tab(text: 'Settings'), // Settings tab
              Tab(text: 'Data'), // Data tab
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController, // Tab controller
          children: [
            _buildSettingsTab(), // Build settings tab
            _buildDataTab(), // Build data tab
          ],
        ),
        backgroundColor:
            AppColors.fitnessBackgroundColor, // Background color of scaffold
      ),
    );
  }

  // Function to build settings tab
  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the content
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        children: [
          const SizedBox(height: 20), // Space between elements
          Align(
            alignment: Alignment.center, // Center align the container
            child: Container(
              padding:
                  const EdgeInsets.all(16.0), // Padding inside the container
              decoration: const BoxDecoration(
                color: AppColors
                    .fitnessModuleColor, // Background color of container
                borderRadius:
                    BorderRadius.all(Radius.circular(10.0)), // Rounded corners
              ),
              child: const Text(
                'Fitness App stores your data both locally and in the cloud. '
                'Local data cannot be accessed by anyone but you. Cloud data lets you sync your data across devices. '
                'We use Firebase Firestore as our cloud service, which provides a safe and secure option for storing data. ',
                textAlign: TextAlign.center, // Center align the text
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor, // Text color
                  fontSize: 15, // Text size
                  fontWeight: FontWeight.w500, // Text weight
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Space between elements
          ListTile(
            leading: const Icon(Icons.visibility,
                color: AppColors.fitnessMainColor), // Icon for the list tile
            title: const Text('View Your Data',
                style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor,
                    fontSize: 18)), // Title of the list tile
            trailing: Transform.scale(
              scale: 0.6, // Scale down the icon
              child: const Icon(CupertinoIcons.right_chevron,
                  color: AppColors.fitnessMainColor), // Chevron icon
            ),
            onTap: _viewYourData, // Function to view data
          ),
        ],
      ),
    );
  }

  // Function to build data tab
  Widget _buildDataTab() {
    if (!_viewDataPressed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
        child: Center(
          child: Text(
            'Click "View Your Data" to see this page',
            textAlign: TextAlign.center, // Center align the text
            style: TextStyle(
              color: AppColors.fitnessSecondaryTextColor, // Text color
              fontSize: 18, // Text size
            ),
          ),
        ),
      );
    }

    if (_isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.fitnessMainColor, // Color of progress indicator
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0), // Padding around the content
      child: ListView(
        children: [
          _buildDataSection(
              'USERDATA', _allData['userdata']), // Build user data section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
                child: Text(
                  'YOUR WORKOUTS',
                  style: TextStyle(
                    color: AppColors.fitnessMainColor, // Text color
                    fontSize: 20, // Text size
                    fontWeight: FontWeight.bold, // Text weight
                  ),
                ),
              ),
              WorkoutsBox(
                workouts: [
                  ...workoutData.where((workout) =>
                  workout.userId == userId)
                      .toList(),
                ],
                isSearch: false,
                isHome: false,
                isToday: false,
              ),
            ],
          ), // Build workouts data section
          _buildDataSection('EXERCISES',
              _allData['exercises']), // Build exercises data section// Build user workouts data section
        ],
      ),
    );
  }

  // Function to build data section
  Widget _buildDataSection(String title, dynamic data) {
    return Container(
      padding: const EdgeInsets.all(16.0), // Padding inside the container
      margin:
          const EdgeInsets.only(bottom: 20.0), // Margin around the container
      decoration: BoxDecoration(
        color: AppColors.fitnessModuleColor, // Background color of container
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.fitnessMainColor, // Text color
              fontSize: 20, // Text size
              fontWeight: FontWeight.bold, // Text weight
            ),
          ),
          const SizedBox(height: 10), // Space between elements
          if (data is Map<String, dynamic>)
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8.0), // Padding around the entry
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(
                            color: AppColors.fitnessMainColor, // Text color
                            fontSize: 16, // Text size
                            fontWeight: FontWeight.bold, // Text weight
                          ),
                        ),
                        TextSpan(
                          text: entry.value.toString().replaceAll('[', '').replaceAll(']', ''),
                          style: const TextStyle(
                            color:
                                AppColors.fitnessPrimaryTextColor, // Text color
                            fontSize: 16, // Text size
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          if (data is! Map<String, dynamic>)
            Text(
              data.toString(),
              style: const TextStyle(
                color: AppColors.fitnessPrimaryTextColor, // Text color
                fontSize: 16, // Text size
              ),
            ),
        ],
      ),
    );
  }

  // Function to view user data
  void _viewYourData() async {
    setState(() {
      _viewDataPressed = true; // Set flag to true
      _isLoadingData = true; // Set flag to true
    });

    _tabController.animateTo(1); // Switch to data tab
    await _fetchData(); // Fetch data

    setState(() {
      _allData = {
        'userdata': userData, // Set user data
        'exercises': exerciseData, // Set exercises data
        'posts': 'Posts content', // Set posts data
        'userfollows': 'User follows content', // Set user follows data
      };
      _isLoadingData = false; // Set flag to false
    });
  }

}
