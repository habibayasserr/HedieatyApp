class Friend {
  final int userId; // The user who is adding the friend
  final int friendUserId; // The friend's user ID (another user)

  Friend({
    required this.userId,
    required this.friendUserId,
  });

  // Convert Friend object to Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'friend_user_id': friendUserId,
    };
  }

  // Convert Map to Friend object
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['user_id'],
      friendUserId: map['friend_user_id'],
    );
  }
}
