import 'package:firebase_auth/firebase_auth.dart';
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
/// TODO: Create "create" post page
/// TODO: Implement backend logic
/// TODO: Create profile page

class SocialFeed extends StatefulWidget {
  final User? user;

  const SocialFeed({super.key, required this.user});

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
  Future<void> _refreshFeed() async {
    // TODO: Implement refresh logic here
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.fitnessMainColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: AppColors.fitnessBackgroundColor,
          bottom: const TabBar(
            indicator: BoxDecoration(),
            labelColor: AppColors.fitnessMainColor,
            unselectedLabelColor: AppColors.fitnessSecondaryTextColor,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            unselectedLabelStyle:
                TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedSection(),
            _buildProfileSection(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePostPage(user: widget.user)),
            );
          },
          backgroundColor: AppColors.fitnessMainColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.black),
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
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
          itemCount: 1,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: PostBuilder(
                profileImageUrl: 'https://picsum.photos/id/237/200/200',
                name: 'Håkon Karlsen',
                date: DateTime.now(),
                icon: Icons.message,
                message: 'I really enjoyed my workout today!',
                workoutStats: const [
                  {'name': 'Duration', 'value': '30:00'},
                  {'name': 'Sets', 'value': '3'},
                  {'name': 'Weight', 'value': '50 kg'},
                ],
                workoutId: 'workout123',
                imageUrl: 'https://picsum.photos/seed/picsum/400/300',
                location: 'Mandal',
                commentCount: 10,
                shareCount: 5,
                heartCount: 20,
              ),
            );
          },
        ),
      ),
    );
  }

 Widget _buildProfileSection() {
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
                backgroundImage: NetworkImage('https://picsum.photos/id/65/200'),
                radius: 50.0,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              SizedBox(width: 110),
              Expanded(
                child: Text(
                  'Håkon Svensen Karlsen',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.only(right: 50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  Text(
                    'Followers',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  Text(
                    '150',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(width: 30),
              Column(
                children: [
                  Text(
                    'Following',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  Text(
                    '200',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
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
                    image: NetworkImage('https://picsum.photos/id/${index + 1}/200/200'),
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
