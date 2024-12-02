import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
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

  Map<String, dynamic> userData = {}; // Map to store user data
  Map<String, dynamic> workoutData = {}; // Map to store workout data

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
    if (FirebaseAuth.instance.currentUser != null) {
      await _fetchUserData(); // Fetch user data
    }
  }

  // Function to fetch user data
  Future<void> _fetchUserData() async {
    final temp = await _userDao
        .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      userData = temp ?? {"error": "No Data"}; // Set user data or error message
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
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
            controller: _tabController, // Tab controller
            indicator: const BoxDecoration(), // Tab indicator
            labelColor:
                AppColors.fitnessMainColor, // Color of selected tab label
            unselectedLabelColor: AppColors
                .fitnessSecondaryTextColor, // Color of unselected tab label
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16), // Style of selected tab label
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16), // Style of unselected tab label
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
                'We use Firebase Firestore as our cloud service, which provides a safe and secure option for storing data. '
                'If you do not wish to have your data stored in the cloud, '
                'you can opt out by pressing the "Cloud Backup Data" switch.',
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
          const SizedBox(height: 20), // Space between elements
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Horizontal padding
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between elements
              children: [
                const Text('Cloud Backup Data'), // Text for the switch
                Switch(
                  value: isCloudBackupEnabled, // Value of the switch
                  onChanged: (value) async {
                    if (!value) {
                      bool confirmChange = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors
                              .fitnessModuleColor, // Background color of dialog
                          title: const Text('Are you sure?',
                              style: TextStyle(
                                  color: AppColors
                                      .fitnessWarningColor)), // Title of dialog
                          content: const Text(
                              'Do you really want to change the cloud backup setting?'), // Content of dialog
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(false), // Close dialog without changing
                              child: const Text(
                                'No',
                                style: TextStyle(
                                    color: AppColors
                                        .fitnessMainColor), // Text color
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(true), // Close dialog and change setting
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                    color: AppColors
                                        .fitnessWarningColor), // Text color
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmChange) {
                        setState(() {
                          isCloudBackupEnabled = value; // Update switch value
                        });
                      }
                    } else {
                      setState(() {
                        isCloudBackupEnabled = value; // Update switch value
                      });
                    }
                  },
                  activeColor:
                      AppColors.fitnessMainColor, // Active color of switch
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Space between elements
          ListTile(
            leading: const Icon(Icons.delete,
                color: AppColors.fitnessWarningColor), // Icon for the list tile
            title: const Text('Delete My Data',
                style: TextStyle(
                    color: AppColors.fitnessWarningColor,
                    fontSize: 18)), // Title of the list tile
            trailing: Transform.scale(
              scale: 0.6, // Scale down the icon
              child: const Icon(CupertinoIcons.right_chevron,
                  color: AppColors.fitnessWarningColor), // Chevron icon
            ),
            onTap: _deleteMyData, // Function to delete data
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
          _buildDataSection(
              'WORKOUTS', _allData['workouts']), // Build workouts data section
          _buildDataSection('EXERCISES',
              _allData['exercises']), // Build exercises data section
          _buildDataSection('USERWORKOUTS',
              _allData['userworkouts']), // Build user workouts data section
          _buildDataSection(
              'POSTS', _allData['posts']), // Build posts data section
          _buildDataSection('USERFOLLOWS',
              _allData['userfollows']), // Build user follows data section
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
                          text: '${entry.value}',
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
        'workouts': 'Workouts content', // Set workouts data
        'exercises': 'Exercises content', // Set exercises data
        'userworkouts': 'User workouts content', // Set user workouts data
        'posts': 'Posts content', // Set posts data
        'userfollows': 'User follows content', // Set user follows data
      };
      _isLoadingData = false; // Set flag to false
    });
  }

  // Function to delete user data
  void _deleteMyData() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            AppColors.fitnessModuleColor, // Background color of dialog
        title: const Text('Delete My Data',
            style: TextStyle(
                color: AppColors.fitnessWarningColor)), // Title of dialog
        content: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text:
                    'Are you sure you want to delete your data? Your account will also be removed.\n\n',
                style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor,
                    fontSize: 15), // Text style
              ),
              TextSpan(
                text: 'This action cannot be undone.',
                style: TextStyle(
                    color: AppColors.fitnessWarningColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold), // Text style
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(false), // Close dialog without deleting
            child: const Text('Cancel',
                style:
                    TextStyle(color: AppColors.fitnessMainColor)), // Text style
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true), // Close dialog and delete data
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.fitnessWarningColor)), // Text style
          ),
        ],
      ),
    );

    if (confirmDelete) {
      // Implement delete data functionality
    }
  }
}
