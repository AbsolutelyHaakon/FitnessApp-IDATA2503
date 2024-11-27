import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles.dart';

class PostBuilder extends StatefulWidget {
  final Posts post;
  final bool isProfile;
  final VoidCallback onDelete;

  const PostBuilder(
      {required this.post, required this.isProfile, required this.onDelete});

  @override
  State<PostBuilder> createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  final UserDao _userDao = UserDao();

  late String profileImageUrl;
  late String name;
  late DateTime date;
  late String? message;
  late String? workoutId;
  late List<Map<String, String>>? visibleStats;
  late String? imageUrl;
  late String? location;
  late int commentCount;
  late int shareCount;
  late int heartCount;

  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _getUserInformation();
  }

  Future<void> _getUserInformation() async {
    final userData = await _userDao.fireBaseGetUserData(widget.post.userId);

    if (mounted) {
      setState(() {
        profileImageUrl = userData?['imageURL'] ?? '';
        name = userData?['name'] ?? '';
        date = widget.post.date;
        message = widget.post.content;
        workoutId = widget.post.workoutId;
        visibleStats = widget.post.visibleStats?.entries
            .map((entry) => {'name': entry.key, 'value': entry.value})
            .toList();
        imageUrl = widget.post.imageURL;
        location = widget.post.location;
        commentCount = 0;
        shareCount = 0;
        heartCount = 0;

        _isReady = true;
      });
    }
  }

  Widget statBuilder(Map<String, String> stat) {
    return Row(
      children: [
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(stat['name'] ?? '',
                style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.fitnessSecondaryTextColor)),
            Text(stat['value'] ?? '',
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fitnessPrimaryTextColor)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.fitnessMainColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              if (!widget.isProfile)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(userId: widget.post.userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('assets/images/placeholder_icon.png')
                            as ImageProvider,
                  ),
                ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isProfile)
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
        const SizedBox(height: 10.0),
        Card(
          color: AppColors.fitnessModuleColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((message != null && message!.isNotEmpty) ||
                  (visibleStats != null && visibleStats!.isNotEmpty))
                const SizedBox(height: 10.0),
              if (message != null && message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: const Icon(Icons.message,
                            color: AppColors.fitnessMainColor),
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
              if (visibleStats != null && visibleStats!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Divider(
                    color: AppColors.fitnessMainColor,
                    thickness: 1.0,
                  ),
                ),
              if (visibleStats != null && visibleStats!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: visibleStats!
                              .map((stat) => statBuilder(stat))
                              .toList(),
                        ),
                      ),
                      if (workoutId != null)
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to workout details
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fitnessModuleColor,
                            foregroundColor: AppColors.fitnessBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                          ),
                          child: const Text(
                            'View >',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.fitnessMainColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 10.0),
              if (imageUrl != null && imageUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2.0),
        Row(
          children: [
            if (location != null && location!.isNotEmpty)
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
            if (widget.post.userId == FirebaseAuth.instance.currentUser?.uid)
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.fitnessModuleColor,
                        title: const Text(
                          'Confirm Delete',
                          style: TextStyle(
                              color: AppColors.fitnessPrimaryTextColor),
                        ),
                        content: const Text(
                          'Are you sure you want to delete this post?',
                          style: TextStyle(
                              color: AppColors.fitnessPrimaryTextColor,
                              fontWeight: FontWeight.w400),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.fitnessPrimaryTextColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: AppColors.fitnessWarningColor)),
                            onPressed: () async {
                              await PostsDao()
                                  .fireBaseDeletePost(widget.post.postId);
                              widget.onDelete();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.more_horiz,
                    color: AppColors.fitnessMainColor),
              ),
          ],
        ),
      ],
    );
  }
}
