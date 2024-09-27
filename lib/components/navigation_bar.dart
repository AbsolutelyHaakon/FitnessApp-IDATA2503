import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitnessapp_idata2503/pages/home.dart';
import 'package:fitnessapp_idata2503/pages/workout.dart';
import 'package:fitnessapp_idata2503/pages/me.dart';

class CustomNavigationBar extends StatefulWidget {
  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home.svg',
              width: 30.0, // Adjust the width
              height: 30.0, // Adjust the height
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/workout.svg',
              width: 30.0, // Adjust the width
              height: 30.0, // Adjust the height
            ),
            label: 'Exercise',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFDCDCDC),
        unselectedItemColor: Color(0xFF747474),
        backgroundColor: Color(0xFF3A3A3A),
        onTap: _onItemTapped,
        iconSize: 30.0, // Adjust the icon size
        selectedFontSize: 16.0, // Adjust the selected font size
        unselectedFontSize: 14.0, // Adjust the unselected font size
      ),
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return Home();
      case 1:
        return Workout();
      case 2:
        return Me();
      default:
        return Home();
    }
  }
}