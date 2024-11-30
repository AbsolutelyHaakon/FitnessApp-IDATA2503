import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/globals.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/modules/navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'database/crud/exercise_dao.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Initialize the FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
final WorkoutDao _workoutDao = WorkoutDao();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  // Set up notification settings for Android and iOS
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize local notifications
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Perform first-time startup tasks for Firebase
  await ExerciseDao().fireBaseFirstTimeStartup();
  await _workoutDao.fireBaseFirstTimeStartup();

  // Fetch active user workout and set global variables accordingly
  var userWorkout = await _userWorkoutsDao.fetchActiveUserWorkout();
  if (userWorkout != null) {
    hasActiveWorkout.value = true;
    activeUserWorkoutId.value = userWorkout.userId;
    activeWorkoutId.value = userWorkout.workoutId;
    activeWorkoutName.value = userWorkout.name;
  } else {
    var workout = await _workoutDao.fetchActiveWorkout();
    if (workout != null) {
      hasActiveWorkout.value = true;
      activeWorkoutId.value = workout.workoutId;
      activeWorkoutName.value = workout.name;
    } else {
      hasActiveWorkout.value = false;
      activeWorkoutId.value = '';
      activeWorkoutName.value = '';
    }
  }

  // Run the main application
  runApp(MyApp());
}

// Initialize Firebase based on the platform (iOS or other)
Future<void> _initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    if (Platform.isIOS) {
      await Firebase.initializeApp(
        name: 'fitnessapp2', // Comment: We could not figure out why this is needed for iOS, and why it breaks is if the name is set in Android
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}

// Main application widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
              fontSize: 35),
          headlineLarge: TextStyle(
              color: AppColors.fitnessSecondaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 24),
          displayLarge: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 28),
          displayMedium: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16),
          headlineMedium: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 24),
          bodyMedium: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16),
          headlineSmall: TextStyle(
              color: AppColors.fitnessSecondaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16),
          bodySmall: TextStyle(
              color: AppColors.fitnessSecondaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14),
          labelSmall: TextStyle(
              color: AppColors.fitnessPrimaryTextColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14),
        ),
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: AuthWrapper(),
    );
  }
}

// Wrapper for authentication
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the stream
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // If the user is signed in, pass the user data to the navigation bar
          return CustomNavigationBar(); // Pass user info if needed
        } else {
          // If no user is logged in, load the app without any user-specific data
          return const CustomNavigationBar();
        }
      },
    );
  }
}