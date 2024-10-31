// lib/modules/user_profile_module.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: $email',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Height: ${height.toStringAsFixed(2)} m',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Weight: ${weight.toStringAsFixed(2)} kg',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}