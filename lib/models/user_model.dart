class User {
  final int? id;
  final String name;
  final String phone;
  final String email;

  User({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  // Convert User object to Map for local database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  // Convert Map to User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}
