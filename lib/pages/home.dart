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
        title: const Text('Home'),
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