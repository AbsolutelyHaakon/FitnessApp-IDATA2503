import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:fitnessapp_idata2503/modules/appBar.dart';

// Workout calendar widget
class WorkoutCalendar extends StatefulWidget {
  @override
  _WorkoutCalendarState createState() => _WorkoutCalendarState();
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Default calendar format
  DateTime _focusedDay = DateTime.now(); // Currently focused day
  DateTime? _selectedDay; // Selected day
  Workouts _selectedWorkout = const Workouts(
    userId: 'exampleUserId',
    workoutId: 'exampleId',
    name: 'exampleName',
    isPrivate: false,
    isDeleted: false,
  ); // Default selected workout
  List<Workouts> _workouts = []; // List of all workouts
  List<Workouts> _filteredWorkouts = []; // List of filtered workouts
  List<UserWorkouts> _upcomingWorkouts = []; // List of upcoming workouts
  String _searchQuery = ''; // Search query for filtering workouts
  List<DateTime> workoutDates = []; // List of workout dates
  final WorkoutDao _workoutDao = WorkoutDao(); // Workout DAO instance
  final UserWorkoutsDao _userWorkoutsDao =
      UserWorkoutsDao(); // User workouts DAO instance
  Map<UserWorkouts, String> _userWorkoutsMap =
      {}; // Map of user workouts to workout names
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'localUser';

  @override
  void initState() {
    super.initState();
    fetchAllWorkouts("All"); // Fetch all workouts on initialization
  }

  // Fetch workout names for upcoming workouts
  Future<void> fetchWorkoutNames() async {
    _upcomingWorkouts.forEach((workout) {
      _workoutDao.localFetchByWorkoutId(workout.workoutId).then((value) {
        if (value == null) return;
        setState(() {
          _userWorkoutsMap[workout] = '${value.name} - ${value.description}';
        });
      });
    });
  }

  // Fetch all workouts based on category
  void fetchAllWorkouts(String category) async {
    List<Workouts> wourkoutsData = await WorkoutDao().localFetchAllById(userId);
    if (!mounted) return;
    setState(() {
      _workouts.clear();
      _workouts = wourkoutsData;
      _filteredWorkouts = _workouts;
    });
    await fetchUpcomingWorkouts();
    await fetchWorkoutNames();
  }

