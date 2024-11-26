import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/edit_field.dart';
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

  void navigateToEditField(
      BuildContext context,
      String title,
      String initialValue,
      ValueChanged<String> onSave,
      TextInputType keyboardType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditFieldPage(
          title: title,
          initialValue: initialValue,
          onSave: onSave,
          keyboardType: keyboardType,
        ),
      ),
    );
  }

  void navigateToEditEmailField(BuildContext context, String title,
      String initialValue, ValueChanged<String> onSave, String password) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditFieldPage(
          title: title,
          initialValue: initialValue,
          keyboardType: TextInputType.emailAddress,
          onSave: (newValue) async {
            onSave(newValue);
            UserDao().fireBaseUpdateUserEmail(
              FirebaseAuth.instance.currentUser!.uid,
              newValue,
              password,
            );
          },
        ),
      ),
    );
  }

  void showReauthenticationDialog(BuildContext context, String title,
      String initialValue, ValueChanged<String> onSave) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.fitnessModuleColor,
          title: const Text('Re-authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                cursorColor: Colors.white,
                controller: emailController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                  suffixStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                cursorColor: Colors.white,
                controller: passwordController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                  suffixStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  labelText: 'Password',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.fitnessMainColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;

                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: email,
                      password: password,
                    );
                    await user.reauthenticateWithCredential(credential);
                    Navigator.of(context).pop();
                    navigateToEditEmailField(
                        context, title, initialValue, onSave, password);
                  }
                } catch (e) {
                  print('Error re-authenticating: $e');
                }
              },
              child: const Text('Authenticate',
                  style: TextStyle(color: AppColors.fitnessMainColor)),
            ),
          ],
        );
      },
    );
  }

  void showUpdatePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.fitnessModuleColor,
          title: const Text('Update Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                cursorColor: Colors.white,
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                  suffixStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  labelText: 'Current Password',
                ),
                obscureText: true,
              ),
              TextFormField(
                cursorColor: Colors.white,
                controller: newPasswordController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                  suffixStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fitnessMainColor),
                  ),
                  labelText: 'New Password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.fitnessMainColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;

                try {
                  var result = await UserDao().fireBaseUpdateUserPassword(
                    FirebaseAuth.instance.currentUser!.uid,
                    currentPassword,
                    newPassword,
                  );
                  if (result['success']) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${result['error']}'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error updating password: $e');
                }
              },
              child: const Text(
                'Update',
                style: TextStyle(color: AppColors.fitnessMainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void showUpdateHeightDialog(BuildContext context) {
    final TextEditingController heightController = TextEditingController();
    heightController.text = height.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.fitnessModuleColor,
          title: const Text('Update Height'),
          content: TextFormField(
            cursorColor: Colors.white,
            controller: heightController,
            decoration: const InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(fontSize: 16, color: Colors.white),
              suffixStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.fitnessMainColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.fitnessMainColor),
              ),
              labelText: 'Height (cm)',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.fitnessMainColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newHeight = heightController.text;
                height = int.parse(newHeight);
                UserDao().fireBaseUpdateUserData(
                  FirebaseAuth.instance.currentUser!.uid,
                  '',
                  double.parse(newHeight),
                  0,
                  0,
                  0,
                  null,
                  null,
                  0,
                  0,
                  0,
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Update',
                style: TextStyle(color: AppColors.fitnessMainColor),
              ),
            ),
          ],
        );
      },
    );
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
                        'Full Name',
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
                  onTap: () {
                    navigateToEditField(context, 'Full Name', displayName,
                        (newValue) {
                      displayName = newValue;
                      UserDao().fireBaseUpdateUserData(
                          FirebaseAuth.instance.currentUser!.uid,
                          newValue,
                          0,
                          0,
                          0,
                          0,
                          null,
                          null,
                          0,
                          0,
                          0);
                    }, TextInputType.text);
                  },
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
                  onTap: () {
                    showReauthenticationDialog(
                      context,
                      'Email',
                      email,
                      (newValue) {
                        email = newValue;
                      },
                    );
                  },
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
                  onTap: () {
                    showUpdatePasswordDialog(context);
                  },
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
                  onTap: () {
                    showUpdateHeightDialog(context);
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
