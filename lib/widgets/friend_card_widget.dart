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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        key: const Key('friend_list_tile'),
        leading: CircleAvatar(
          key: const Key('friend_profile_image'),
          backgroundImage:
              AssetImage(profileImage), // Use AssetImage for local assets
          radius: 24,
        ),
        title: Text(
          name,
          key: const Key('friend_name_text'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          upcomingEvents > 0
              ? 'Upcoming Events: $upcomingEvents'
              : 'No Upcoming Events',
          key: const Key('friend_upcoming_events_text'),
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          key: Key('friend_card_trailing_icon'),
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
