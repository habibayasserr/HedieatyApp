import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FirestoreTestView extends StatefulWidget {
  const FirestoreTestView({Key? key}) : super(key: key);

  @override
  _FirestoreTestViewState createState() => _FirestoreTestViewState();
}

class _FirestoreTestViewState extends State<FirestoreTestView> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _events = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (_userId == null) return;
    final events = await _firestoreService.getUserEvents(_userId!);
    setState(() {
      _events = events;
    });
  }

  Future<void> _addEvent() async {
    if (_userId == null) return;

    final eventData = {
      'name': _nameController.text,
      'date': _dateController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
    };

    await _firestoreService.addEvent(_userId!, eventData);
    _nameController.clear();
    _dateController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _fetchEvents();
  }

  Future<void> _deleteEvent(String eventId) async {
    if (_userId == null) return;
    await _firestoreService.deleteEvent(_userId!, eventId);
    _fetchEvents();
  }

  void _showEditDialog(Map<String, dynamic> event) {
    final TextEditingController nameController =
        TextEditingController(text: event['name']);
    final TextEditingController dateController =
        TextEditingController(text: event['date']);
    final TextEditingController locationController =
        TextEditingController(text: event['location']);
    final TextEditingController descriptionController =
        TextEditingController(text: event['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Event Date'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedEvent = {
                  'name': nameController.text,
                  'date': dateController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                };
                await _firestoreService.updateEvent(
                    _userId!, event['id'], updatedEvent);
                _fetchEvents();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                ),
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Event Date'),
                ),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addEvent,
                  child: const Text('Add Event'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  child: ListTile(
                    title: Text(event['name']),
                    subtitle: Text('${event['date']} - ${event['location']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDialog(event);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteEvent(event['id']);
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
