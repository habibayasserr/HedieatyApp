import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/notification_page.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Title for the header
  final VoidCallback? onLogoTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const CustomHeader({
    Key? key,
    required this.title,
    this.onLogoTap,
    this.onNotificationTap,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AppBar(
          key: const Key('custom_header_app_bar'),
          backgroundColor: const Color(
              0xFFF8F9FA), // Neutral light background for consistency
          elevation: 2,
          centerTitle: true, // Center the title
          title: Text(
            title,
            key: const Key('header_title_text'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(
                  0xFFEF0F72), // Bright pink for title (consistent with footer)
            ),
          ),
          leading: GestureDetector(
            key: const Key('home_navigation_logo'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Padding(
              padding: constraints.maxWidth > 600
                  ? const EdgeInsets.only(
                      left: 32.0,
                      top: 8.0,
                      bottom: 8.0) // Wider padding for larger screens
                  : const EdgeInsets.only(
                      left: 16.0,
                      top: 8.0,
                      bottom: 8.0), // Default padding for smaller screens
              child: Icon(
                Icons.card_giftcard, // Creative gift icon
                color: const Color(
                    0xFFEF0F72), // Bright pink color (consistent with theme)
                size: constraints.maxWidth > 600
                    ? 48
                    : 36, // Adjust icon size for larger screens
              ),
            ),
          ),
          actions: [
            IconButton(
              key: const Key('notification_icon_button'),
              icon: Icon(
                Icons.notifications_active_outlined, // Updated to a better icon
                color: const Color(
                    0xFF005F73), // Neutral gray for idle state (consistent with footer)
                size: constraints.maxWidth > 600
                    ? 32
                    : 28, // Adjust size for larger screens
              ),
              onPressed: () {
                final String? userId = FirebaseAuth.instance.currentUser?.uid;

                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(userId: userId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please log in to view notifications.')),
                  );
                }
              },
            ),
            IconButton(
              key: const Key('profile_icon_button'),
              icon: Icon(
                Icons.account_circle_outlined, // Updated to a better icon
                color: const Color(
                    0xFF005F73), // Neutral gray for idle state (consistent with footer)
                size: constraints.maxWidth > 600
                    ? 32
                    : 28, // Adjust size for larger screens
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            const SizedBox(width: 8), // Padding between icons and screen edge
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
