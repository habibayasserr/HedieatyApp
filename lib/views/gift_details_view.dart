import 'package:flutter/material.dart';
import '../models/gift_model.dart';

class GiftDetailsView extends StatefulWidget {
  final Gift gift;

  const GiftDetailsView({Key? key, required this.gift}) : super(key: key);

  @override
  _GiftDetailsViewState createState() => _GiftDetailsViewState();
}

class _GiftDetailsViewState extends State<GiftDetailsView> {
  bool isEditing = false; // Control editing state

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with gift details
    nameController = TextEditingController(text: widget.gift.name);
    categoryController = TextEditingController(text: widget.gift.category);
    priceController = TextEditingController(text: widget.gift.price.toString());
    descriptionController =
        TextEditingController(text: widget.gift.description);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
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
        title: const Text('Gift Details'),
        backgroundColor: Colors.orange,
        actions: [
          if (widget.gift.status ==
              'Available') // Show edit button if applicable
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  // Save changes when editing is done
                  setState(() {
                    widget.gift.name = nameController.text;
                    widget.gift.category = categoryController.text;
                    widget.gift.price = double.tryParse(priceController.text) ??
                        widget.gift.price;
                    widget.gift.description = descriptionController.text;
                  });
                }
                setState(() {
                  isEditing = !isEditing; // Toggle editing state
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
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Gift Name'),
              enabled: isEditing, // Editable only in editing mode
            ),
            const SizedBox(height: 10),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              enabled: isEditing, // Editable only in editing mode
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price (EGP)'),
              keyboardType: TextInputType.number,
              enabled: isEditing, // Editable only in editing mode
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              enabled: isEditing, // Editable only in editing mode
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Status: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  widget.gift.status,
                  style: TextStyle(
                    color: widget.gift.status == 'Purchased'
                        ? Colors.red
                        : widget.gift.status == 'Pledged'
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
