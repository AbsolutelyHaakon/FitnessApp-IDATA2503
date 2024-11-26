import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/Initialization/social_feed_data.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/create_post_page.dart';
import 'package:fitnessapp_idata2503/pages/social%20and%20account/post_builder.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// SocialFeed page which contains a feed and a profile tab
/// Shows posts by other users
///
/// Last edited: 13.11.2024
/// Last edited by: Håkon Karlsen
///
/// TODO: Implement refresh logic
/// TODO: Implement backend logic

class SocialFeed extends StatefulWidget {
  const SocialFeed({super.key});

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed>
    with SingleTickerProviderStateMixin {
  final PostsDao _postsDao = PostsDao();
  final SocialFeedData _socialFeedData = SocialFeedData();

  List<Posts> _posts = [];
  bool _isReady = false;
  bool _isSearching = false;
  List<LocalUser> _allUsers = [];
  List<LocalUser> _filteredUsers = [];

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_isSearching) {
        _stopSearch();
      }
    });
    getFeed();
    getUsers();
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

  Future<void> getUsers() async {
    try {
      final fetchedUsers = await _socialFeedData.fireBaseFetchUsersForSearch();
      setState(() {
        _allUsers = fetchedUsers["users"] ?? [];
        _filteredUsers = _allUsers;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _filteredUsers = _allUsers;
    });
    _searchFocusNode.requestFocus();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
  }

  // TODO: Change this to search for people with @ tags in their name when they are implemented
  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where(
              (user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            _stopSearch();
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back,
                  color: AppColors.fitnessMainColor),
              onPressed: _isSearching
                  ? _stopSearch
                  : () => Navigator.of(context).pop(),
            ),
            backgroundColor: AppColors.fitnessBackgroundColor,
            actions: [
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.search,
                      color: AppColors.fitnessMainColor),
                  onPressed: _startSearch,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(),
              labelColor: AppColors.fitnessMainColor,
              unselectedLabelColor: AppColors.fitnessSecondaryTextColor,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              tabs: const [
                Tab(text: 'Feed'),
                Tab(text: 'Profile'),
              ],
            ),
          ),
          // TODO: Remove the second tab if the user is not logged in (Public view)
          body: _isReady
              ? _isSearching
                  ? _buildSearchSection()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildFeedSection(),
                        ProfilePage(
                            userId: FirebaseAuth.instance.currentUser!.uid),
                      ],
                    )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
          floatingActionButton: !_isSearching
              ? FloatingActionButton(
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
                )
              : null,
          backgroundColor: AppColors.fitnessBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildFeedSection() {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppColors.fitnessMainColor,
      backgroundColor: AppColors.fitnessBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 5, right: 5),
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

  Widget _buildSearchSection() {
    return Container(
      height: 300, // Set a fixed height
      width: double.infinity, // Set width to infinity
      color: AppColors.fitnessBackgroundColor, // Set background color
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.fitnessMainColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              style: const TextStyle(
                  color: AppColors.fitnessPrimaryTextColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(userId: _filteredUsers[index].userId),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(_filteredUsers[index]
                          .email[0], style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),), // TODO: Replace with user profile image
                      backgroundColor: AppColors.fitnessMainColor,
                    ),
                    title: Text(
                      _filteredUsers[index].email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: AppColors.fitnessPrimaryTextColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
