import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
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
      price: 150.0,
      description: 'A modern smartwatch with various health features.',
    ),
    Gift(
      name: 'Cookbook',
      category: 'Books',
      status: 'Pledged',
      price: 20.0,
      description: 'A comprehensive cookbook with recipes for beginners.',
    ),
  ];

  Future<void> _navigateToGiftDetails({Gift? gift, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsView(gift: gift),
      ),
    );

    if (result != null && result is Gift) {
      setState(() {
        if (gift == null) {
          gifts.add(result); // Add new gift
        } else {
          gifts[index!] = result; // Update existing gift
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: widget.event.name,
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        onNotificationTap: () {
          // Handle notification
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(gift.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${gift.category}'),
                        Text('Price: \$${gift.price.toStringAsFixed(2)}'),
                        Text(
                          'Status: ${gift.status}',
                          style: TextStyle(
                            color: gift.status == 'Available'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text('Description: ${gift.description}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (gift.status == 'Available')
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToGiftDetails(
                                gift: gift, index: index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToGiftDetails(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
