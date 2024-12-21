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
      key: const Key('gift_list_scaffold'),
      appBar: AppBar(
        key: const Key('gift_list_app_bar'),
        title: Text(
          widget.event.name,
          key: const Key('gift_list_title'),
        ),
        backgroundColor: const Color(0xFFe5f8ff),
      ),
      body: Column(
        key: const Key('gift_list_body'),
        children: [
          // Sorting Dropdown

          Padding(
            key: const Key('gift_list_sorting_dropdown'),
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0XFFFDE9F2), // Light pink background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF005F73), // Darker blue border
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  key: const Key('gift_sort_dropdown'),
                  value: selectedSortOption,
                  items: [
                    'Sort by Name (Ascending)',
                    'Sort by Name (Descending)',
                    'Sort by Category',
                    'Sort by Status',
                  ].map((sortOption) {
                    return DropdownMenuItem(
                      value: sortOption,
                      child: Text(
                        sortOption,
                        key: Key('sort_option_$sortOption'),
                        style: const TextStyle(
                          color: Color(0xFF005F73), // Darker blue text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                  dropdownColor:
                      const Color(0XFFFDE9F2), // Dropdown background color
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF005F73),
                    size: 36, // Darker blue icon
                  ),
                ),
              ),
            ),
          ),

          // Gifts List
          Expanded(
            key: const Key('gift_list_stream_builder'),
            child: StreamBuilder<List<Gift>>(
              stream: _fetchGifts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    key: Key('gift_list_loading'),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    key: Key('gift_list_error'),
                    child: Text('Error fetching gifts.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    key: Key('gift_list_empty'),
                    child: Text('No gifts found.'),
                  );
                }

                final gifts = snapshot.data!;
                _sortGifts(gifts);

                return ListView.builder(
                  key: const Key('gift_list_view'),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    return Card(
                      key: Key('gift_card_$index'),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: const Color(0xFF005F73),
                            width: 2), // Blue outline
                      ),
                      child: ListTile(
                        key: Key('gift_tile_$index'),
                        title: Text(
                          gift.name,
                          key: Key('gift_name_$index'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005F73), // Blue text
                          ),
                        ),
                        subtitle: Text(
                          'Category: ${gift.category}\nPrice: ${gift.price.toStringAsFixed(2)} EGP',
                          key: Key('gift_details_$index'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
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
                                key: Key('gift_actions_$index'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    key: Key('edit_gift_$index'),
                                    icon: const Icon(Icons.edit,
                                        color: Color(0xFF005F73)),
                                    onPressed: () {
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
                                    key: Key('delete_gift_$index'),
                                    icon: const Icon(Icons.delete,
                                        color: Color(0xFFEF0F72)),
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
                            : null,
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
        key: const Key('add_gift_fab'),
        onPressed: () {
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
                eventId: widget.event.id!,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFEF0F72),
        child: const Icon(Icons.add),
      ),
    );
  }
}
