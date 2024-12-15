import 'package:flutter/material.dart';
import '../models/gift_model.dart';

class GiftDetailsView extends StatefulWidget {
  final Gift? gift;

  const GiftDetailsView({Key? key, this.gift}) : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedCategory = 'Electronics'; // Default category
  bool isAvailable = true; // Default status

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      nameController.text = widget.gift!.name;
      priceController.text = widget.gift!.price.toString();
      descriptionController.text = widget.gift!.description;
      selectedCategory = widget.gift!.category;
      isAvailable = widget.gift!.status == 'Available';
    }
  }

  void _saveGift() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final description = descriptionController.text.trim();

    if (name.isEmpty || price == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields correctly'),
        ),
      );
      return;
    }

    // Return the new/updated gift data
    Navigator.pop(
      context,
      Gift(
        name: name,
        category: selectedCategory,
        status: isAvailable ? 'Available' : 'Pledged',
        price: price,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveGift,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Gift Name',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: [
                'Electronics',
                'Books',
                'Toys',
                'Clothing',
                'Other',
              ].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Status:'),
                const Spacer(),
                Text(
                  isAvailable ? 'Available' : 'Pledged',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
