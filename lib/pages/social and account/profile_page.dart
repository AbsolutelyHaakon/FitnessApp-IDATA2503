import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_follows_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/personal_best_module.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/weight_bar_chart.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/settings.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'post_builder.dart';

/// This class represents the profile page of a user in the fitness app.
/// It displays the user's profile information, posts, and stats.
class ProfilePage extends StatefulWidget {
  final String userId; // The ID of the user whose profile is being displayed

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final UserDao _userDao = UserDao(); // DAO for user data
  final UserFollowsDao _userFollowsDao =
      UserFollowsDao(); // DAO for user follows data
  final PostsDao _postsDao = PostsDao(); // DAO for posts data
  late TabController _tabController; // Controller for tab navigation

  String name = " "; // User's name
  String imageURL = " "; // URL of the user's profile image
  String bannerURL = " "; // URL of the user's banner image

  int followers = 0; // Number of followers
  int following = 0; // Number of following
  bool _isFollowing =
      false; // Whether the current user is following this profile
  bool _isEditing = false; // Whether the profile is in edit mode
  bool _changeMade = false; // Whether changes were made in edit mode

  bool followerCountReady = false; // Whether follower count is ready
  bool _isReady = false; // Whether the profile data is ready

  XFile? _profileImage; // The new profile image file
  XFile? _bannerImage; // The new banner image file

  List<Posts> _posts = []; // List of user's posts

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Initialize the tab controller
    _loadUserData(); // Load user data
    if (FirebaseAuth.instance.currentUser?.uid != widget.userId) {
      _checkIfFollowing(); // Check if the current user is following this profile
    }
    _loadUserPosts(); // Load user's posts
    _loadFollowerData(); // Load follower data
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Loads the user's posts from the database
  Future<void> _loadUserPosts() async {
    setState(() {
      _isReady = false;
      _posts = [];
    });
    final postsData = await _postsDao.fireBaseFetchUserPosts(widget.userId);

    if (postsData["posts"] != null) {
      setState(() {
        _posts = List<Posts>.from(postsData["posts"]);
        _posts.sort((a, b) => b.date.compareTo(a.date));
        _setReady();
      });
    }
  }

  /// Logs out the current user
  void _onLogout() {
    setState(() {});
  }

  /// Loads the user's data from the database
  Future<void> _loadUserData() async {
    final user = await _userDao.fireBaseGetUserData(widget.userId);

    setState(() {
      name = user?["name"] ?? "Unknown"; // Set user's name
      imageURL = user?["imageURL"] ?? ""; // Set user's profile image URL
      bannerURL = user?["bannerURL"] ?? ""; // Set user's banner image URL
    });
  }

  /// Loads the follower data from the database
  Future<void> _loadFollowerData() async {
    final followerData =
        await _userFollowsDao.fireBaseGetFollowerCount(widget.userId);
    final followingData =
        await _userFollowsDao.fireBaseGetFollowingCount(widget.userId);

    setState(() {
      followers = followerData; // Set number of followers
      following = followingData; // Set number of following
      followerCountReady = true; // Follower count is ready
    });

    _setReady();
  }

