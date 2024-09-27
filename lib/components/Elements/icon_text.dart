import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconText extends StatelessWidget {
  const IconText(
      {super.key,
      required this.text,
      required this.color,
      required this.asset});

  final String text;
  final Color color;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/$asset',
          width: 15,
          height: 15,
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
