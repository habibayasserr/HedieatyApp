import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PledgedGiftsView extends StatelessWidget {
  const PledgedGiftsView({Key? key}) : super(key: key);

  Stream<List<Map<String, dynamic>>> _fetchPledgedGifts() async* {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await for (final snapshot in firestore
        .collectionGroup('gifts') // Searches all 'gifts' subcollections
        .where('status', whereIn: ['Pledged', 'Purchased']) // Filter by status
        .snapshots()) {
      final List<Map<String, dynamic>> giftList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unnamed Gift',
          'status': data['status'] ?? 'Unknown',
          'friendName': data['friendName'] ?? 'Unknown Friend',
          'dueDate': data['dueDate'] is Timestamp
              ? (data['dueDate'] as Timestamp).toDate().toLocal()
              : null,
        };
      }).toList();
      yield giftList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pledged_gifts_scaffold'),
      appBar: AppBar(
        key: const Key('pledged_gifts_app_bar'),
        title: const Text(
          'My Pledged Gifts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005F73),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        key: const Key('pledged_gifts_stream_builder'),
        stream: _fetchPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              key: Key('pledged_gifts_loading'),
              child: CircularProgressIndicator(color: Color(0xFF005F73)),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              key: Key('pledged_gifts_error'),
              child: Text(
                'Error fetching pledged gifts.',
                style: TextStyle(color: Color(0xFFEF0F72)),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              key: Key('pledged_gifts_empty'),
              child: Text(
                'No pledged gifts found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final gifts = snapshot.data!;
          return ListView.builder(
            key: const Key('pledged_gifts_list_view'),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              final dueDate = gift['dueDate'] != null
                  ? (gift['dueDate'] as DateTime).toString().split(' ')[0]
                  : 'No due date';

              return Card(
                key: Key('pledged_gift_card_$index'),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFF005F73), width: 2),
                ),
                elevation: 2,
                color: gift['status'] == 'Pledged'
                    ? Colors.green[100]
                    : Colors.red[100],
                child: ListTile(
                  title: Text(
                    gift['name'],
                    key: Key('pledged_gift_name_$index'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005F73),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Friend: ${gift['friendName']}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Due Date: $dueDate',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Text(
                    gift['status'],
                    style: TextStyle(
                      color: gift['status'] == 'Pledged'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
