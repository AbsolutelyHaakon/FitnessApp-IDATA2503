import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalBestBox extends StatelessWidget {
  PersonalBestBox({
    super.key,
    this.index,
    required this.item,
  });

  final int? index;
  final MapEntry<String, dynamic> item;

  final svgIcons = [
    "assets/icons/medal1.svg",
    "assets/icons/medal2.svg",
    "assets/icons/medal3.svg",
    "",
    "",
  ];

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
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
            color: AppColors.fitnessSecondaryModuleColor.withOpacity(0.6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (index != null)
                    if (index! < 3)
                      SvgPicture.asset(
                        svgIcons[index!],
                        height: 24,
                        width: 24,
                        color: medalColors[index!],
                      ),
                  const SizedBox(width: 10),
                  Text(
                    item.key,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              Text(
                '${item.value} kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
