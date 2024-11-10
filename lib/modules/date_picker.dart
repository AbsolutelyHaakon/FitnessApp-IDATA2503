import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

// Last edited by Big D

class DatePickerModule extends StatefulWidget {
  const DatePickerModule({Key? key}) : super(key: key);

  @override
  _DatePickerModuleState createState() => _DatePickerModuleState();
}

class _DatePickerModuleState extends State<DatePickerModule> {
  DateTime selectedDate = DateTime.now();
  final RxString displayedDate = ''.obs;

  @override
  void initState() {
    super.initState();
    _updateDisplayedDate();
  }

  //Update the value accordingly
  void _updateDisplayedDate() {
    displayedDate.value =
        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
  }

  void _setPresetDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      _updateDisplayedDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.fitnessModuleColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.fitnessModuleColor,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    primaryColor: AppColors.fitnessPrimaryTextColor,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime value) {
                      _setPresetDate(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  //TODO: Logic here to retrieve the selected date
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text("Title"),
                          content: DefaultTextStyle(
                            style: TextStyle(
                                color: AppColors.fitnessSecondaryTextColor),
                            child: Text(
                                "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OKOKOKOKOK"),
                            )
                          ]);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fitnessPrimaryTextColor,
                ),
                child: const Text(
                  //OK button
                  'OK',
                  style: TextStyle(
                    color: AppColors.fitnessBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
