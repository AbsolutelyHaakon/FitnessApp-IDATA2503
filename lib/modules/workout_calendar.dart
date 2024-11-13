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
  String _selectedWorkout = 'Leg day';
  final List<String> _workouts = ['Leg day', 'Hike', 'Run', 'Sing', 'Neck', 'Russian deadlift'];
  String _searchQuery = '';
  List<String> _filteredWorkouts = [];

  @override
  void initState() {
    super.initState();
    _filteredWorkouts = _workouts;
  }

  void _filterWorkouts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredWorkouts = _workouts
          .where((workout) => workout.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _clearFilter() {
    setState((){
      _searchQuery = '';
      _filteredWorkouts = _workouts;
    });
  }

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
              showModalBottomSheet(
                context: context,
                isDismissible: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.fitnessBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: FractionallySizedBox(
                      heightFactor: 0.6,
                      widthFactor: 1,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Select workout',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: TextStyle(fontSize: 12),
                              onChanged: _filterWorkouts,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListView.builder(
                                itemCount: _filteredWorkouts.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedWorkout = _filteredWorkouts[index];
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.fitnessSecondaryModuleColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _filteredWorkouts[index],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).whenComplete(_clearFilter);
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