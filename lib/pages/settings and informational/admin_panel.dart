import 'package:fitnessapp_idata2503/modules/admin/general_tab.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/modules/admin/workout_tab.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    WorkoutTab(),
    GeneralTab(),
    const Text('Social Tab'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'General',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Social',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.fitnessMainColor,
        unselectedItemColor: AppColors.fitnessSecondaryTextColor,
        backgroundColor: AppColors.fitnessBackgroundColor,
        onTap: _onItemTapped,
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}