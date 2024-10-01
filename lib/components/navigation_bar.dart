import 'package:fitnessapp_idata2503/pages/upcoming_workouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitnessapp_idata2503/pages/home.dart';
import 'package:fitnessapp_idata2503/pages/workout_page.dart';
import 'package:fitnessapp_idata2503/pages/me.dart';

// Navigation bar for the whole app
// Contains 3 pages: Home, Workout, and Me with icons
// The selected page is highlighted with a different color

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

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
              width: 20.0,
              height: 20.0,
              color:
                  _selectedIndex == 0 ? const Color(0xFFDCDCDC) : const Color(0xFF747474),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/workout.svg',
              width: 30.0,
              height: 30.0,
              color:
                  _selectedIndex == 1 ? const Color(0xFFDCDCDC) : const Color(0xFF747474),
            ),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/me.svg',
              width: 25.0,
              height: 25.0,
              color:
                  _selectedIndex == 2 ? const Color(0xFFDCDCDC) : const Color(0xFF747474),
            ),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFDCDCDC),
        unselectedItemColor: const Color(0xFF747474),
        backgroundColor: const Color(0xFF1A1B1C),
        onTap: _onItemTapped,
        iconSize: 30.0,
        unselectedFontSize: 14.0,
      ),
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return const Home();
      case 1:
        return WorkoutPage();
      case 2:
        return Me();
      default:
        return const Home();
    }
  }
}
