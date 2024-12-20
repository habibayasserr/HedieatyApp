import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gift_model.dart';

class GiftDetailsView extends StatefulWidget {
  final Gift? gift; // Nullable for new gift addition
  final bool isEditable;
  final String eventId; // Event ID passed to the view

  const GiftDetailsView({
    Key? key,
    this.gift,
    this.isEditable = false,
    required this.eventId,
  }) : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? imagePath; // Local file path
  String? imageBase64; // Base64-encoded string
  bool _isPickerActive = false;
  bool isAvailable = true; // Default to Available

  final List<String> categories = [
    'Electronics',
    'Books',
    'Toys',
    'Clothing',
    'Accessories',
  ]; // Example categories

  late String status;

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      nameController.text = widget.gift!.name;
      selectedCategory = widget.gift!.category.isNotEmpty &&
              categories.contains(widget.gift!.category)
          ? widget.gift!.category
          : categories.first; // Validate category
      priceController.text = widget.gift!.price.toStringAsFixed(2);
      descriptionController.text = widget.gift!.description;
      status = widget.gift!.status;
      isAvailable = status == 'Available'; // Set toggle based on status
      imageBase64 = widget.gift!.imageBase64; // Use Base64 if available
    } else {
      selectedCategory = categories.first; // Default category
      status = 'Available'; // Default status
      isAvailable = true; // Default toggle
    }
  }

  Future<void> _pickImage() async {
    if (_isPickerActive) return; // Prevent multiple triggers
    setState(() {
      _isPickerActive = true;
    });

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          imagePath = pickedFile.path;
          imageBase64 = base64Encode(bytes); // Convert to Base64
        });
      }
    } catch (e) {
      print('Image Picker Error: $e');
    } finally {
      setState(() {
        _isPickerActive = false;
      });
    }
  }

  Future<void> _saveGift() async {
    final String name = nameController.text.trim();
    final String category = selectedCategory ?? '';
    final String description = descriptionController.text.trim();
    final double? price = double.tryParse(priceController.text.trim());

    if (name.isEmpty ||
        category.isEmpty ||
        description.isEmpty ||
        price == null ||
        imageBase64 == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('All fields, including an image, are required.')),
        );
      }
      return;
    }

    final Map<String, dynamic> giftData = {
      'name': name,
      'category': category,
      'status': status, // Include status from toggle
      'price': price,
      'description': description,
      'imageBase64': imageBase64, // Store Base64 string
    };

    try {
      if (widget.gift?.id == null) {
        // Add new gift
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('events')
            .doc(widget.eventId)
            .collection('gifts')
            .add(giftData);
      } else {
        // Update existing gift
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('events')
            .doc(widget.eventId)
            .collection('gifts')
            .doc(widget.gift!.id)
            .update(giftData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift saved successfully!')),
        );
      }

      if (mounted) {
        Navigator.pop(context); // Close the page only if still mounted
      }
    } catch (e) {
      print('Error saving gift: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save gift.')),
        );
      }
    }

    @override
    void dispose() {
      nameController.dispose();
      priceController.dispose();
      descriptionController.dispose();
      super.dispose();
    }
  }

  Widget _buildGiftImage() {
    if (imageBase64 != null) {
      // Decode and display Base64 image
      final imageBytes = base64Decode(imageBase64!);
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } else if (imagePath != null) {
      // Display selected image
      return Image.file(File(imagePath!), fit: BoxFit.cover);
    } else {
      return const Center(child: Text('No image available'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('gift_details_scaffold'),
      appBar: AppBar(
        key: const Key('gift_details_app_bar'),
        title: Text(
          widget.gift == null ? 'Add Gift' : 'Edit Gift',
          key: const Key('gift_details_title'),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        key: const Key('gift_details_scroll_view'),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          key: const Key('gift_details_column'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gift Image',
              key: Key('gift_image_title'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              key: const Key('gift_image_gesture_detector'),
              onTap: widget.isEditable ? _pickImage : null,
              child: Container(
                key: const Key('gift_image_container'),
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildGiftImage(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gift Name',
              key: Key('gift_name_title'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              key: const Key('gift_name_text_field'),
              controller: nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const Text(
              'Category',
              key: Key('gift_category_title'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              key: const Key('gift_category_dropdown'),
              value: categories.contains(selectedCategory)
                  ? selectedCategory
                  : null,
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, key: Key('category_$category')),
                      ))
                  .toList(),
              onChanged: widget.isEditable
                  ? (value) => setState(() => selectedCategory = value)
                  : null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            const Text(
              'Price (EGP)',
              key: Key('gift_price_title'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              key: const Key('gift_price_text_field'),
              controller: priceController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const Text(
              'Description',
              key: Key('gift_description_title'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextField(
              key: const Key('gift_description_text_field'),
              controller: descriptionController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Status',
              key: Key('gift_status_title'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              key: const Key('gift_status_row'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Available',
                  key: const Key('gift_status_available'),
                  style: TextStyle(
                    fontSize: 16,
                    color: isAvailable ? Colors.green : Colors.grey,
                  ),
                ),
                Switch(
                  key: const Key('gift_status_switch'),
                  value: isAvailable,
                  onChanged: widget.isEditable
                      ? (value) {
                          setState(() {
                            isAvailable = value;
                            status = isAvailable ? 'Available' : 'Pledged';
                          });
                        }
                      : null,
                  activeColor: Colors.orange,
                ),
                Text(
                  'Pledged',
                  key: const Key('gift_status_pledged'),
                  style: TextStyle(
                    fontSize: 16,
                    color: !isAvailable ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.isEditable)
              Center(
                child: ElevatedButton(
                  key: const Key('save_changes_button'),
                  onPressed: _saveGift,
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
