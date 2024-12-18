import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:get/get.dart';

// This page allows the user to edit a specific field
class EditFieldPage extends StatelessWidget {
  final String title; // Title of the page
  final String initialValue; // Initial value of the field
  final ValueChanged<String>
      onSave; // Callback function when the user saves the field
  final TextInputType keyboardType; // Type of keyboard to use

  // Constructor for the EditFieldPage
  EditFieldPage({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.keyboardType = TextInputType.text,
  });

  // Controller for the text field
  final TextEditingController _controller = TextEditingController();

  bool _isNumeric(String str) {
    if (str.isEmpty) {
      return false;
    }
    final number = num.tryParse(str);
    return number != null;
  }

  @override
  Widget build(BuildContext context) {
    // Set the initial value of the text field
    _controller.text = initialValue;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor), // Back button
          onPressed: () =>
              Navigator.of(context).pop(), // Go back to the previous page
        ),
        title: Text(
          title, // Title of the app bar
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            AppColors.fitnessBackgroundColor, // Background color of the app bar
      ),
      body: Container(
        color: AppColors.fitnessBackgroundColor, // Background color of the page
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          child: Column(
            children: [
              TextFormField(
                style: const TextStyle(fontSize: 20), // Text style
                cursorColor: Colors.white, // Cursor color
                controller: _controller, // Controller for the text field
                keyboardType: keyboardType, // Keyboard type
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white), // Hint text style
                  labelStyle: TextStyle(
                      fontSize: 20, color: Colors.white), // Label text style
                  suffixStyle:
                      TextStyle(color: Colors.white), // Suffix text style
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors
                            .fitnessMainColor), // Border color when enabled
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: AppColors
                            .fitnessMainColor), // Border color when focused
                  ),
                ),
              ),
              const SizedBox(
                  height: 20), // Space between the text field and the button
              SizedBox(
                width: double.infinity, // Button width
                height: 50, // Button height
                child: TextButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        AppColors.fitnessMainColor), // Button background color
                    foregroundColor: WidgetStatePropertyAll(AppColors
                        .fitnessModuleColor), // Button foreground color
                  ),
                  onPressed: () {
                    if (_controller.text.isNotEmpty &&
                        _controller.text != initialValue &&
                        (_isNumeric(_controller.text)
                            ? int.parse(_controller.text) > 0
                            : true)) {
                      onSave(_controller.text); // Save the text field value
                      Navigator.of(context)
                          .pop(); // Go back to the previous page
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.fitnessModuleColor,
                          title:
                              const Text('Invalid Input'), // Alert dialog title
                          content: const Text(
                              'Insert a valid value'), // Alert dialog content
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the alert dialog
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                    color: AppColors.fitnessMainColor),
                              ), // Button text
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save', // Button text
                    style: TextStyle(
                        fontSize: 16, color: Colors.white), // Button text style
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
