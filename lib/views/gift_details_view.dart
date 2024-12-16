import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import 'dart:io';

class GiftDetailsView extends StatefulWidget {
  final Gift gift;
  const GiftDetailsView({Key? key, required this.gift}) : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  late String status; // Status of the gift
  bool isEditable = false; // Determines if fields can be edited
  String? imagePath; // Holds the image path

  @override
  void initState() {
    super.initState();
    status = widget.gift.status; // Initialize with gift status
    imagePath = widget.gift.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gift Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePath != null
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : const Center(child: Text('No Image Available')),
            ),
            const SizedBox(height: 20),
            // Gift Name
            TextField(
              enabled: isEditable, // Disable editing when read-only
              controller: TextEditingController(text: widget.gift.name),
              decoration: const InputDecoration(labelText: 'Gift Name'),
            ),
            const SizedBox(height: 10),
            // Gift Category
            TextField(
              enabled: isEditable,
              controller: TextEditingController(text: widget.gift.category),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            // Gift Price
            TextField(
              enabled: isEditable,
              controller: TextEditingController(
                  text: widget.gift.price.toStringAsFixed(2)),
              decoration: const InputDecoration(labelText: 'Price (EGP)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // Gift Description
            TextField(
              enabled: isEditable,
              controller: TextEditingController(text: widget.gift.description),
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            // Status Toggle (Available <-> Pledged)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: status == 'Pledged',
                  onChanged: (value) {
                    setState(() {
                      if (status == 'Pledged') return; // Restrict modification
                      status = value ? 'Pledged' : 'Available';
                    });
                  },
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.grey,
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: status == 'Pledged' ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Save Changes Button
            if (isEditable)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (status == 'Pledged') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot modify pledged gifts!'),
                        ),
                      );
                      return;
                    }
                    // Logic to save updated gift details
                    Navigator.pop(context, 'save');
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Save Changes'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
