class Gift {
  final String name;
  final String category;
  final String status; // "Available" or "Pledged"
  final double price;
  final double description;

  Gift({
    required this.name,
    required this.category,
    required this.status,
    required this.price,
    required this.description,
  });
}
