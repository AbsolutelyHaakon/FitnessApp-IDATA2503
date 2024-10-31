import 'package:fitnessapp_idata2503/database/crud/user_dao.dart'; // Import UserDao
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/modules/create_add_user_widget.dart';
import 'package:flutter/material.dart';

class Me extends StatefulWidget {
  @override
  _MeState createState() => _MeState();
}

class _MeState extends State<Me> {
  Future<List<LocalUser>>? users;
  final userDao = UserDao(); // Create an instance of UserDao

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() {
    setState(() {
      users = userDao.fetchAll(); // Use UserDao to fetch users
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
        backgroundColor: const Color(0xFF000000),
      ),
      body: Center (

      ),
        backgroundColor: const Color(0xFF000000),
    );
  }
}