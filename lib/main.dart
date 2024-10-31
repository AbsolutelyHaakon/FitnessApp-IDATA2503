import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/components/navigation_bar.dart';
import 'database/database_to_json.dart';
import 'database/dummy_data.dart';
import 'database/database_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DatabaseService().initDatabase();
  await DummyData().insertAllDummyData();
  final databaseToJson = DatabaseToJson();
  final jsonString = await databaseToJson.convertDatabaseToJson();
  print(jsonString);
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
      home: CustomNavigationBar(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}