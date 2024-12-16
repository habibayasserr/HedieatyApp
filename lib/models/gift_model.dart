class Gift {
  String name;
  String category;
  String status; // "Available" or "Pledged"
  double price;
  String description;
  String? imagePath; // Add the imagePath field

  Gift({
    required this.name,
    required this.category,
    required this.status,
    required this.price,
    required this.description,
    this.imagePath,
  });
}
