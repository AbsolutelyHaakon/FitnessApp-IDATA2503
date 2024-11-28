import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/Initialization/social_feed_data.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/create_post_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/post_builder.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

/// SocialFeed page displaying a feed of posts from other users.
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
    _fetchFeed();
  }

  /// Fetches the social feed data for the current user.
  Future<void> _fetchFeed() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() => _isReady = false);

    try {
      final fetchedPosts = await _postsDao.fireBaseFetchFeed(user.uid);

      if (fetchedPosts != null && fetchedPosts["posts"] != null) {
        setState(() {
          _posts = fetchedPosts["posts"];
          _isReady = true;
        });
      }
    } catch (e) {
      // Log error or show a message to the user
      setState(() => _isReady = true);
      debugPrint("Error fetching feed: $e");
    }
  }

  /// Refreshes the social feed.
  Future<void> _refreshFeed() async {
    await _fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: _buildAppBar(context),
      ),
      body: Stack(
        children: [
          _isReady
              ? _buildFeedSection()
              : const Center(
            child: CircularProgressIndicator(
              color: AppColors.fitnessMainColor,
            ),
          ),
          _buildFloatingActionButton(context),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }

  /// Builds the app bar with a title and subtitle.
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.fitnessModuleColor,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 20.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Feed',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Explore posts from other users',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the feed section with a refreshable list of posts.
Widget _buildFeedSection() {
  return RefreshIndicator(
    onRefresh: _refreshFeed,
    color: AppColors.fitnessMainColor,
    backgroundColor: AppColors.fitnessBackgroundColor,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 200),
                    child: PostBuilder(
                      post: _posts[index],
                      isProfile: false,
                      onDelete: _refreshFeed,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
  /// Builds the floating action button for creating new posts.
  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      bottom: 35,
      right: 10,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
        },
        backgroundColor: AppColors.fitnessMainColor,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: AppColors.fitnessBackgroundColor,
        ),
      ),
    );
  }
}
