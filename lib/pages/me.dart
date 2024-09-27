import 'package:flutter/material.dart';

class Me extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
      ),
      body: const Center(
        child: Text('Welcome to the Me page!'),
      ),
    );
  }
}