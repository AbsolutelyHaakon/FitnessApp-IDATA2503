import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/Initialization/social_feed_data.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/create_post_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/post_builder.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// SocialFeed page which contains a feed and a profile tab
/// Shows posts by other users
///
/// Last edited: 26.11.2024
/// Last edited by: Håkon Karlsen

class SocialFeed extends StatefulWidget {
  const SocialFeed({super.key});

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
  final PostsDao _postsDao = PostsDao();
  final SocialFeedData _socialFeedData = SocialFeedData();

  List<Posts> _posts = [];
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    getFeed();
  }

  Future<void> _refreshFeed() async {
    await getFeed();
  }

  Future<void> getFeed() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    setState(() {
      _isReady = false;
    });

    final fetchedPosts = await _postsDao
        .fireBaseFetchFeed(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      _posts = fetchedPosts["posts"];
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(40.0), // Adjust the height as needed
  child: Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: AppColors.fitnessModuleColor, // Set the border color
          width: 1.0, // Adjust the border width as needed
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Social feed',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Text(
              'Explore posts from other users',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  ),
),
      body: _isReady
          ? _buildFeedSection()
          : const Center(
              child: CircularProgressIndicator(
                color: AppColors.fitnessMainColor,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );
        },
        backgroundColor: AppColors.fitnessMainColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add,
            color: AppColors.fitnessPrimaryTextColor),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }

  Widget _buildFeedSection() {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppColors.fitnessMainColor,
      backgroundColor: AppColors.fitnessBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: PostBuilder(
                post: post,
                isProfile: false,
              ),
            );
          },
        ),
      ),
    );
  }
}