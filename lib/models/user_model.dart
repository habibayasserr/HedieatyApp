class UserModel {
  String name;
  String phone;
  String imageUrl;

  UserModel(this.name, this.phone, this.imageUrl);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['name'],
      json['phone'],
      json['imageUrl'] ?? "assets/images/default_profile.jpg",
    );
  }
}
