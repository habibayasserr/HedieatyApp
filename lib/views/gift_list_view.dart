import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import '../widgets/custom_header.dart';
import 'gift_details_view.dart';

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
      case 'Sort by Price (Low to High)':
        gifts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Sort by Price (High to Low)':
        gifts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Sort by Category':
        gifts.sort((a, b) => a.category.compareTo(b.category));
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
                'Sort by Name (Ascending)',
                'Sort by Name (Descending)',
                'Sort by Price (Low to High)',
                'Sort by Price (High to Low)',
                'Sort by Category',
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${gift.category}'),
                        Text(
                          'Price: ${gift.price.toStringAsFixed(2)} EGP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftDetailsView(gift: gift),
                        ),
                      );
                    },
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
