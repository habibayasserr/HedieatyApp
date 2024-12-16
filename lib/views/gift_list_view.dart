import 'dart:io'; // Import for handling files
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gift_model.dart';
import 'gift_details_view.dart';
import '../models/event_model.dart';

class GiftListView extends StatefulWidget {
  final Event event;
  const GiftListView({Key? key, required this.event}) : super(key: key);

  @override
  _GiftListViewState createState() => _GiftListViewState();
}

class _GiftListViewState extends State<GiftListView> {
  final List<Gift> gifts = [
    Gift(
      name: 'Smartwatch',
      category: 'Electronics',
      status: 'Available',
      price: 1500.0,
      description: 'A modern smartwatch with various health features.',
    ),
    Gift(
      name: 'Cookbook',
      category: 'Books',
      status: 'Pledged',
      price: 200.0,
      description: 'A comprehensive cookbook with recipes for beginners.',
    ),
    Gift(
      name: 'Gaming Console',
      category: 'Electronics',
      status: 'Purchased',
      price: 10000.0,
      description: 'A high-end gaming console with advanced features.',
    ),
  ];

  String selectedSortOption = 'Sort by Name (Ascending)';
  final ImagePicker _picker = ImagePicker();
  void _showGiftDialog({Gift? gift, int? index}) {
    final TextEditingController nameController =
        TextEditingController(text: gift?.name);
    final TextEditingController categoryController =
        TextEditingController(text: gift?.category);
    final TextEditingController priceController =
        TextEditingController(text: gift?.price.toString());
    final TextEditingController descriptionController =
        TextEditingController(text: gift?.description);

    String? imagePath = gift?.imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder for in-dialog setState()
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Gift Image',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          dialogSetState(() {
                            imagePath = pickedFile.path; // Update imagePath
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: imagePath != null
                            ? Image.file(File(imagePath!), fit: BoxFit.cover)
                            : const Center(
                                child: Text('Tap to add an image'),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Gift Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      decoration:
                          const InputDecoration(labelText: 'Price (EGP)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final category = categoryController.text.trim();
                    final price = double.tryParse(priceController.text.trim());
                    final description = descriptionController.text.trim();

                    if (name.isEmpty ||
                        category.isEmpty ||
                        price == null ||
                        description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                        ),
                      );
                      return;
                    }

                    if (gift == null) {
                      // Add new gift
                      setState(() {
                        gifts.add(Gift(
                          name: name,
                          category: category,
                          status: 'Available',
                          price: price,
                          description: description,
                          imagePath: imagePath,
                        ));
                      });
                    } else {
                      // Update existing gift
                      setState(() {
                        gifts[index!] = Gift(
                          name: name,
                          category: category,
                          status: gift.status,
                          price: price,
                          description: description,
                          imagePath: imagePath,
                        );
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: Text(gift == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _sortGifts() {
    switch (selectedSortOption) {
      case 'Sort by Name (Ascending)':
        gifts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Sort by Name (Descending)':
        gifts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Sort by Category':
        gifts.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Sort by Status':
        gifts.sort((a, b) => a.status.compareTo(b.status));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gifts List'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Sorting Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedSortOption,
              items: [
                'Sort by Name (Ascending)',
                'Sort by Name (Descending)',
                'Sort by Category',
                'Sort by Status',
              ].map((sortOption) {
                return DropdownMenuItem(
                  value: sortOption,
                  child: Text(sortOption),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSortOption = value;
                    _sortGifts();
                  });
                }
              },
              isExpanded: true,
            ),
          ),
          // Gifts List
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                final Color cardColor = gift.status == 'Purchased'
                    ? Colors.red[100]!
                    : gift.status == 'Pledged'
                        ? Colors.green[100]!
                        : Colors.white;

                return Card(
                  color: cardColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(gift.name),
                    subtitle: Text(
                      'Category: ${gift.category}\nPrice: ${gift.price.toStringAsFixed(2)} EGP',
                    ),
                    onTap: () {
                      // Navigate to GiftDetailsView in read-only mode
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftDetailsView(gift: gift),
                        ),
                      );
                    },
                    trailing: gift.status == 'Available'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showGiftDialog(gift: gift, index: index),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    gifts.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          )
                        : null, // Hide Edit/Delete for non-available gifts
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGiftDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
