import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor), // Back button
          onPressed: () =>
              Navigator.of(context).pop(), // Go back to previous page
        ),
        backgroundColor: AppColors.fitnessBackgroundColor,
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
      body: Center(
        child: Markdown(
          data: '''
Welcome to G5 Fitness! These Terms and Conditions ("Terms") govern your access and use of our fitness application ("App"), including sharing posts and workouts with other users. By using our App, you agree to these Terms, so please read them carefully.

# 1. Account Registration
By accessing or using G5 Fitness, you agree to be bound by these Terms, our Privacy Policy, and any additional guidelines or rules posted within the App. If you do not agree with these Terms, please do not use our services.

# 2. Account Registration
* Eligibility: You must be at least 13 years old (or the legal age in your jurisdiction) to use the App.
* Account Security: You are responsible for maintaining the confidentiality of your login information and for all activities that occur under your account.
* Accuracy of Information: You agree to provide accurate, current, and complete information during registration and to update this information as needed.

# 3. User Conduct
You agree not to:

* Share any content that is unlawful, harmful, or offensive.
* Impersonate others or provide false information.
* Post any material that infringes on the intellectual property rights of others.
* Harass, abuse, or harm other users.
* Use the App for any unauthorized or illegal purpose.

# 4. Content Sharing and User-Generated Content
* Your Content: You retain ownership of any content you share, including posts and workouts. However, by posting, you grant G5 Fitness a non-exclusive, royalty-free, worldwide license to use, display, and distribute your content within the App.
* Content Responsibility: You are solely responsible for the content you post. G5 Fitness does not endorse or take responsibility for any user-generated content.
* Moderation: We reserve the right to remove or disable any content that violates these Terms or is otherwise deemed inappropriate.

# 5. Intellectual Property
* All rights, title, and interest in and to the App (excluding user-generated content) are and will remain the exclusive property of G5 Fitness.
* You may not copy, modify, distribute, sell, or lease any part of our App or included software without our prior written consent.

# 6. Privacy
Our Privacy Policy explains how we collect, use, and share your information. By using the App, you agree to our Privacy Policy.

# 7. Disclaimers and Limitation of Liability
* No Guarantees: G5 Fitness is provided "as is" without warranties of any kind. We do not guarantee that the App will be error-free or uninterrupted.
* Health Disclaimer: Always consult a medical professional before starting any workout or fitness program. G5 Fitness is not responsible for any injuries resulting from the use of our content.
* Limitation of Liability: To the fullest extent permitted by law, G5 Fitness will not be liable for any indirect, incidental, or consequential damages arising out of or related to your use of the App.

# 8. Termination
We may suspend or terminate your access to the App at any time if you violate these Terms. You can also terminate your account at any time.

# 9. Changes to These Terms
We may update these Terms periodically. We will notify you of any significant changes, and continued use of the App after such changes constitutes your acceptance of the new Terms.

# 10. Governing Law
These Terms are governed by the laws of Norway. Any disputes arising from these Terms will be resolved in the courts of Norway.

By using G5 Fitness, you acknowledge that you have read, understood, and agree to be bound by these Terms.
        ''',
          styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              h2: const TextStyle(color: Colors.white),
              p: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal),
              listBullet: const TextStyle(color: Colors.white),
              h1Padding: const EdgeInsets.only(top: 20)
              // Add more styles as needed
              ),
          // Set the background color of the Markdown widget
          selectable: true,
        ),
      ),
    );
  }
}
