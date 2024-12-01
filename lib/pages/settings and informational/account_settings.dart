import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/database/crud/user_dao.dart';
import 'package:fitnessapp_idata2503/pages/settings%20and%20informational/edit_field.dart';
import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Account settings page for the user to view and edit their account settings.
class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late String displayName;

  late String email;

  late int height;

  late int weightTarget;

  late int waterTarget;

  late int caloriesIntakeTarget;

  late int caloriesBurnedTarget;

  Future<void> getUserData() async {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      try {
        var userDataMap = await UserDao()
            .fireBaseGetUserData(FirebaseAuth.instance.currentUser!.uid);

        if (userDataMap != null &&
            userDataMap.containsKey('name') &&
            userDataMap.containsKey('email') &&
            userDataMap.containsKey('height') &&
            userDataMap.containsKey('weightTarget') &&
            userDataMap.containsKey('waterTarget') &&
            userDataMap.containsKey('caloriesIntakeTarget') &&
            userDataMap.containsKey('caloriesBurnedTarget')) {
          displayName = userDataMap['name'];
          email = userDataMap['email'];
          height = (userDataMap['height'] as double).toInt();
          weightTarget = userDataMap['weightTarget'];
          waterTarget = userDataMap['waterTarget'];
          caloriesIntakeTarget = userDataMap['caloriesIntakeTarget'];
          caloriesBurnedTarget = userDataMap['caloriesBurnedTarget'];
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
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
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
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
                cursorColor: Colors.white,
                controller: passwordController,
                obscureText: true,
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
                keyboardType: TextInputType.text,
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
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
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
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.fitnessMainColor));
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
                'Account Settings & Goals',
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
                          displayName,
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
                          '********',
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
                          '${height}m', //Insert user display name here
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
                    navigateToEditField(
                        context, 'Height (cm)', height.toString(), (newValue) {
                      height = int.parse(newValue);
                      UserDao().fireBaseUpdateUserData(
                          FirebaseAuth.instance.currentUser!.uid,
                          '',
                          height.toDouble(),
                          0,
                          0,
                          0,
                          null,
                          null,
                          0,
                          0,
                          0);
                    }, TextInputType.number);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fitness_center,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weight Goal',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${weightTarget}kg',
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
                    navigateToEditField(
                        context, 'Weight Goal (kg)', weightTarget.toString(),
                        (newValue) {
                      weightTarget = int.parse(newValue);
                      UserDao().fireBaseUpdateUserData(
                          FirebaseAuth.instance.currentUser!.uid,
                          '',
                          0,
                          0,
                          weightTarget,
                          0,
                          null,
                          null,
                          0,
                          0,
                          0);
                    }, TextInputType.number);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.water_drop_rounded,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Water Goal',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${waterTarget}ml',
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
                    navigateToEditField(
                        context, 'Water Goal (ml)', waterTarget.toString(),
                        (newValue) {
                      waterTarget = int.parse(newValue);
                      UserDao().fireBaseUpdateUserData(
                          FirebaseAuth.instance.currentUser!.uid,
                          '',
                          0,
                          0,
                          0,
                          0,
                          null,
                          null,
                          waterTarget,
                          0,
                          0);
                    }, TextInputType.number);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dinner_dining_rounded,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calorie Intake Goal',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${caloriesIntakeTarget}cal',
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
                    navigateToEditField(context, 'Calorie Intake Goal (cal)',
                        caloriesIntakeTarget.toString(), (newValue) {
                      caloriesIntakeTarget = int.parse(newValue);
                      UserDao().fireBaseUpdateUserData(
                          FirebaseAuth.instance.currentUser!.uid,
                          '',
                          0,
                          0,
                          0,
                          0,
                          null,
                          null,
                          0,
                          caloriesIntakeTarget,
                          0);
                    }, TextInputType.number);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.flame_fill,
                      color: AppColors.fitnessMainColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calorie Burn Goal',
                        style: TextStyle(
                          color: AppColors.fitnessPrimaryTextColor,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${caloriesBurnedTarget}cal',
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
                    navigateToEditField(context, 'Calorie Burn Goal (cal)',
                        caloriesBurnedTarget.toString(), (newValue) {
                      caloriesBurnedTarget = int.parse(newValue);
                      UserDao().fireBaseUpdateUserData(
                          FirebaseAuth.instance.currentUser!.uid,
                          '',
                          0,
                          0,
                          0,
                          0,
                          null,
                          null,
                          0,
                          0,
                          caloriesBurnedTarget);
                    }, TextInputType.number);
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
