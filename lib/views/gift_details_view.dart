import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GiftDetailsView extends StatefulWidget {
  final Gift? gift; // Nullable for new gift addition
  final bool isEditable;

  const GiftDetailsView({Key? key, this.gift, this.isEditable = false})
      : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late String status;
  String? imagePath;
  bool _isPickerActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      nameController.text = widget.gift!.name;
      categoryController.text = widget.gift!.category;
      priceController.text = widget.gift!.price.toStringAsFixed(2);
      descriptionController.text = widget.gift!.description;
      status = widget.gift!.status;
      imagePath = widget.gift!.imagePath;
    } else {
      status = 'Available'; // Default status for new gifts
    }
  }

  Future<void> _pickImage() async {
    if (_isPickerActive) return;
    _isPickerActive = true;

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Image Picker Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPickerActive = false;
        });
      }
    }
  }

  void _saveGift() {
    final String name = nameController.text.trim();
    final String category = categoryController.text.trim();
    final String description = descriptionController.text.trim();
    final double? price = double.tryParse(priceController.text.trim());

    if (name.isEmpty ||
        category.isEmpty ||
        description.isEmpty ||
        price == null ||
        imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required, including an image.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      Gift(
        name: name,
        category: category,
        status: status,
        price: price,
        description: description,
        imagePath: imagePath,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
        backgroundColor: Colors.orange,
      ),
      body: IgnorePointer(
        ignoring: !widget.isEditable,
        child: SingleChildScrollView(
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
                onTap: widget.isEditable ? _pickImage : null,
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
                controller: nameController,
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
                controller: categoryController,
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
                controller: priceController,
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
                controller: descriptionController,
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
                              status = value ? 'Pledged' : 'Available';
                            });
                          }
                        : null,
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
                    onPressed: _saveGift,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text('Save Changes'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
