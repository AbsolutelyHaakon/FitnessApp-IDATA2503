import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/personal_best_box.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PersonalBestsList extends StatefulWidget {
  const PersonalBestsList({super.key, required this.personalBests});

  final List<MapEntry<String, dynamic>> personalBests;

  @override
  State<PersonalBestsList> createState() => _PersonalBestsListState();
}

class _PersonalBestsListState extends State<PersonalBestsList> {
  bool _isDescending = true;
  String _selectedMetric = 'Weight';

  final _filterOptions = ['Weight'];

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, dynamic>> sortedPersonalBests =
        List.from(widget.personalBests);

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
            onPressed: () => Navigator.of(context).pop(),
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
                        _selectedMetric = newValue!;
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
                        _isDescending = !_isDescending;
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
              item: item,
            );
          }).toList(),
        ));
  }
}
