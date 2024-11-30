import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// This class represents a box that displays a personal best.
/// It shows the name of the personal best and its value, along with an optional medal icon.
class PersonalBestBox extends StatelessWidget {
  PersonalBestBox({
    super.key,
    this.index,
    required this.item,
  });

  final int? index; // Index of the personal best in the list
  final MapEntry<String, dynamic> item; // The personal best data

  // List of SVG icons for medals
  final svgIcons = [
    "assets/icons/medal1.svg",
    "assets/icons/medal2.svg",
    "assets/icons/medal3.svg",
    "",
    "",
  ];

  // List of colors for medals
  final medalColors = [
    Colors.yellow.shade500,
    Colors.grey.shade500,
    Colors.brown.shade500,
    Colors.transparent,
    Colors.transparent,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5), // Shadow color
                spreadRadius: 1, // Spread radius of the shadow
                offset: const Offset(0, 3), // Offset of the shadow
              ),
            ],
            borderRadius: BorderRadius.circular(10), // Rounded corners
            color: AppColors.fitnessSecondaryModuleColor.withOpacity(0.6), // Background color
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Padding inside the container
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between the elements
            children: [
              Row(
                children: [
                  if (index != null) // Check if index is not null
                    if (index! < 3) // Check if index is less than 3
                      SvgPicture.asset(
                        svgIcons[index!], // Medal icon
                        height: 24, // Height of the icon
                        width: 24, // Width of the icon
                        color: medalColors[index!], // Color of the icon
                      ),
                  const SizedBox(width: 10), // Space between icon and text
                  Text(
                    item.key, // Name of the personal best
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis, // Text overflow handling
                    maxLines: 1, // Maximum number of lines
                  ),
                ],
              ),
              Text(
                '${item.value} kg', // Value of the personal best
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10), // Space between items
      ],
    );
  }
}