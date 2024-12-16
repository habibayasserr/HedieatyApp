import 'dart:io'; // Import for handling files
import 'package:flutter/material.dart';
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
        title: Text(widget.event.name),
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
                          builder: (context) => GiftDetailsView(
                            gift: gift,
                            isEditable: false,
                          ),
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
                                onPressed: () {
                                  // Navigate to GiftDetailsView in editable mode
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GiftDetailsView(
                                        gift: gift,
                                        isEditable: true,
                                      ),
                                    ),
                                  );
                                },
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
        onPressed: () {
          // Navigate to GiftDetailsView for adding a new gift
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GiftDetailsView(
                gift: Gift(
                  name: '',
                  category: '',
                  status: 'Available',
                  price: 0.0,
                  description: '',
                ),
                isEditable: true,
              ),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
