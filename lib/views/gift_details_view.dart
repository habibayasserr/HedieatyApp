import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import 'dart:io';

class GiftDetailsView extends StatelessWidget {
  final Gift gift;
  const GiftDetailsView({Key? key, required this.gift}) : super(key: key);

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
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: gift.imagePath != null
                  ? Image.file(File(gift.imagePath!), fit: BoxFit.cover)
                  : const Center(child: Text('No Image Available')),
            ),
            const SizedBox(height: 20),

            // Gift Name
            const Text(
              'Gift Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            IgnorePointer(
              ignoring: true,
              child: TextField(
                controller: TextEditingController(text: gift.name),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Gift Category
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            IgnorePointer(
              ignoring: true,
              child: TextField(
                controller: TextEditingController(text: gift.category),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Gift Price
            const Text(
              'Price (EGP)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            IgnorePointer(
              ignoring: true,
              child: TextField(
                controller: TextEditingController(
                    text: '${gift.price.toStringAsFixed(2)} EGP'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Gift Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            IgnorePointer(
              ignoring: true,
              child: TextField(
                controller: TextEditingController(text: gift.description),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 20),

            // Gift Status
            const Text(
              'Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: gift.status == 'Pledged'
                    ? Colors.red[100]
                    : Colors.green[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  gift.status == 'Pledged' ? 'Pledged' : 'Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: gift.status == 'Pledged' ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
