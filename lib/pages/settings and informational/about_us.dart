import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  final List<Map<String, String>> developers = [
    {
      'name': 'Adrian Faustino Johansen',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/adrian.png'
    },
    {
      'name': 'Håkon Svensen Karlsen',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/haakon.png'
    },
    {
      'name': 'Di Xie',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/di.png'
    },
    {
      'name': 'Matti Kjellstadli',
      'credentials': 'Bachelor student at NTNU',
      'imageUrl': 'assets/images/matti.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Developers',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.fitnessPrimaryTextColor,
          ),
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: developers.length,
                itemBuilder: (context, index) {
                  final developer = developers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(developer['imageUrl']!),
                          backgroundColor: AppColors.fitnessMainColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          developer['name']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          developer['credentials']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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