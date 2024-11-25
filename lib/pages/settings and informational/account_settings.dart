import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  AccountSettingsPage({super.key});

  late String displayName;
  late String email;
  late int height;

  Future<void> getUserData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      try {
        var userDataMap = await UserDao()
            .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);

        if (userDataMap != null &&
            userDataMap.containsKey('name') &&
            userDataMap.containsKey('email') &&
            userDataMap.containsKey('height')) {
          displayName = userDataMap['name'];
          email = userDataMap['email'];
          height = (userDataMap['height'] as double).toInt();
        }
      } catch (e) {
        print('Error fetching goal weight: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            backgroundColor: AppColors.fitnessBackgroundColor,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(CupertinoIcons.back,
                    color: AppColors.fitnessMainColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Account Settings',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: AppColors.fitnessBackgroundColor,
            ),
            body: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Display Name',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          displayName, //Insert user display name here
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  trailing: Transform.scale(
                    scale: 0.6,
                    child: const Icon(CupertinoIcons.right_chevron,
                        color: AppColors.fitnessMainColor),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.mail_rounded,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  trailing: Transform.scale(
                    scale: 0.6,
                    child: const Icon(CupertinoIcons.right_chevron,
                        color: AppColors.fitnessMainColor),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.lock_rounded,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '********', //Insert user display name here
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  trailing: Transform.scale(
                    scale: 0.6,
                    child: const Icon(CupertinoIcons.right_chevron,
                        color: AppColors.fitnessMainColor),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.height_outlined,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Height',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '$height m', //Insert user display name here
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  trailing: Transform.scale(
                    scale: 0.6,
                    child: const Icon(CupertinoIcons.right_chevron,
                        color: AppColors.fitnessMainColor),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
