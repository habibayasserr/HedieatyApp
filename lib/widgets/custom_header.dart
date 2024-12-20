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
    return AppBar(
      key: const Key('custom_header_app_bar'),
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        key: const Key('custom_header_title_row'),
        children: [
          GestureDetector(
            key: const Key('home_navigation_logo'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/images/app_logo.jpg',
                  height: 92,
                  width: 92,
                  key: const Key('app_logo_image'),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  key: const Key('header_title_text'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          key: const Key('notification_icon_button'),
          icon: const Icon(Icons.notifications),
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
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
