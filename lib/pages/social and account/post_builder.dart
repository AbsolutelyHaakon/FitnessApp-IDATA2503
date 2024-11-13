import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles.dart';

class PostBuilder extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final DateTime date;
  final IconData icon;
  final String? message;
  final List<Map<String, String>>? workoutStats;
  final String? workoutId;
  final String? imageUrl;
  final String? location;
  final int commentCount;
  final int shareCount;
  final int heartCount;

  const PostBuilder({
    required this.profileImageUrl,
    required this.name,
    required this.date,
    required this.icon,
    this.message,
    this.workoutStats,
    this.workoutId,
    this.imageUrl,
    this.location,
    this.commentCount = 0,
    this.shareCount = 0,
    this.heartCount = 0,
  });

  Widget statBuilder(Map<String, String> stat) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(stat['name'] ?? '',
                style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400)),
            Text(stat['value'] ?? '', style: const TextStyle(fontSize: 16.0)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    DateFormat('d\'th\' of MMMM').format(date),
                    style: const TextStyle(
                        color: AppColors.fitnessSecondaryTextColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Card(
          color: AppColors.fitnessModuleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((message != null && message!.isNotEmpty) ||
                  (workoutStats != null && workoutStats!.isNotEmpty))
                const SizedBox(height: 10.0),
              if (message != null && message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Icon(icon, color: AppColors.fitnessMainColor),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                          child: Text(message!,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400))),
                    ],
                  ),
                ),
              if (message != null && message!.isNotEmpty)
                const SizedBox(height: 5.0),
              if (workoutStats != null && workoutStats!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: workoutStats!
                              .map((stat) => statBuilder(stat))
                              .toList(),
                        ),
                      ),
                      if (workoutId != null)
                        TextButton(
                          onPressed: () {
                            // Navigate to workout details
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          child: const Text(
                            'View Workout >',
                            style: TextStyle(color: AppColors.fitnessMainColor),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10.0),
              if (imageUrl != null)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  // TODO: Find out what other services use as their standard image dimensions
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                )
            ],
          ),
        ),
        const SizedBox(height: 2.0),
        Row(
          children: [
            if (location != null)
              Row(
                children: [
                  Transform.scale(
                    scale: 0.7,
                    child: const Icon(Icons.location_on,
                        color: AppColors.fitnessMainColor),
                  ),
                  const SizedBox(width: 5.0),
                  Text(location!, style: const TextStyle(fontSize: 12.0)),
                ],
              ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.comment, color: AppColors.fitnessMainColor, size: 16),
                const SizedBox(width: 2.0),
                Text('$commentCount', style: const TextStyle(fontSize: 12.0)),
                const SizedBox(width: 10.0),
                const Icon(Icons.share, color: AppColors.fitnessMainColor, size: 16),
                const SizedBox(width: 2.0),
                Text('$shareCount', style: const TextStyle(fontSize: 12.0)),
                const SizedBox(width: 10.0),
                const Icon(Icons.favorite, color: AppColors.fitnessMainColor, size: 16),
                const SizedBox(width: 2.0),
                Text('$heartCount', style: const TextStyle(fontSize: 12.0)),
                const SizedBox(width: 10.0),
              ],
            ),
          ],
        ),
      ],
    );
  }
}