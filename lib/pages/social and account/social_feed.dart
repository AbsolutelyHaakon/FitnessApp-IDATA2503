import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/Initialization/social_feed_data.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/create_post_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/post_builder.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

/// SocialFeed page displaying a feed of posts from other users.

class SocialFeed extends StatefulWidget {
  const SocialFeed({super.key});

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
  final PostsDao _postsDao = PostsDao(); // DAO for handling posts
  final SocialFeedData _socialFeedData = SocialFeedData(); // Data for social feed

  List<Posts> _posts = []; // List to store posts
  bool _isReady = false; // Flag to check if data is ready
  bool _noPostsAvailable = false; // Flag to check if no posts are available

  @override
  void initState() {
  super.initState();
  if (FirebaseAuth.instance.currentUser != null) {
    _fetchFeed(); // Fetch the feed when the widget is initialized
  } else {
    setState(() {
      _isReady = true;
      _noPostsAvailable = true;
    });
  }
}


  /// Fetches the social feed data for the current user.
  Future<void> _fetchFeed() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user == null) return; // If no user is logged in, return

    if (!mounted) return;
    setState(() => _isReady = false); // Set loading state

    try {
      final fetchedPosts = await _postsDao.fireBaseFetchFeed(user.uid); // Fetch posts from Firebase

      if (fetchedPosts != null && fetchedPosts["posts"] != null) {
        if (!mounted) return;
        setState(() {
          _posts = fetchedPosts["posts"]; // Update posts list
          _isReady = true; // Data is ready
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isReady = true); // Set ready state even if there's an error
      debugPrint("Error fetching feed: $e"); // Print error message
    }
  }

  /// Refreshes the social feed.
  Future<void> _refreshFeed() async {
    await _fetchFeed(); // Fetch the feed again
  }

  @override
Widget build(BuildContext context) {
  final appBarHeight = MediaQuery.of(context).size.height * 0.1; // Calculate app bar height

  return Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight), // Set app bar height
      child: _buildAppBar(context), // Build the app bar
    ),
    body: Stack(
      children: [
        _isReady
            ? _noPostsAvailable
                ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: Text(
                        'No posts available.... Follow some peers to see their content!',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                )
                : _buildFeedSection() // Show feed if data is ready
            : const Center(
                child: CircularProgressIndicator(
                  color: AppColors.fitnessMainColor, // Show loading indicator
                ),
              ),
        _buildFloatingActionButton(context), // Show floating action button
      ],
    ),
    backgroundColor: AppColors.fitnessBackgroundColor, // Set background color
  );
}

  /// Builds the app bar with a title and subtitle.
  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.fitnessModuleColor, // Set border color
            width: 1.0, // Set border width
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 20.0), // Set padding
      child: Align(
        alignment: Alignment.centerLeft, // Align to the left
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
          children: [
            Text(
              'Social Feed', // Title
              style: Theme.of(context).textTheme.bodyLarge, // Set text style
            ),
            Text(
              'Explore posts from other users', // Subtitle
              style: Theme.of(context).textTheme.bodyMedium, // Set text style
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the feed section with a refreshable list of posts.
  Widget _buildFeedSection() {
    return RefreshIndicator(
      onRefresh: _refreshFeed, // Refresh feed on pull down
      color: AppColors.fitnessMainColor, // Set refresh indicator color
      backgroundColor: AppColors.fitnessBackgroundColor, // Set background color
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0), // Set padding
              child: ListView.builder(
                shrinkWrap: true, // Shrink wrap the list
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: _posts.length, // Number of posts
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 40.0), // Set padding
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 200), // Set minimum height
                      child: PostBuilder(
                        post: _posts[index], // Build post
                        isProfile: false, // Not a profile post
                        onDelete: _refreshFeed, // Refresh feed on delete
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
      bottom: 35, // Position from bottom
      right: 10, // Position from right
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()), // Navigate to create post page
          );
        },
        backgroundColor: AppColors.fitnessMainColor, // Set button color
        shape: const CircleBorder(), // Set button shape
        child: const Icon(
          Icons.add, // Add icon
          color: AppColors.fitnessBackgroundColor, // Set icon color
        ),
      ),
    );
  }
}