class Gift {
  final String? id; // Firestore document ID
  final String name;
  final String category;
  final String status; // 'Available', 'Pledged', 'Purchased'
  final double price;
  final String description;
  final String? imageBase64; // Base64 string for the image

  Gift({
    this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.price,
    required this.description,
    this.imageBase64, // Nullable to handle gifts without images
  });

  // Convert Firestore document to Gift object
  factory Gift.fromJson(Map<String, dynamic> json, String id) {
    return Gift(
      id: id,
      name: json['name'],
      category: json['category'],
      status: json['status'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageBase64: json['imageBase64'], // Decode Base64 string
    );
  }

  // Convert Gift object to Firestore-compatible format
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'status': status,
      'price': price,
      'description': description,
      'imageBase64': imageBase64, // Save Base64 string
    };
  }
}
