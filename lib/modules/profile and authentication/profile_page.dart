import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/posts_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/database/crud/user_follows_dao.dart';
import 'package:fitnessapp_idata2503/database/tables/posts.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../pages/social and account/post_builder.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserDao _userDao = UserDao();
  final UserFollowsDao _userFollowsDao = UserFollowsDao();
  final PostsDao _postsDao = PostsDao();

  String name = " ";
  String imageURL = " ";
  String bannerURL = " ";

  int followers = 0;
  int following = 0;
  bool _isFollowing = false;
  bool _isEditing = false;
  bool _changeMade = false;

  bool followerCountReady = false;
  bool _isReady = false;

  XFile? _profileImage;
  XFile? _bannerImage;

  List<Posts> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (FirebaseAuth.instance.currentUser?.uid != widget.userId) {
      _checkIfFollowing();
    }
    _loadUserPosts();
    _loadFollowerData();
  }

  Future<void> _loadUserPosts() async {
    final postsData = await _postsDao.fireBaseFetchUserPosts(widget.userId);

    setState(() {
      _posts = postsData["posts"];
    });
  }

  Future<void> _loadUserData() async {
    final user = await _userDao.fireBaseGetUserData(widget.userId);

    setState(() {
      name = user?["name"] ?? "Unknown";
      imageURL = user?["imageURL"] ?? "";
      bannerURL = user?["bannerURL"] ?? "";
    });

    print(name);
    print(widget.userId);
    print(imageURL);
    print(bannerURL);
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

  void _checkIfFollowing() {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      _userFollowsDao
          .fireBaseCheckIfFollows(
              FirebaseAuth.instance.currentUser!.uid, widget.userId)
          .then((value) {
        setState(() {
          _isFollowing = value;
        });
      });
    }
  }

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
      _isFollowing = !_isFollowing;
      followers = _isFollowing ? followers + 1 : followers - 1;
    });
  }

  void _setReady() {
    if (name.isNotEmpty && followerCountReady) {
      setState(() {
        _isReady = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerImage = pickedFile;
        } else {
          _profileImage = pickedFile;
        }
        _changeMade = true;
      });
    }
  }

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
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FirebaseAuth.instance.currentUser?.uid != widget.userId
          ? AppBar(
              leading: IconButton(
                icon: const Icon(CupertinoIcons.back,
                    color: AppColors.fitnessMainColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: AppColors.fitnessBackgroundColor,
            )
          : null,
      body: _isReady
          ? SingleChildScrollView(
              child: DefaultTextStyle(
                style:
                    const TextStyle(color: AppColors.fitnessPrimaryTextColor),
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
                                    bannerURL = 'assets/images/placeholder.png';
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
                                ? () => _pickImage(ImageSource.gallery, false)
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
                                  imageURL = 'assets/images/placeholder.png';
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
                          if (FirebaseAuth.instance.currentUser?.uid !=
                              widget.userId)
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
                                        color:
                                            AppColors.fitnessPrimaryTextColor),
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
                                  backgroundColor: AppColors.fitnessMainColor,
                                ),
                                child: Text(
                                  _isEditing ? 'Save Changes' : 'Edit Profile',
                                  style: const TextStyle(
                                      color: AppColors.fitnessPrimaryTextColor),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 40.0),
                            child: PostBuilder(
                              post: post,
                              isProfile: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
