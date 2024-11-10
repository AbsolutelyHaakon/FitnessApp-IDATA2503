import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class DwProgressBar extends StatefulWidget {
  double value;

  DwProgressBar({super.key, required this.value});

  @override
  State<DwProgressBar> createState() => _DwProgressBarState();
}

class _DwProgressBarState extends State<DwProgressBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Progress',
            style: TextStyle(
              color: AppColors.fitnessSecondaryTextColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: LinearProgressIndicator(
                    value: widget.value,
                    backgroundColor: AppColors.fitnessSecondaryModuleColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.fitnessMainColor),
                    minHeight: 30,
                  ),
                ),
              ),
              Positioned.fill(
                left: 10,
                top: 5,
                child: Text(
                  textAlign: TextAlign.left,
                  '${(widget.value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}