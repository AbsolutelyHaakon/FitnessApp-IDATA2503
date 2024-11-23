import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/workout_page.dart';
import 'package:fitnessapp_idata2503/modules/appBar.dart';

class WorkoutCalendar extends StatefulWidget {
  @override
  _WorkoutCalendarState createState() => _WorkoutCalendarState();
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Workouts _selectedWorkout = Workouts(
    userId: 'exampleUserId',
    workoutId: 'exampleId',
    name: 'exampleName',
    isPrivate: false,
  );
  List<Workouts> _workouts = [];
  List<Workouts> _filteredWorkouts = [];
  List<UserWorkouts> _upcomingWorkouts = [];
  String _searchQuery = '';
  List<DateTime> workoutDates = [];
  final WorkoutDao _workoutDao = WorkoutDao();
  final UserWorkoutsDao _userWorkoutsDao = UserWorkoutsDao();
  Map<UserWorkouts, String> _userWorkoutsMap = {};


  @override
  void initState() {
    super.initState();
    _filteredWorkouts = _workouts;
    fetchAllWorkouts("All");
  }

  Future<void> fetchWorkoutNames() async {
    _upcomingWorkouts.forEach((workout) {
      _workoutDao.localFetchByWorkoutId(workout.workoutId).then((value) {
        setState(() {
          _userWorkoutsMap[workout] = value.name;
        });
      });
    });
    print(_userWorkoutsMap);
  }



  void fetchAllWorkouts(String category) async {
    List<Workouts> wourkoutsData = await WorkoutDao()
        .localFetchAllById(FirebaseAuth.instance.currentUser?.uid);
    if (!mounted) return;
    setState(() {
      _workouts.clear();
      _workouts = wourkoutsData;
      _filteredWorkouts = _workouts;
    });
    await fetchUpcomingWorkouts();
    await fetchWorkoutNames();
  }

  void _filterWorkouts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredWorkouts = _workouts
          .where((workout) =>
          workout.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _clearFilter() {
    setState(() {
      _searchQuery = '';
      _filteredWorkouts = _workouts;
    });
  }

  void addToCalendar() async {
    if (FirebaseAuth.instance.currentUser?.uid != null && _selectedDay != null) {
      await _userWorkoutsDao.fireBaseCreateUserWorkout(
          FirebaseAuth.instance.currentUser!.uid,
          _selectedWorkout.workoutId,
          _selectedDay!
      );
      setState(() {
        // Fetch the updated list of upcoming workouts
        fetchUpcomingWorkouts();
      });
    }
  }

  Future<void> fetchUpcomingWorkouts() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      final result = await _userWorkoutsDao.fireBaseFetchUpcomingWorkouts(
          FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        _upcomingWorkouts = result['upcomingWorkouts'];
        workoutDates = _upcomingWorkouts.map((workout) => workout.date).toList();
      });
      print(workoutDates);
    }
  }


  //Check if workoutId exist
  bool workoutExist(String workoutId) {
    return _workouts.any((value) => value.workoutId == workoutId);
  }


  void _showFirstModal(DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        //If all conditions are met (true), restrict user to add a workokut.
        bool canAddWorkout = !_upcomingWorkouts.any((workout) =>
        workout.date.year == selectedDay.year &&
            workout.date.month == selectedDay.month &&
            workout.date.day == selectedDay.day &&
            workoutExist(workout.workoutId)
        );
        String workoutName = 'No workout scheduled';
        for (var workout in _upcomingWorkouts) {
          if (workout.date.year == selectedDay.year &&
              workout.date.month == selectedDay.month &&
              workout.date.day == selectedDay.day) {
            workoutName = _userWorkoutsMap[workout] ?? 'No workout scheduled';
            break;
          }
        }
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.fitnessBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: FractionallySizedBox(
            heightFactor: 0.3,
            widthFactor: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${selectedDay.toLocal().toString().split(' ')[0]}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  workoutName,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),
                //Check if workout can be added
                if(canAddWorkout)
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      //Show add workout modal
                      _showSecondModal();
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        decoration: BoxDecoration(
                          color: AppColors.fitnessMainColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Add workout',
                          style: TextStyle(color: Colors.white),
                        )
                    )
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Select workout modal
  void _showSecondModal() {
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
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16),
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
                              addToCalendar();
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
                              _filteredWorkouts[index].name,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.buildAppBar(context),
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
              _showFirstModal(selectedDay);
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
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  bool isSpecificDate = _upcomingWorkouts.any((value) =>
                  value.date.year == day.year && value.date.month == day.month && value.date.day == day.day && workoutExist(value.workoutId)); // Checks if _workout_id exist in _upcoming
                  return Stack(
                    children: [
                      Center(
                        //Day number, if there is a existing date, make the text red, if not primarycolor
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isSpecificDate ? Colors.red : AppColors.fitnessPrimaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            calendarStyle: const CalendarStyle(
              //Default days
              defaultTextStyle: TextStyle(fontSize: 12),
              //Weekend days
              weekendTextStyle: TextStyle(fontSize: 12),
              selectedTextStyle: TextStyle(
                  fontSize: 12, color: AppColors.fitnessMainColor),
              todayTextStyle: TextStyle(
                  fontSize: 12, color: AppColors.fitnessMainColor),
              outsideDaysVisible: true,
              //Outside days: days that are not in the current month
              outsideTextStyle: TextStyle(
                  fontSize: 12, color: AppColors.fitnessSecondaryTextColor),
              cellMargin: EdgeInsets.all(0),
              //Background color for the callendar
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
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                  fontSize: 12, color: AppColors.fitnessPrimaryTextColor),
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
              weekdayStyle: TextStyle(
                  fontSize: 9, color: AppColors.fitnessPrimaryTextColor),
              weekendStyle: TextStyle(
                  fontSize: 9, color: AppColors.fitnessMainColor),
            ),
          ),
        ),
      ),
    );
  }
}