import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

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
      await _firestore
          .collection('users')
          .doc(widget.friendId)
          .collection('events')
          .doc(widget.eventId)
          .collection('gifts')
          .doc(gift.id)
          .update({'status': newStatus});

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
          title: const Text('Unpledge Gift'),
          content: const Text('Are you sure you want to unpledge this gift?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Unpledge'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _updateGiftStatus(gift, 'Available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
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
                _sortGifts(gifts); // Apply sorting

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
                        subtitle: Text('Category: ${gift.category}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (gift.status == 'Available')
                              TextButton(
                                onPressed: () {
                                  _updateGiftStatus(gift, 'Pledged');
                                },
                                child: const Text('Pledge'),
                              ),
                            if (gift.status == 'Pledged')
                              TextButton(
                                onPressed: () {
                                  _confirmUnpledge(gift);
                                },
                                child: const Text('Unpledge'),
                              ),
                            if (gift.status != 'Purchased')
                              TextButton(
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