  /// Checks if the current user is following this profile
  void _checkIfFollowing() {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      _userFollowsDao
          .fireBaseCheckIfFollows(
              FirebaseAuth.instance.currentUser!.uid, widget.userId)
          .then((value) {
        setState(() {
          _isFollowing = value; // Set following status
        });
      });
    }
  }

  /// Toggles the follow/unfollow status
  void _toggleFollow() {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      if (_isFollowing) {
        _userFollowsDao.fireBaseUnfollow(
            FirebaseAuth.instance.currentUser!.uid, widget.userId);
      } else {
        _userFollowsDao.fireBaseFollow(
            FirebaseAuth.instance.currentUser!.uid, widget.userId);
      }
    }
    setState(() {
      _isFollowing = !_isFollowing; // Toggle following status
      followers =
          _isFollowing ? followers + 1 : followers - 1; // Update follower count
    });
  }

  /// Sets the profile data as ready
  void _setReady() {
    if (name.isNotEmpty && followerCountReady) {
      setState(() {
        _isReady = true; // Profile data is ready
      });
    }
  }

  /// Picks an image from the gallery
  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerImage = pickedFile; // Set banner image
        } else {
          _profileImage = pickedFile; // Set profile image
        }
        _changeMade = true; // Changes were made
      });
    }
  }

  /// Toggles the edit mode
  void _toggleEdit() {
    if (_isEditing &&
        _changeMade &&
        FirebaseAuth.instance.currentUser?.uid != null) {
      _userDao.fireBaseUpdateUserData(
        FirebaseAuth.instance.currentUser!.uid,
        '',
        0.0,
        0,
        0,
        0,
        _profileImage,
        _bannerImage,
        null,
        null,
        null,
      );
    }

    setState(() {
      _isEditing = !_isEditing; // Toggle edit mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.userId != FirebaseAuth.instance.currentUser?.uid
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.green),
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to the previous screen
                },
              ),
              backgroundColor: AppColors.fitnessBackgroundColor,
              elevation: 0,
            )
          : null,
      body: _isReady
          ? NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: _isEditing
                                  ? () => _pickImage(ImageSource.gallery, true)
                                  : null,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: _bannerImage != null
                                        ? FileImage(File(_bannerImage!.path))
                                        : (bannerURL.isNotEmpty
                                                ? NetworkImage(bannerURL)
                                                : const AssetImage(
                                                    'assets/images/placeholder_banner.png'))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      setState(() {
                                        bannerURL =
                                            'assets/images/placeholder.png';
                                      });
                                    },
                                  ),
                                ),
                                child: _isEditing && _bannerImage == null
                                    ? Center(
                                        child: Icon(
                                          Icons.image,
                                          color: AppColors.fitnessMainColor
                                              .withOpacity(0.7),
                                          size: 50,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: -45,
                              child: GestureDetector(
                                onTap: _isEditing
                                    ? () =>
                                        _pickImage(ImageSource.gallery, false)
                                    : null,
                                child: CircleAvatar(
                                  backgroundImage: _profileImage != null
                                      ? FileImage(File(_profileImage!.path))
                                      : (imageURL.isNotEmpty
                                              ? NetworkImage(imageURL)
                                              : const AssetImage(
                                                  'assets/images/placeholder_icon.png'))
                                          as ImageProvider,
                                  onBackgroundImageError: (_, __) {
                                    setState(() {
                                      imageURL =
                                          'assets/images/placeholder.png';
                                    });
                                  },
                                  radius: 50.0,
                                  backgroundColor: Colors.white,
                                  child: _isEditing && _profileImage == null
                                      ? Icon(
                                          Icons.image,
                                          color: AppColors.fitnessMainColor
                                              .withOpacity(0.7),
                                          size: 30,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 110),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double horizontalPadding =
                                constraints.maxWidth > 400
                                    ? 20.0
                                    : constraints.maxWidth * 0.05;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Followers',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        followers.toString(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    children: [
                                      const Text(
                                        'Following',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        following.toString(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (FirebaseAuth.instance.currentUser?.uid !=
                                          widget.userId &&
                                      FirebaseAuth.instance.currentUser != null)
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: _toggleFollow,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isFollowing
                                                ? AppColors
                                                    .fitnessSecondaryModuleColor
                                                : AppColors.fitnessMainColor,
                                          ),
                                          child: Text(
                                            _isFollowing
                                                ? 'Following'
                                                : 'Follow',
                                            style: const TextStyle(
                                                color: AppColors
                                                    .fitnessPrimaryTextColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (FirebaseAuth.instance.currentUser?.uid ==
                                      widget.userId)
                                    SizedBox(
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: _toggleEdit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.fitnessMainColor,
                                        ),
                                        child: Text(
                                          _isEditing
                                              ? 'Save Changes'
                                              : 'Edit Profile',
                                          style: const TextStyle(
                                              color: AppColors
                                                  .fitnessPrimaryTextColor),
                                        ),
                                      ),
                                    ),
                                  if (FirebaseAuth.instance.currentUser?.uid ==
                                      widget.userId)
                                    IconButton(
                                      icon: const Icon(Icons.settings,
                                          color: AppColors.fitnessMainColor),
                                      color: Colors.grey,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsPage(
                                                      onLogout: _onLogout)),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        if (FirebaseAuth.instance.currentUser?.uid ==
                            widget.userId)
                          TabBar(
                            dividerColor: AppColors.fitnessBackgroundColor,
                            labelColor: AppColors.fitnessMainColor,
                            indicatorColor: AppColors.fitnessMainColor,
                            controller: _tabController,
                            tabs: const [
                              Tab(text: "My Posts"),
                              Tab(text: 'My Stats'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ];
              },
              body: FirebaseAuth.instance.currentUser?.uid == widget.userId
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: ListView.builder(
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              final post = _posts[index];
                              return PostBuilder(
                                post: post,
                                isProfile: true,
                                onDelete: _loadUserPosts,
                              );
                            },
                          ),
                        ),
                        const SingleChildScrollView(
                          child: Column(children: [
                            SizedBox(height: 20),
                            PersonalBestModule(),
                            SizedBox(height: 20),
                            WeightBarChart(),
                            SizedBox(height: 20),
                          ]),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView.builder(
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return PostBuilder(
                            post: post,
                            isProfile: true,
                            onDelete: _loadUserPosts,
                          );
                        },
                      ),
                    ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppColors.fitnessMainColor,
              ),
            ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}
