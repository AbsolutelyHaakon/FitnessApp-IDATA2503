import 'package:fitnessapp_idata2503/modules/admin/general_tab.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/modules/admin/workout_tab.dart';

// Admin panel page. Contains tabs for workout, general settings, and social settings
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 1; // Index of the selected tab

  // List of widgets for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    const WorkoutTab(), // Workout tab
    const GeneralTab(), // General settings tab
    const Text('Social Tab'), // Placeholder for social tab
  ];

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel',
            style: TextStyle(
                color: AppColors.fitnessPrimaryTextColor)), // App bar title
        backgroundColor:
            AppColors.fitnessBackgroundColor, // App bar background color
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor), // Back button icon
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      body: Center(
        child: _widgetOptions
            .elementAt(_selectedIndex), // Display the selected tab
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), // Icon for workout tab
            label: 'Workout', // Label for workout tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Icon for general settings tab
            label: 'General', // Label for general settings tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), // Icon for social tab
            label: 'Social', // Label for social tab
          ),
        ],
        currentIndex: _selectedIndex, // Current selected index
        selectedItemColor:
            AppColors.fitnessMainColor, // Color for selected item
        unselectedItemColor:
            AppColors.fitnessSecondaryTextColor, // Color for unselected items
        backgroundColor: AppColors
            .fitnessBackgroundColor, // Background color of the navigation bar
        onTap: _onItemTapped, // Handle tab selection
      ),
      backgroundColor:
          AppColors.fitnessBackgroundColor, // Background color of the scaffold
    );
  }
}
