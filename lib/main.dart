import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/navigation_bar.dart';
import 'database/dummy_data.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        fontFamily: 'Inter',
        // Set Inter as the default font
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
          return CustomNavigationBar(
              user: snapshot.data); // Pass user info if needed
        } else {
          // If no user is logged in, load the app without any user-specific data
          return const CustomNavigationBar();
        }
      },
    );
  }
}
