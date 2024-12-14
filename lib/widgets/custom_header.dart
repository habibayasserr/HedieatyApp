import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Title for the header
  // Actions for navigation (commented for static implementation)
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
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0, // Align the logo and title to the left
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Uncomment when Home Screen navigation is implemented
              // if (onLogoTap != null) onLogoTap!();
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/images/app_logo.jpg', // Path to your app logo
                  height: 92, // Adjust the logo size
                  width: 92,
                ),
                const SizedBox(width: 8), // Space between logo and title
                Text(
                  title,
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
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            // Uncomment when Notifications Screen is implemented
            // if (onNotificationTap != null) onNotificationTap!();
          },
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
            // Uncomment when Profile Screen is implemented
            // if (onProfileTap != null) onProfileTap!();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
