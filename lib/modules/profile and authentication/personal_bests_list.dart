import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/personal_best_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// This class represents a list of personal bests.
/// It displays the personal bests in a sorted order and allows the user to filter and sort them.
class PersonalBestsList extends StatefulWidget {
  const PersonalBestsList({super.key, required this.personalBests});

  final List<MapEntry<String, dynamic>> personalBests;

  @override
  State<PersonalBestsList> createState() => _PersonalBestsListState();
}

class _PersonalBestsListState extends State<PersonalBestsList> {
  bool _isDescending = true; // Sort order flag
  String _selectedMetric = 'Weight'; // Default filter option

  final _filterOptions = ['Weight']; // Available filter options

  @override
  Widget build(BuildContext context) {
    // Create a copy of the personal bests list to sort
    List<MapEntry<String, dynamic>> sortedPersonalBests =
        List.from(widget.personalBests);

    // Sort the list based on the selected order
    if (_isDescending) {
      sortedPersonalBests.sort((a, b) => b.value.compareTo(a.value));
    } else {
      sortedPersonalBests.sort((a, b) => a.value.compareTo(b.value));
    }

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.fitnessMainColor),
            onPressed: () => Navigator.of(context).pop(), // Go back
          ),
          title: const Text(
            'Personal Bests',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColors.fitnessBackgroundColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  DropdownButton<String>(
                    dropdownColor: AppColors.fitnessSecondaryModuleColor,
                    value: _selectedMetric,
                    items: _filterOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: Theme.of(context).textTheme.bodyMedium),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMetric = newValue!; // Update selected metric
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDescending = !_isDescending; // Toggle sort order
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: sortedPersonalBests.asMap().entries.map((entry) {
            final item = entry.value;
            return PersonalBestBox(
              item: item, // Display each personal best
            );
          }).toList(),
        ));
  }
}