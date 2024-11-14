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

  bool followerCountReady = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (FirebaseAuth.instance.currentUser?.uid != widget.userId) {
      _checkIfFollowing();
    }
    _loadFollowerData();

  }

  Future<void> _loadUserData() async {
    final user = await _userDao.fireBaseGetUserData(widget.userId);

    setState(() {
      name = user?["name"] ?? "Unknown";
    });
  }

  Future<void> _loadFollowerData() async {
    final followerData =
        await _userFollowsDao.fireBaseGetFollowerCount(widget.userId);
    final followingData =
        await _userFollowsDao.fireBaseGetFollowingCount(widget.userId);

    setState(() {
      followers = followerData ?? 0;
      following = followingData ?? 0;
      followerCountReady = true;
    });

    _setReady();
  }

  void _checkIfFollowing(){
  if (FirebaseAuth.instance.currentUser?.uid != null) {
    _userFollowsDao.fireBaseCheckIfFollows(FirebaseAuth.instance.currentUser!.uid, widget.userId).then((value) {
      setState(() {
        _isFollowing = value;
      });
    });
  }
  }

  void _toggleFollow() {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      if (_isFollowing) {
        _userFollowsDao.fireBaseUnfollow(FirebaseAuth.instance.currentUser!.uid, widget.userId);
      } else {
        _userFollowsDao.fireBaseFollow(FirebaseAuth.instance.currentUser!.uid, widget.userId);
      }
    }
    setState(() {
      _isFollowing = !_isFollowing;
      followers = _isFollowing ? followers + 1 : followers - 1;
    });
  }

  void _setReady() {
    if (name.isNotEmpty && followerCountReady) {
      setState(() {
        _isReady = true;
      });
      print("is ready: $_isReady");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isReady
        ? SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://picsum.photos/id/13/800/300'),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            setState(() {
                              bannerURL = 'assets/images/placeholder.png';
                            });
                          },
                        ),
                      ),
                    ),
                    Positioned(
                        left: 20,
                        bottom: -45,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/id/86/200/200'),
                          onBackgroundImageError: (_, __) {
                            setState(() {
                              imageURL = 'assets/images/placeholder.png';
                            });
                          },
                          radius: 50.0,
                          backgroundColor: Colors.white,
                        )),
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
                              fontWeight: FontWeight.bold, fontSize: 20),
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
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          Text(
                            followers.toString(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text(
                            'Following',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          Text(
                            following.toString(),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (FirebaseAuth.instance.currentUser?.uid != widget.userId)
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
                              style: const TextStyle(
                                  color: AppColors.fitnessPrimaryTextColor),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://picsum.photos/id/${index + 1}/200/200'),
                            onError: (_, __) {
                              setState(() {
                                imageURL = 'assets/images/placeholder.png';
                              });
                            },
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
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
