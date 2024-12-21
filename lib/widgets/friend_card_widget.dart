import 'package:flutter/material.dart';

class FriendCardWidget extends StatelessWidget {
  final String name;
  final String profileImage;
  final int upcomingEvents;
  final VoidCallback onTap;

  const FriendCardWidget({
    Key? key,
    required this.name,
    required this.profileImage,
    required this.upcomingEvents,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('friend_card_widget'),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5F8FF), // Light blue outline
          width: 2,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        key: const Key('friend_list_tile'),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          key: const Key('friend_profile_image'),
          backgroundImage:
              AssetImage(profileImage), // Use AssetImage for local assets
          radius: 28,
          backgroundColor: const Color(0xFFFDE9F2), // Pale pink border effect
        ),
        title: Text(
          name,
          key: const Key('friend_name_text'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFFEF0F72), // Bright pink for title
          ),
        ),
        subtitle: Text(
          upcomingEvents > 0
              ? 'Upcoming Events: $upcomingEvents'
              : 'No Upcoming Events',
          key: const Key('friend_upcoming_events_text'),
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          key: Key('friend_card_trailing_icon'),
          size: 20,
          color: Color(0xFF888888), // Neutral gray for icon
        ),
        onTap: onTap,
      ),
    );
  }
}
