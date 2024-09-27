import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 27.0, // Set font size to 30
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: Color(0xFF292929),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Home page!',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}