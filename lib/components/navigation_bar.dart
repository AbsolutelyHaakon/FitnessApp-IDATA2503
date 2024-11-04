import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitnessapp_idata2503/pages/home.dart';
import 'package:fitnessapp_idata2503/pages/workout_page.dart';
import 'package:fitnessapp_idata2503/pages/me.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Navigation bar for the whole app
// Contains 3 pages: Home, Workout, and Me with icons
// The selected page is highlighted with a different color

// Last edited: 27/09/2024
// Last edited by: Matti Kjellstadli

class CustomNavigationBar extends StatefulWidget {
  final User? user; // Add a User parameter to the navigation bar

  const CustomNavigationBar({Key? key, this.user}) : super(key: key);

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // If selected is the same, do nothing
    if (_selectedIndex == index) {
      //Do nothing
      return;
    }
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
              color: _selectedIndex == 0 ? AppColors.fitnessMainColor : AppColors.fitnessSecondaryTextColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/workout.svg',
              width: 30.0,
              height: 30.0,
              color: _selectedIndex == 1 ? AppColors.fitnessMainColor : AppColors.fitnessSecondaryTextColor,
            ),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/me.svg',
              width: 25.0,
              height: 25.0,
              color: _selectedIndex == 2 ? AppColors.fitnessMainColor : AppColors.fitnessSecondaryTextColor,
            ),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.fitnessMainColor,
        unselectedItemColor: AppColors.fitnessSecondaryTextColor,
        backgroundColor: AppColors.fitnessBackgroundColor,
        onTap: _onItemTapped,
        iconSize: 30.0,
        unselectedFontSize: 14.0,
      ),
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return Home(user: widget.user);
      case 1:
        return WorkoutPage(user: widget.user); // Pass the user to the workout page
      case 2:
        return Me(user: widget.user); // Pass the user to the Me page
      default:
        return Home(user: widget.user);
    }
  }
}
