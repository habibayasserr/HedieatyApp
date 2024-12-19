import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import 'gift_details_view.dart';
import '../models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftListView extends StatefulWidget {
  final Event event;

  const GiftListView({Key? key, required this.event}) : super(key: key);

  @override
  _GiftListViewState createState() => _GiftListViewState();
}

class _GiftListViewState extends State<GiftListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  String selectedSortOption = 'Sort by Name (Ascending)';

  Stream<List<Gift>> _fetchGifts() {
    if (_userId == null) {
      return const Stream.empty(); // Handle null user case gracefully
    }
    return _firestore
        .collection('users')
        .doc(_userId) // Replace with actual user ID logic
        .collection('events')
        .doc(widget.event.id)
        .collection('gifts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Gift.fromJson(doc.data(), doc.id);
            }).toList());
  }

  void _sortGifts(List<Gift> gifts) {
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
                  });
                }
              },
              isExpanded: true,
            ),
          ),
          // Gifts List
          Expanded(
            child: StreamBuilder<List<Gift>>(
              stream: _fetchGifts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching gifts.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No gifts found.'));
                }

                final gifts = snapshot.data!;
                _sortGifts(gifts);

                return ListView.builder(
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
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                                eventId: widget.event.id!,
                              ),
                            ),
                          );
                        },
                        trailing: gift.status == 'Available'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      // Navigate to GiftDetailsView in editable mode
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GiftDetailsView(
                                            gift: gift,
                                            isEditable: true,
                                            eventId: widget.event.id!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      if (_userId == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('User not logged in')),
                                        );
                                        return;
                                      }
                                      await _firestore
                                          .collection('users')
                                          .doc(_userId)
                                          .collection('events')
                                          .doc(widget.event.id)
                                          .collection('gifts')
                                          .doc(gift.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              )
                            : null, // Hide Edit/Delete for non-available gifts
                      ),
                    );
                  },
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
                eventId: widget
                    .event.id!, // Pass the event ID to the GiftDetailsView
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
