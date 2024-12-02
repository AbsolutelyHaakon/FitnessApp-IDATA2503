// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_workouts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/workout_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/database/tables/user_workouts.dart';
import 'package:fitnessapp_idata2503/database/tables/workout.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/profile_page.dart';
import 'package:fitnessapp_idata2503/pages/workout%20and%20exercises/detailed_workout_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles.dart';

class PostBuilder extends StatefulWidget {
  final Posts post; // Post data
  final bool isProfile; // Check if it's a profile post
  final VoidCallback onDelete; // Callback for delete action

  const PostBuilder(
      {super.key,
      required this.post,
      required this.isProfile,
      required this.onDelete});

  @override
  State<PostBuilder> createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  final UserDao _userDao = UserDao(); // User data access object

  late String profileImageUrl; // URL for profile image
  late String name; // User's name
  late DateTime date; // Post date
  late String? message; // Post message
  late String? userWorkoutId; // Workout ID
  late List<Map<String, String>>? visibleStats; // Stats to display
  late String? imageUrl; // URL for post image
  late String? location; // Post location
  late int commentCount; // Number of comments
  late int shareCount; // Number of shares
  late int heartCount; // Number of likes

  bool _isReady = false; // Check if data is ready

  @override
  void initState() {
    super.initState();
    _getUserInformation(); // Fetch user info when widget is initialized
  }

  Future<void> _getUserInformation() async {
    final userData = await _userDao
        .fireBaseGetUserData(widget.post.userId); // Fetch user data

    if (mounted) {
      setState(() {
        profileImageUrl = userData?['imageURL'] ?? ''; // Set profile image URL
        name = userData?['name'] ?? ''; // Set user name
        date = widget.post.date; // Set post date
        message = widget.post.content; // Set post message
        userWorkoutId = widget.post.userWorkoutsId; // Set workout ID
        visibleStats = widget.post.visibleStats?.entries
            .map((entry) => {'name': entry.key, 'value': entry.value})
            .toList(); // Set visible stats
        imageUrl = widget.post.imageURL; // Set post image URL
        location = widget.post.location; // Set post location
        commentCount = 0; // Initialize comment count
        shareCount = 0; // Initialize share count
        heartCount = 0; // Initialize like count

        _isReady = true; // Data is ready
      });
    }

    print('PostBuilder: User information fetched');
    print('userWorkoutId: $userWorkoutId');
  }

