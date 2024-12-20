import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/gift_model.dart';

class FriendGiftDetailsView extends StatelessWidget {
  final Gift gift;

  const FriendGiftDetailsView({
    Key? key,
    required this.gift,
  }) : super(key: key);

  Widget _buildGiftImage(String? imageBase64) {
    if (imageBase64 != null) {
      final imageBytes = base64Decode(imageBase64);
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } else {
      return const Center(child: Text('No image available'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                child: _buildGiftImage(gift.imageBase64),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gift Name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                gift.name,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                gift.category,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Price (EGP)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${gift.price.toStringAsFixed(2)} EGP',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Description',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                gift.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (gift.status == 'Purchased') ...[
                Text(
                  'Purchased',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 16,
                        color: gift.status == 'Available'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    Switch(
                      value: gift.status == 'Pledged',
                      onChanged: null, // Read-only
                      activeColor: Colors.orange,
                    ),
                    Text(
                      'Pledged',
                      style: TextStyle(
                        fontSize: 16,
                        color: gift.status == 'Pledged'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
