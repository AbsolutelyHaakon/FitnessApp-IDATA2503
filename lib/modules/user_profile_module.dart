import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp_idata2503/styles.dart';

class UserProfileModule extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double height;
  final double weight;
  final String email;
  final VoidCallback onLogout;

  const UserProfileModule({
    super.key,
    this.imageUrl,
    required this.name,
    required this.height,
    required this.weight,
    required this.email,
    required this.onLogout,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            IntrinsicHeight(
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  color: AppColors.fitnessModuleColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Color(0xFF262626),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        if (imageUrl != null)
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(imageUrl!),
                          )
                        else
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Email: $email',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Height: ${height.toStringAsFixed(2)} m',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Weight: ${weight.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: CupertinoButton(
                        onPressed: () => _logout(context),
                        child: Container(
                          width: 410,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.fitnessBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Logout",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                ),

              ),

            ),
          ],
        ),
      ),
    );
  }
}