import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/navigation_bar.dart';
import 'database/dummy_data.dart';
import 'database/database_service.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DatabaseService().initDatabase();
  // await DummyData().insertAllDummyData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        fontFamily: 'Inter', // Set Inter as the default font
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // If the user is signed in, pass the user data to the navigation bar
          return CustomNavigationBar(user: snapshot.data); // Pass user info if needed
        } else {
          // If no user is logged in, load the app without any user-specific data
          return CustomNavigationBar();
        }
      },
    );
  }
}
