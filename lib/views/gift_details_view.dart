import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GiftDetailsView extends StatefulWidget {
  final Gift gift;
  final bool isEditable; // Add this parameter to control edit mode

  const GiftDetailsView({Key? key, required this.gift, this.isEditable = false})
      : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  final ImagePicker _picker = ImagePicker();
  late String status; // Status of the gift
  String? imagePath; // Holds the image path
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    status = widget.gift.status; // Initialize with the gift's status
    imagePath = widget.gift.imagePath;
  }

  Future<void> _pickImage() async {
    if (_isPickerActive) return; // Prevent multiple calls
    setState(() {
      _isPickerActive = true;
    });

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      // Handle any errors gracefully
      print('Image Picker Error: $e');
    } finally {
      setState(() {
        _isPickerActive = false;
      });
    }
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
            // Gift Image
            const Text(
              'Gift Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: widget.isEditable
                  ? () async {
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imagePath = pickedFile.path; // Update the image path
                        });
                      }
                    }
                  : null, // Disable in non-editable mode
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imagePath != null
                    ? Image.file(File(imagePath!), fit: BoxFit.cover)
                    : const Center(child: Text('Tap to add an image')),
              ),
            ),

            const SizedBox(height: 20),

            // Gift Name
            const Text(
              'Gift Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              enabled: widget.isEditable,
              controller: TextEditingController(text: widget.gift.name),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Gift Category
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              enabled: widget.isEditable,
              controller: TextEditingController(text: widget.gift.category),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Gift Price
            const Text(
              'Price (EGP)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              enabled: widget.isEditable,
              controller: TextEditingController(
                  text: widget.gift.price.toStringAsFixed(2)),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),

            // Gift Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              enabled: widget.isEditable,
              controller: TextEditingController(text: widget.gift.description),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Gift Status Toggle
            const Text(
              'Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available / Pledged:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: status == 'Pledged',
                  onChanged: widget.isEditable
                      ? (value) {
                          setState(() {
                            if (status == 'Pledged')
                              return; // Restrict modification
                            status = value ? 'Pledged' : 'Available';
                          });
                        }
                      : null, // Disable toggle in read-only mode
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
            if (widget.isEditable)
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
