import 'package:flutter/material.dart';

// Heading1 widget for large headings
class Heading1 extends StatelessWidget {
  const Heading1({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20, // Font size for Heading1
        fontWeight: FontWeight.w900, // Bold font weight
        color: Color(0xFFFFFFFF), // White color
        height: 1.1, // Line height
      ),
    );
  }
}

// Heading2 widget for smaller headings
class Heading2 extends StatelessWidget {
  const Heading2({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14, // Font size for Heading2
          fontWeight: FontWeight.w800, // Semi-bold font weight
          color: Color(0xFF848484), // Grey color
          height: 1.1), // Line height
    );
  }
}

// IconText widget for text with an icon
class IconText extends StatelessWidget {
  const IconText(
      {super.key,
      required this.text,
      required this.color,
      required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15, // Icon size
          color: color, // Icon color
        ),
        const SizedBox(
          width: 5, // Space between icon and text
        ),
        Text(
          text,
          style: TextStyle(
            color: color, // Text color
            fontWeight: FontWeight.w700, // Bold font weight
            fontSize: 10, // Font size
          ),
        ),
      ],
    );
  }
}