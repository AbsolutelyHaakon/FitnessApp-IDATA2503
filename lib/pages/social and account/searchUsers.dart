import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/Initialization/social_feed_data.dart';
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/material.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final SocialFeedData _socialFeedData = SocialFeedData();
  List<LocalUser> _allUsers = [];
  List<LocalUser> _filteredUsers = [];
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsers();
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

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.fitnessBackgroundColor,
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
                  enabledBorder: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: AppColors.fitnessMainColor),
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
                          builder: (context) => ProfilePage(userId: _filteredUsers[index].userId),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(_filteredUsers[index].email[0], style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
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
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}