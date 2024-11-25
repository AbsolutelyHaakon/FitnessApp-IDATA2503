import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles.dart';

// TODO: Implement likes and comments, get rid of shareCount

class PostBuilder extends StatefulWidget {
  final Posts post;
  final bool isProfile;

  const PostBuilder({required this.post, required this.isProfile});

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
  late List<Map<String, String>>? workoutStats;
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

    setState(() {
      profileImageUrl = userData?['imageURL'] ?? '';
      name = userData?['name'] ?? '';
      date = widget.post.date;
      message = widget.post.content;
      workoutId = widget.post.workoutId;
      workoutStats = [];
      imageUrl = widget.post.imageURL;
      location = widget.post.location;
      commentCount = 0;
      shareCount = 0;
      heartCount = 0;

      _isReady = true;
    });
  }

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
                CircleAvatar(
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
                ),
              SizedBox(width: 10.0),
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
                        child: Icon(Icons.message,
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
              if (imageUrl != null && imageUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
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
            Row(
              children: [
                const Icon(Icons.comment,
                    color: AppColors.fitnessMainColor, size: 16),
                const SizedBox(width: 2.0),
                Text('$commentCount', style: const TextStyle(fontSize: 12.0)),
                const SizedBox(width: 10.0),
                const Icon(Icons.share,
                    color: AppColors.fitnessMainColor, size: 16),
                const SizedBox(width: 2.0),
                Text('$shareCount', style: const TextStyle(fontSize: 12.0)),
                const SizedBox(width: 10.0),
                const Icon(Icons.favorite,
                    color: AppColors.fitnessMainColor, size: 16),
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
