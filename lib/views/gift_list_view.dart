import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../widgets/custom_header.dart';
import 'gift_details_view.dart';
import '../models/event_model.dart';

class GiftListView extends StatefulWidget {
  final Event event; // Pass the associated event

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

  String selectedSortOption = 'Sort by Name';

  void _sortGifts() {
    switch (selectedSortOption) {
      case 'Sort by Name':
        gifts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Sort by Category':
        gifts.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Sort by Price':
        gifts.sort((a, b) => a.price.compareTo(b.price));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: widget.event.name,
        onProfileTap: () {
          // Navigate to Profile
        },
        onNotificationTap: () {
          // Handle Notification
        },
      ),
      body: Column(
        children: [
          // Sorting Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedSortOption,
              items: [
                'Sort by Name',
                'Sort by Category',
                'Sort by Price',
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
          // Gift List
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                // Change card color based on gift status
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
                    subtitle: Text('Category: ${gift.category}'),
                    onTap: () {
                      // Navigate to Gift Details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftDetailsView(gift: gift),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (gift.status == 'Available')
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Navigate to Gift Details for Editing
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GiftDetailsView(gift: gift),
                                ),
                              );
                            },
                          ),
                        if (gift.status == 'Available')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                gifts.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
