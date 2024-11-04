import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Heading1 extends StatelessWidget {
  const Heading1({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFFFFFF),
        height: 1.1,
      ),
    );
  }
}

class Heading2 extends StatelessWidget {
  const Heading2({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF848484),
          height: 1.1),
    );
  }
}

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
          size: 15,
          color: color,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