  // Filter workouts based on search query
  void _filterWorkouts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredWorkouts = _workouts
          .where((workout) =>
              workout.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Clear the search filter
  void _clearFilter() {
    setState(() {
      _searchQuery = '';
      _filteredWorkouts = _workouts;
    });
  }

  // Add selected workout to calendar
  void addToCalendar() async {
    if (_selectedDay != null && userId != 'localUser') {
      await _userWorkoutsDao.fireBaseCreateUserWorkout(
          userId, _selectedWorkout.workoutId, _selectedDay!);
    } // Handle adding workout to calendar when not logged in
    else if (userId == 'localUser' && _selectedDay != null) {
      _userWorkoutsDao.localCreate(UserWorkouts(
        userId: 'localUser',
        // localUser is the local "general" user id
        workoutId: _selectedWorkout.workoutId,
        date: _selectedDay!,
        userWorkoutId: '1',
        // If id == 1 --> It will generate a random one in the localCreate function
        isActive: false, // It should not be active by default
      ));
    }
    await fetchUpcomingWorkouts();
    await fetchWorkoutNames();
  }

  // Fetch upcoming workouts for the user
  Future<void> fetchUpcomingWorkouts() async {
    final result =
        await _userWorkoutsDao.localFetchUpcomingUserWorkouts(userId);
    setState(() {
      _upcomingWorkouts = result;
      workoutDates = _upcomingWorkouts.map((workout) => workout.date).toList();
    });
  }

  // Replace an existing workout with a new one
  Future<void> replaceExisting(UserWorkouts userWorkout) async {
    if (userId != 'localUser') {
      final success = await _userWorkoutsDao.fireBaseReplaceUserWorkout(
          userWorkout, _selectedWorkout);
      if (success) {
        await fetchUpcomingWorkouts();
        await fetchWorkoutNames();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: AppColors.fitnessPrimaryTextColor),
              SizedBox(width: 8),
              Text(
                'Workout replaced',
                style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
              ),
            ],
          ),
          backgroundColor: AppColors.fitnessMainColor,
        ));
      }
    } else if (userId == 'localUser') {
      final success = await _userWorkoutsDao.localReplaceUserWorkout(
          userWorkout, _selectedWorkout);
      if (success) {
        await fetchUpcomingWorkouts();
        await fetchWorkoutNames();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: AppColors.fitnessPrimaryTextColor),
              SizedBox(width: 8),
              Text(
                'Workout replaced',
                style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
              ),
            ],
          ),
          backgroundColor: AppColors.fitnessMainColor,
        ));
      }
    }
  }

  void removeCurrentFromCalendar() async {
  if (_selectedDay != null) {
    // Find the workout to be deleted
    UserWorkouts? toBeDeleted;
    for (var workout in _upcomingWorkouts) {
      if (workout.date.year == _selectedDay!.year &&
          workout.date.month == _selectedDay!.month &&
          workout.date.day == _selectedDay!.day) {
        toBeDeleted = workout;
        break;
      }
    }

    if (toBeDeleted != null) {
      if (userId != 'localUser') {
        await _userWorkoutsDao.fireBaseDeleteUserWorkout(toBeDeleted);
      } else {
        await _userWorkoutsDao.localDelete(toBeDeleted.userWorkoutId);
      }
      await fetchUpcomingWorkouts();
      await fetchWorkoutNames();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: AppColors.fitnessPrimaryTextColor),
            SizedBox(width: 8),
            Text(
              'Workout removed',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor),
            ),
          ],
        ),
        backgroundColor: AppColors.fitnessMainColor,
      ));
    }
  }
}

  // Check if a workout exists in the list
  bool workoutExist(String workoutId) {
    return _workouts.any((value) => value.workoutId == workoutId);
  }

  // Show the first modal to add or replace a workout
  void _showFirstModal(DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        bool canAddWorkout = !_upcomingWorkouts.any((workout) =>
            workout.date.year == selectedDay.year &&
            workout.date.month == selectedDay.month &&
            workout.date.day == selectedDay.day &&
            workoutExist(workout.workoutId));
        String workoutName = 'No workout scheduled';
        String workoutDescription = '';
        for (var workout in _upcomingWorkouts) {
          if (workout.date.year == selectedDay.year &&
              workout.date.month == selectedDay.month &&
              workout.date.day == selectedDay.day) {
            workoutName = _userWorkoutsMap[workout]?.split(' - ')[0] ??
                'No workout scheduled';
            workoutDescription =
                _userWorkoutsMap[workout]?.split(' - ')[1] ?? '';
            break;
          }
        }

        String formattedDate = DateFormat.yMMMMd().format(selectedDay);
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
                  formattedDate,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  workoutName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16, color: AppColors.fitnessPrimaryTextColor),
                ),
                const SizedBox(height: 10),
                Text(
                  workoutDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14, color: AppColors.fitnessSecondaryTextColor),
                ),
                const SizedBox(height: 20),
                if (!selectedDay.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)))) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (canAddWorkout)
                        InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _showSecondModal(true);
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
                                )))
                      else
                        ...[
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showSecondModal(false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            decoration: BoxDecoration(
                              color: AppColors.fitnessModuleColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Replace workout',
                              style: TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          removeCurrentFromCalendar();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          decoration: BoxDecoration(
                            color: AppColors.fitnessWarningColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: AppColors.fitnessPrimaryTextColor,
                          )
                        ),
                      ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Select workout modal
  void _showSecondModal(bool isAddWorkout) {
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
                  style: Theme.of(context)
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
                              if (isAddWorkout) {
                                addToCalendar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check,
                                          color: AppColors
                                              .fitnessPrimaryTextColor),
                                      SizedBox(width: 8),
                                      Text(
                                        'Workout Added',
                                        style: TextStyle(
                                            color: AppColors
                                                .fitnessPrimaryTextColor),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.fitnessMainColor,
                                ));
                              } else {
                                // Find the workout to be deleted
                                UserWorkouts toBeDeletedId;
                                for (var workout in _upcomingWorkouts) {
                                  if (workout.date.year == _selectedDay!.year &&
                                      workout.date.month ==
                                          _selectedDay!.month &&
                                      workout.date.day == _selectedDay!.day) {
                                    toBeDeletedId = workout;
                                    if (toBeDeletedId != null) {
                                      replaceExisting(toBeDeletedId);
                                    }
                                    break;
                                  }
                                }
                              }
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
      appBar: CustomAppBar.buildAppBar(context), // Custom app bar
      body: Center(
        child: Container(
          color: AppColors.fitnessBackgroundColor, // Background color
          child: TableCalendar(
            locale: 'en_US',
            firstDay: DateTime.utc(2024, 1, 1),
            // First day of the calendar
            lastDay: DateTime.utc(2030, 12, 31),
            // Last day of the calendar
            focusedDay: _focusedDay,
            // Currently focused day
            calendarFormat: _calendarFormat,
            // Calendar format
            startingDayOfWeek: StartingDayOfWeek.monday,
            // Start week on Monday
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            selectedDayPredicate: (day) {
              return isSameDay(
                  _selectedDay, day); // Check if the day is selected
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showFirstModal(selectedDay); // Show modal on day selection
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format; // Change calendar format
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay; // Change focused day
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                bool isSpecificDate = _upcomingWorkouts.any((value) =>
                    value.date.year == day.year &&
                    value.date.month == day.month &&
                    value.date.day == day.day &&
                    workoutExist(value
                        .workoutId)); // Checks if _workout_id exist in _upcoming
                return Stack(
                  children: [
                    Center(
                      //Day number, if there is a existing date, make the text red, if not primarycolor
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isSpecificDate)
                      Positioned(
                        top: 5,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.fitnessWarningColor,
                              shape: BoxShape.circle,
                            ),
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
                fontSize: 12,
                color: AppColors.fitnessPrimaryTextColor,
              ),
              todayTextStyle:
                  TextStyle(fontSize: 12, color: AppColors.fitnessMainColor),
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
                color: AppColors.fitnessMainColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.fitnessBackgroundColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.fitnessWarningColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                  fontSize: 24, color: AppColors.fitnessPrimaryTextColor),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.fitnessPrimaryTextColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.fitnessPrimaryTextColor,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                  fontSize: 9, color: AppColors.fitnessPrimaryTextColor),
              weekendStyle: TextStyle(fontSize: 9, color: AppColors.fitnessWarningColor),
            ),
          ),
        ),
      ),
    );
  }
}
