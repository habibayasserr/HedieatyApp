import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';
import 'friend_gift_details_view.dart';

class FriendGiftListView extends StatefulWidget {
  final String friendId; // Friend's user ID
  final String eventId; // Event ID

  const FriendGiftListView({
    Key? key,
    required this.friendId,
    required this.eventId,
  }) : super(key: key);

  @override
  _FriendGiftListViewState createState() => _FriendGiftListViewState();
}

class _FriendGiftListViewState extends State<FriendGiftListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedSortOption = 'Sort by Name (Ascending)';

  Stream<List<Gift>> _fetchGifts() {
    return _firestore
        .collection('users')
        .doc(widget.friendId)
        .collection('events')
        .doc(widget.eventId)
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

  Future<void> _updateGiftStatus(Gift gift, String newStatus) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update gift status in Firestore
      await firestore
          .collection('users')
          .doc(widget.friendId)
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(gift.id)
          .update({'status': newStatus});

      // Add a notification to the friend's notifications collection
      final notificationMessage = 'Your ${gift.name} has been $newStatus.';
      await firestore
          .collection('users')
          .doc(widget.friendId)
          .collection('notifications')
          .add({
        'giftName': gift.name,
        'action': newStatus, // "Pledged", "Unpledged", or "Purchased"
        'timestamp': FieldValue.serverTimestamp(),
        'message': notificationMessage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift status updated to $newStatus')),
      );
    } catch (e) {
      print('Error updating gift status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update gift status.')),
      );
    }
  }

  Future<void> _confirmUnpledge(Gift gift) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key('unpledge_dialog'),
          title: const Text('Unpledge Gift'),
          content: const Text('Are you sure you want to unpledge this gift?'),
          actions: [
            TextButton(
              key: Key('unpledge_dialog_content'),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('unpledge_confirm_button'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Unpledge'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Update gift status to "Available"
        await firestore
            .collection('users')
            .doc(widget.friendId)
            .collection('events')
            .doc(widget.eventId)
            .collection('gifts')
            .doc(gift.id)
            .update({'status': 'Available'});

        // Add a notification to the friend's notifications collection
        final notificationMessage = 'Your ${gift.name} has been unpledged.';
        await firestore
            .collection('users')
            .doc(widget.friendId)
            .collection('notifications')
            .add({
          'giftName': gift.name,
          'action': 'Unpledged',
          'timestamp': FieldValue.serverTimestamp(),
          'message': notificationMessage,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift status updated to Available')),
        );
      } catch (e) {
        print('Error updating gift status: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update gift status.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('friend_gift_list_scaffold'),
      appBar: AppBar(
        key: const Key('friend_gift_list_app_bar'),
        title: const Text('Gift List', key: Key('gift_list_title')),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        key: const Key('gift_list_body'),
        children: [
          // Sorting Dropdown
          Padding(
            key: const Key('gift_list_sorting_dropdown'),
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              key: const Key('gift_list_sort_dropdown_button'),
              value: selectedSortOption,
              items: [
                'Sort by Name (Ascending)',
                'Sort by Name (Descending)',
                'Sort by Category',
                'Sort by Status',
              ].map((sortOption) {
                return DropdownMenuItem(
                  value: sortOption,
                  child:
                      Text(sortOption, key: Key('dropdown_item_$sortOption')),
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
          Expanded(
            child: StreamBuilder<List<Gift>>(
              key: const Key('gift_list_stream_builder'),
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
                _sortGifts(gifts); // Apply sorting

                return ListView.builder(
                  key: const Key('gift_list_view'),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    final Color cardColor = gift.status == 'Purchased'
                        ? Colors.red[100]!
                        : gift.status == 'Pledged'
                            ? Colors.green[100]!
                            : Colors.white;

                    return Card(
                      key: Key('gift_card_$index'),
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        key: Key('gift_tile_$index'),
                        title: Text(
                          gift.name,
                          key: Key('gift_name_$index'),
                        ),
                        subtitle: Text(
                          'Category: ${gift.category}',
                          key: Key('gift_category_$index'),
                        ),
                        onTap: () {
                          // Navigate to FriendGiftDetailsView
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendGiftDetailsView(gift: gift),
                            ),
                          );
                        },
                        trailing: Row(
                          key: Key('gift_action_row_$index'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (gift.status == 'Available')
                              TextButton(
                                key: Key('pledge_button_$index'),
                                onPressed: () {
                                  _updateGiftStatus(gift, 'Pledged');
                                },
                                child: const Text('Pledge'),
                              ),
                            if (gift.status == 'Pledged')
                              TextButton(
                                key: Key('unpledge_button_$index'),
                                onPressed: () {
                                  _confirmUnpledge(gift);
                                },
                                child: const Text('Unpledge'),
                              ),
                            if (gift.status != 'Purchased')
                              TextButton(
                                key: Key('purchase_button_$index'),
                                onPressed: () {
                                  _updateGiftStatus(gift, 'Purchased');
                                },
                                child: const Text('Purchase'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
