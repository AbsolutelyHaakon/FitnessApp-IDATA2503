import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataAndPrivacyPage extends StatefulWidget {
  @override
  _DataAndPrivacyPageState createState() => _DataAndPrivacyPageState();
}

class _DataAndPrivacyPageState extends State<DataAndPrivacyPage> with SingleTickerProviderStateMixin {
  bool isCloudBackupEnabled = true;
  bool _viewDataPressed = false;
  bool _isLoadingData = false;
  Map<String, dynamic> _allData = {};
  late TabController _tabController;

  final UserDao _userDao = UserDao();
  final WorkoutDao _workoutDao = WorkoutDao();

  Map<String, dynamic> userData = {};
  Map<String,dynamic> workoutData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await _fetchUserData();
      await _fetchWorkoutData();
    }
  }

  Future<void> _fetchUserData() async {
  final temp = await _userDao.fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);
  setState(() {
    userData = temp ?? {"error": "No Data"};
  });
}

  Future<void> _fetchWorkoutData() async {
    final temp = await _workoutDao.localFetchAllById(FirebaseAuth.instance.currentUser!.uid,true);
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.fitnessBackgroundColor,
          title: const Text('Data and Privacy',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.fitnessMainColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicator: const BoxDecoration(),
            labelColor: AppColors.fitnessMainColor,
            unselectedLabelColor: AppColors.fitnessSecondaryTextColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: const [
              Tab(text: 'Settings'),
              Tab(text: 'Data'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSettingsTab(),
            _buildDataTab(),
          ],
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.fitnessModuleColor,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: const Text(
                'Fitness App stores your data both locally and in the cloud. '
                'Local data cannot be accessed by anyone but you. Cloud data lets you sync your data across devices. '
                'We use Firebase Firestore as our cloud service, which provides a safe and secure option for storing data. '
                'If you do not wish to have your data stored in the cloud, '
                'you can opt out by pressing the "Cloud Backup Data" switch.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.visibility, color: AppColors.fitnessMainColor),
            title: const Text('View Your Data',
                style: TextStyle(
                    color: AppColors.fitnessPrimaryTextColor, fontSize: 18)),
            trailing: Transform.scale(
              scale: 0.6,
              child: const Icon(CupertinoIcons.right_chevron,
                  color: AppColors.fitnessMainColor),
            ),
            onTap: _viewYourData,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cloud Backup Data'),
                Switch(
                  value: isCloudBackupEnabled,
                  onChanged: (value) async {
                    if (!value) {
                      bool confirmChange = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.fitnessModuleColor,
                          title: const Text('Are you sure?',
                              style: TextStyle(
                                  color: AppColors.fitnessWarningColor)),
                          content: const Text(
                              'Do you really want to change the cloud backup setting?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'No',
                                style: TextStyle(
                                    color: AppColors.fitnessMainColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                    color: AppColors.fitnessWarningColor),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmChange) {
                        setState(() {
                          isCloudBackupEnabled = value;
                        });
                      }
                    } else {
                      setState(() {
                        isCloudBackupEnabled = value;
                      });
                    }
                  },
                  activeColor: AppColors.fitnessMainColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.delete, color: AppColors.fitnessWarningColor),
            title: const Text('Delete My Data',
                style: TextStyle(
                    color: AppColors.fitnessWarningColor, fontSize: 18)),
            trailing: Transform.scale(
              scale: 0.6,
              child: const Icon(CupertinoIcons.right_chevron,
                  color: AppColors.fitnessWarningColor),
            ),
            onTap: _deleteMyData,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    if (!_viewDataPressed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            'Click "View Your Data" to see this page',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.fitnessSecondaryTextColor,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    if (_isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.fitnessMainColor,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDataSection('USERDATA', _allData['userdata']),
          _buildDataSection('WORKOUTS', _allData['workouts']),
          _buildDataSection('EXERCISES', _allData['exercises']),
          _buildDataSection('USERWORKOUTS', _allData['userworkouts']),
          _buildDataSection('POSTS', _allData['posts']),
          _buildDataSection('USERFOLLOWS', _allData['userfollows']),
        ],
      ),
    );
  }

Widget _buildDataSection(String title, dynamic data) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    margin: const EdgeInsets.only(bottom: 20.0),
    decoration: BoxDecoration(
      color: AppColors.fitnessModuleColor,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.fitnessMainColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (data is Map<String, dynamic>)
          ...data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: TextStyle(
                          color: AppColors.fitnessMainColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '${entry.value}',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        if (data is! Map<String, dynamic>)
          Text(
            data.toString(),
            style: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontSize: 16,
            ),
          ),
      ],
    ),
  );
}

  void _viewYourData() async {
    setState(() {
      _viewDataPressed = true;
      _isLoadingData = true;
    });

    _tabController.animateTo(1);
    await _fetchData();

      setState(() {
        _allData = {
          'userdata': userData,
          'workouts': 'Workouts content',
          'exercises': 'Exercises content',
          'userworkouts': 'User workouts content',
          'posts': 'Posts content',
          'userfollows': 'User follows content',
        };
        _isLoadingData = false;
      });
  }

  void _deleteMyData() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.fitnessModuleColor,
        title: const Text('Delete My Data',
            style: TextStyle(color: AppColors.fitnessWarningColor)),
        content: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text:
                    'Are you sure you want to delete your data? Your account will also be removed.\n\n',
                style: TextStyle(color: AppColors.fitnessPrimaryTextColor, fontSize: 15),
              ),
              TextSpan(
                text: 'This action cannot be undone.',
                style: TextStyle(color: AppColors.fitnessWarningColor, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.fitnessMainColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.fitnessWarningColor)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      // Implement delete data functionality
    }
  }
}