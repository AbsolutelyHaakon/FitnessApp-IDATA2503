import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:table_calendar/table_calendar.dart";
import 'package:fitnessapp_idata2503/styles.dart';

class WorkoutCalendar extends StatefulWidget {
  @override
  _WorkoutCalendarState createState() => _WorkoutCalendarState();
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          color: AppColors.fitnessBackgroundColor,
          child: TableCalendar(
            locale: 'en_US',
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(fontSize: 12),
              weekendTextStyle: TextStyle(fontSize: 12),
              selectedTextStyle: TextStyle(fontSize: 12, color: AppColors.fitnessMainColor),
              todayTextStyle: TextStyle(fontSize: 12, color: AppColors.fitnessMainColor),
              outsideDaysVisible: true,
              outsideTextStyle: TextStyle(fontSize: 12, color: AppColors.fitnessSecondaryTextColor),
              cellMargin: EdgeInsets.all(0),
              rowDecoration: BoxDecoration(
                color: AppColors.fitnessBackgroundColor,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.fitnessBackgroundColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(fontSize: 12, color: AppColors.fitnessPrimaryTextColor),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.fitnessPrimaryTextColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.fitnessPrimaryTextColor,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 9, color: AppColors.fitnessPrimaryTextColor),
              weekendStyle: TextStyle(fontSize: 9, color: AppColors.fitnessMainColor),
            ),
          ),
        ),
      ),
    );
  }
}