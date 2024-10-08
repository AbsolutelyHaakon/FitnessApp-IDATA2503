import 'package:fitnessapp_idata2503/database/crud/user_dao.dart'; // Import UserDao
import 'package:fitnessapp_idata2503/database/tables/user.dart';
import 'package:fitnessapp_idata2503/modules/create_add_user_widget.dart';
import 'package:flutter/material.dart';

class Me extends StatefulWidget {
  @override
  _MeState createState() => _MeState();
}

class _MeState extends State<Me> {
  Future<List<User>>? users;
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
        backgroundColor: Color(0xFF292929),
      ),
      body: Center(
        child: FutureBuilder<List<User>>(
          future: users,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading users'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No Users..',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                  ),
                ),
              );
            } else {
              final users = snapshot.data!;

              return ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final email = user.email;
                  final name = user.name;
                  final weight = user.weight;

                  return ListTile(
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: Text('$weight kg'),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateAddUserWidget(
                        user: user,
                        onSubmit: (userDetails) async {
                          if (userDetails['name'] != null &&
                              userDetails['email'] != null &&
                              userDetails['password'] != null &&
                              userDetails['weight'] != null) {
                            await userDao.update( // Use UserDao to update user
                              User(
                                id: user.id,
                                name: userDetails['name']!,
                                email: userDetails['email']!,
                                password: userDetails['password']!,
                                weight: int.parse(userDetails['weight']!),
                              ),
                            );
                            if (!mounted) return;
                            fetchUsers();
                            Navigator.of(context).pop();
                          } else {
                            // Handle the case where userDetails are null
                            // For example, show an error message
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateAddUserWidget(
              onSubmit: (userDetails) async {
                try {
                  if (userDetails['name'] != null &&
                      userDetails['email'] != null &&
                      userDetails['password'] != null &&
                      userDetails['weight'] != null) {
                    await userDao.create( // Use UserDao to create user
                      User(
                        name: userDetails['name']!,
                        email: userDetails['email']!,
                        password: userDetails['password']!,
                        weight: int.parse(userDetails['weight']!),
                      ),
                    );
                    if (!mounted) return;
                    fetchUsers();
                    Navigator.of(context).pop();
                  } else {
                    print('Error: Some user details are null');
                  }
                } catch (e) {
                  print('Error creating user: $e');
                }
              },
            ),
          );
        },
      ),
      backgroundColor: Color(0xFF292929),
    );
  }
}