  Widget statBuilder(Map<String, String> stat) {
  return Row(
    children: [
      const SizedBox(width: 5), // Add spacing
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(stat['name'] ?? '',
              style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.fitnessSecondaryTextColor)), // Stat name
          if (stat['name'] != 'Hike' && !(stat['name']?.contains('walk') ?? false) && !(stat['name']?.contains('run') ?? false))
            Text(stat['value'] ?? '',
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fitnessPrimaryTextColor)), // Stat value
        ],
      ),
    ],
  );
}

  String formatDateWithSuffix(DateTime date) {
    String day = DateFormat('d').format(date);
    String suffix;

    if (day.endsWith('1') && !day.endsWith('11')) {
      suffix = 'st of';
    } else if (day.endsWith('2') && !day.endsWith('12')) {
      suffix = 'nd of';
    } else if (day.endsWith('3') && !day.endsWith('13')) {
      suffix = 'rd of';
    } else {
      suffix = 'th of';
    }

    return DateFormat('d').format(date) +
        suffix +
        DateFormat(' MMMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.fitnessMainColor, // Loading indicator color
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0), // Add padding
          child: Row(
            children: [
              if (!widget.isProfile)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                            userId:
                                widget.post.userId), // Navigate to profile page
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl) // Display profile image
                        : const AssetImage('assets/images/placeholder_icon.png')
                            as ImageProvider, // Placeholder image
                  ),
                ),
              const SizedBox(width: 10.0), // Add spacing
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isProfile)
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)), // Display user name
                  Text(
                    formatDateWithSuffix(date), // Display post date with suffix
                    style: const TextStyle(
                      color: AppColors.fitnessSecondaryTextColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0), // Add spacing
        Card(
          color: AppColors.fitnessModuleColor, // Card background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((message != null && message!.isNotEmpty) ||
                  (visibleStats != null && visibleStats!.isNotEmpty))
                const SizedBox(height: 10.0), // Add spacing
              if (message != null && message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0), // Add padding
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: const Icon(Icons.message,
                            color: AppColors.fitnessMainColor), // Message icon
                      ),
                      const SizedBox(width: 10.0), // Add spacing
                      Expanded(
                          child: Text(message!,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight:
                                      FontWeight.w400))), // Display message
                    ],
                  ),
                ),
              if (message != null && message!.isNotEmpty)
                const SizedBox(height: 5.0), // Add spacing
              if (visibleStats != null && visibleStats!.isNotEmpty)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0), // Add padding
                  child: Divider(
                    color: AppColors.fitnessMainColor, // Divider color
                    thickness: 1.0, // Divider thickness
                  ),
                ),
              if (visibleStats != null && visibleStats!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0), // Add padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: visibleStats!
                              .map((stat) => statBuilder(stat)) // Build stats
                              .toList(),
                        ),
                      ),
                      if (userWorkoutId != null)
                        ElevatedButton(
                          onPressed: () async {
                            final userWorkout = await UserWorkoutsDao()
                                .fireBaseFetchUserWorkoutById(userWorkoutId!);
                            final workout = await WorkoutDao()
                                .fireBaseFetchWorkout(userWorkout.workoutId);
                            if (workout == null) {
                              return;
                            }
                            final MapEntry<UserWorkouts, Workouts>
                                workoutMapEntry =
                                MapEntry(userWorkout, workout);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailedWorkoutLog(
                                        workoutMapEntry: workoutMapEntry,
                                      )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors
                                .fitnessModuleColor, // Button background color
                            foregroundColor: AppColors
                                .fitnessBackgroundColor, // Button text color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10), // Add padding
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors
                                  .fitnessMainColor, // Button text color
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10.0), // Add spacing
              if (imageUrl != null && imageUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity, // Full width
                  height: 300, // Fixed height
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15), // Rounded corners
                        bottomRight: Radius.circular(15), // Rounded corners
                      ),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl!), // Display post image
                        fit: BoxFit.cover, // Cover the container
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2.0), // Add spacing
        Row(
          children: [
            if (location != null && location!.isNotEmpty)
              Row(
                children: [
                  Transform.scale(
                    scale: 0.7,
                    child: const Icon(Icons.location_on,
                        color: AppColors.fitnessMainColor), // Location icon
                  ),
                  const SizedBox(width: 5.0), // Add spacing
                  Text(location!,
                      style:
                          const TextStyle(fontSize: 12.0)), // Display location
                ],
              ),
            const Spacer(), // Add spacing
            if (widget.post.userId == FirebaseAuth.instance.currentUser?.uid)
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors
                            .fitnessModuleColor, // Dialog background color
                        title: const Text(
                          'Confirm Delete',
                          style: TextStyle(
                              color: AppColors
                                  .fitnessPrimaryTextColor), // Dialog title color
                        ),
                        content: const Text(
                          'Are you sure you want to delete this post?',
                          style: TextStyle(
                              color: AppColors.fitnessPrimaryTextColor,
                              fontWeight:
                                  FontWeight.w400), // Dialog content color
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: AppColors
                                        .fitnessPrimaryTextColor)), // Cancel button
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                            },
                          ),
                          TextButton(
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: AppColors
                                        .fitnessWarningColor)), // Delete button
                            onPressed: () async {
                              await PostsDao().fireBaseDeletePost(
                                  widget.post.postId); // Delete post
                              widget.onDelete(); // Call delete callback
                              Navigator.of(context).pop(); // Close dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.more_horiz,
                    color: AppColors.fitnessMainColor), // More options icon
              ),
          ],
        ),
      ],
    );
  }
}
