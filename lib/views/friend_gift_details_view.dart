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
      key: const Key('gift_details_scaffold'),
      appBar: AppBar(
        key: const Key('gift_details_app_bar'),
        title: const Text(
          'Gift Details',
          key: Key('gift_details_title'),
        ),
        backgroundColor: const Color(0xFFe5f8ff),
      ),
      body: Padding(
        key: const Key('gift_details_body'),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          key: const Key('gift_details_scroll_view'),
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
              Container(
                key: const Key('gift_image_container'),
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF005F73), // Start with a darker blue
                      const Color(0xFF98C1D9), // Gradient to a lighter blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                      color: const Color(0xFF005F73),
                      width: 2), // Consistent border with theme
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildGiftImage(gift.imageBase64),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gift Name',
                key: Key('gift_name_title'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                gift.name,
                key: const Key('gift_name'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Category',
                key: Key('gift_category_title'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                gift.category,
                key: const Key('gift_category'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Price (EGP)',
                key: Key('gift_price_title'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${gift.price.toStringAsFixed(2)} EGP',
                key: const Key('gift_price'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Description',
                key: Key('gift_description_title'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                gift.description,
                key: const Key('gift_description'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status',
                key: Key('gift_status_title'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (gift.status == 'Purchased') ...[
                Text(
                  'Purchased',
                  key: const Key('gift_status_purchased'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFf0207c),
                  ),
                ),
              ] else ...[
                Row(
                  key: const Key('gift_status_row'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Available',
                      key: const Key('gift_status_available'),
                      style: TextStyle(
                        fontSize: 16,
                        color: gift.status == 'Available'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    Switch(
                      key: const Key('gift_status_switch'),
                      value: gift.status == 'Pledged',
                      onChanged: null, // Read-only
                      activeColor: const Color(0xFFf0207c),
                    ),
                    Text(
                      'Pledged',
                      key: const Key('gift_status_pledged'),
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
