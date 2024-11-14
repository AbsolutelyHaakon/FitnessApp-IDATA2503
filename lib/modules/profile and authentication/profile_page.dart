import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_follows_dao.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

/// Profile page for a user
/// Used for both your own but also other users profiles
///
/// Last edited: 14.11.2024
/// Last edited by: Håkon Svensen Karlsen
///
/// TODO: Implement backend logic
/// TODO: Implement follow button

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Fetch DAOs
  final UserDao _userDao = UserDao();
  final UserFollowsDao _userFollowsDao = UserFollowsDao();

  String name = " ";
  String imageURL = " ";
  String bannerURL = " ";

  int followers = 0;
  int following = 0;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFollowerData();
  }

  Future<void> _loadUserData() async {
    final user = await _userDao.fireBaseGetUserData(widget.userId);

    setState(() {
      name = user?["name"] as String;
    });
  }

  Future<void> _loadFollowerData() async {
    final followerData =
        await _userFollowsDao.fireBaseGetFollowerCount(widget.userId);
    final followingData =
        await _userFollowsDao.fireBaseGetFollowingCount(widget.userId);

    setState(() {
      followers = followerData;
      following = followingData;
    });
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/id/13/800/300'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Positioned(
                left: 20,
                bottom: -45,
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://picsum.photos/id/65/200'),
                  radius: 50.0,
                  backgroundColor: Colors.white,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      'Followers',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    Text(
                      followers.toString(),
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Text(
                      'Following',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    Text(
                      following.toString(),
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing
                            ? AppColors.fitnessSecondaryModuleColor
                            : AppColors.fitnessMainColor,
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(color: AppColors.fitnessPrimaryTextColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://picsum.photos/id/${index + 1}/200/200'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
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
