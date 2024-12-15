import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/gift_model.dart';

class GiftDetailsView extends StatefulWidget {
  final Gift gift;

  const GiftDetailsView({Key? key, required this.gift}) : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  bool isEditing = false;
  File? _giftImage; // Stores the selected gift image
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.gift.name);
    categoryController = TextEditingController(text: widget.gift.category);
    priceController = TextEditingController(text: widget.gift.price.toString());
    descriptionController =
        TextEditingController(text: widget.gift.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // Gallery picker

    if (pickedFile != null) {
      setState(() {
        _giftImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                // Save changes
                if (widget.gift.status == 'Pledged') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot edit a pledged gift.'),
                    ),
                  );
                  setState(() {
                    isEditing = false; // Exit editing mode
                  });
                  return;
                }

                setState(() {
                  widget.gift.name = nameController.text;
                  widget.gift.category = categoryController.text;
                  widget.gift.price = double.tryParse(priceController.text) ??
                      widget.gift.price;
                  widget.gift.description = descriptionController.text;
                  widget.gift.status = widget.gift.status; // Keep status
                });
              }
              setState(() {
                isEditing = !isEditing; // Toggle editing mode
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display or upload gift image
            GestureDetector(
              onTap: isEditing
                  ? _pickImage
                  : null, // Allow image picking only in editing mode
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _giftImage != null
                    ? Image.file(
                        _giftImage!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text('Tap to upload an image'),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Gift name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Gift Name'),
              enabled: isEditing,
            ),
            const SizedBox(height: 10),

            // Gift category
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              enabled: isEditing,
            ),
            const SizedBox(height: 10),

            // Gift price
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price (EGP)'),
              keyboardType: TextInputType.number,
              enabled: isEditing,
            ),
            const SizedBox(height: 10),

            // Gift description
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              enabled: isEditing,
            ),
            const SizedBox(height: 20),

            // Toggle status between Available and Pledged
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 10),
                if (isEditing)
                  Switch(
                    value: widget.gift.status == 'Pledged',
                    onChanged: (value) {
                      if (isEditing) {
                        setState(() {
                          widget.gift.status = value ? 'Pledged' : 'Available';
                        });
                      }
                    },
                  )
                else
                  Text(
                    widget.gift.status,
                    style: TextStyle(
                      color: widget.gift.status == 'Pledged'
                          ? Colors.green
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
