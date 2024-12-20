import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PledgedGiftsView extends StatelessWidget {
  const PledgedGiftsView({Key? key}) : super(key: key);

  Stream<List<Map<String, dynamic>>> _fetchPledgedGifts() async* {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await for (final snapshot in firestore
        .collection('gifts') // Search across all gifts collections
        .where('status', whereIn: ['Pending', 'Purchased']) // Filter by status
        .snapshots()) {
      final List<Map<String, dynamic>> giftList = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final eventRef = doc.reference.parent.parent;
        final friendRef = eventRef?.parent?.parent;

        final eventData = await eventRef?.get();
        final friendData = await friendRef?.get();

        giftList.add({
          'id': doc.id,
          'name': data['name'],
          'status': data['status'],
          'friendName': friendData?.get('name') ?? 'Unknown',
          'dueDate':
              eventData?.get('date')?.toDate().toIso8601String() ?? 'Unknown',
          ...data,
        });
      }

      yield giftList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('pledged_gifts_scaffold'),
      appBar: AppBar(
        key: const Key('pledged_gifts_app_bar'),
        title: const Text('My Pledged Gifts'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        key: const Key('pledged_gifts_stream_builder'),
        stream: _fetchPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              key: Key('pledged_gifts_loading'),
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              key: Key('pledged_gifts_error'),
              child: Text('Error fetching pledged gifts.'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              key: Key('pledged_gifts_empty'),
              child: Text('No pledged gifts.'),
            );
          }

          final gifts = snapshot.data!;
          return ListView.builder(
            key: const Key('pledged_gifts_list_view'),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return Card(
                key: Key('pledged_gift_card_$index'),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: gift['status'] == 'Pending'
                    ? Colors.green[100]
                    : Colors.red[100],
                child: ListTile(
                  key: Key('pledged_gift_tile_$index'),
                  title: Text(
                    gift['name'],
                    key: Key('pledged_gift_name_$index'),
                  ),
                  subtitle: Column(
                    key: Key('pledged_gift_details_$index'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Friend: ${gift['friendName']}'),
                      Text('Due Date: ${gift['dueDate']}'),
                    ],
                  ),
                  trailing: Text(
                    gift['status'],
                    key: Key('pledged_gift_status_$index'),
                  ),
                  onTap: () {
                    // Navigate to gift details if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
