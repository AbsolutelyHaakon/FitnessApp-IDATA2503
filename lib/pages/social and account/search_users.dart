import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/Initialization/social_feed_data.dart';
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/modules/profile%20and%20authentication/profile_page.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// SearchUsers page to search for users.

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final SocialFeedData _socialFeedData = SocialFeedData(); // Instance to fetch data
  List<LocalUser> _allUsers = []; // List to store all users
  List<LocalUser> _filteredUsers = []; // List to store filtered users
  final FocusNode _searchFocusNode = FocusNode(); // Focus node for search field
  final TextEditingController _searchController = TextEditingController(); // Controller for search field

  @override
  void initState() {
    super.initState();
    getUsers(); // Fetch users when the widget is initialized
  }

  // Function to fetch users from the database
  Future<void> getUsers() async {
    try {
      final fetchedUsers = await _socialFeedData.fireBaseFetchUsersForSearch(); // Fetch users
      setState(() {
        // Update state with fetched users, excluding the current user
        _allUsers = fetchedUsers["users"]?.where((user) => user.userId != FirebaseAuth.instance.currentUser?.uid).toList() ?? [];
        _filteredUsers = _allUsers; // Initially, all users are shown
      });
    } catch (e) {
      print("Error fetching users: $e"); // Print error if fetching fails
    }
  }

  // Function to filter users based on search query
  void _filterUsers(String query) {
    setState(() {
      // Update filtered users list based on query
      _filteredUsers = _allUsers
          .where((user) => user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Make container take full width
        color: AppColors.fitnessBackgroundColor, // Set background color
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0), // Padding around search field
              child: CupertinoTextField(
                focusNode: _searchFocusNode, // Set focus node
                controller: _searchController, // Set controller
                placeholder: 'Search users...',
                placeholderStyle: TextStyle(
                  color: AppColors.fitnessSecondaryTextColor, // Set placeholder text color
                ),// Placeholder text
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(CupertinoIcons.search, color: AppColors.fitnessMainColor), // Search icon
                ),
                decoration: BoxDecoration(
                  color: AppColors.fitnessModuleColor, // Background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                style: const TextStyle(
                  color: AppColors.fitnessPrimaryTextColor, // Text color
                  fontWeight: FontWeight.w500, // Text weight
                  fontSize: 15, // Text size
                ),
                onChanged: _filterUsers, // Call filter function on text change
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length, // Number of items in the list
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // Navigate to profile page on tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userId: _filteredUsers[index].userId),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        // Display first letter of user's email
                        child: Text(_filteredUsers[index].email[0], style: const TextStyle(color: AppColors.fitnessPrimaryTextColor)),
                        backgroundColor: AppColors.fitnessMainColor, // Avatar background color
                      ),
                      title: Text(
                        _filteredUsers[index].email, // Display user's email
                        style: const TextStyle(
                          fontWeight: FontWeight.w500, // Text weight
                          fontSize: 18, // Text size
                          color: AppColors.fitnessPrimaryTextColor, // Text color
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
      backgroundColor: AppColors.fitnessBackgroundColor, // Set background color
    );
  }
}