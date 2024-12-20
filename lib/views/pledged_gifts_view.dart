import 'package:flutter/material.dart';

class MyPledgedGiftsView extends StatefulWidget {
  const MyPledgedGiftsView({Key? key}) : super(key: key);

  @override
  _MyPledgedGiftsViewState createState() => _MyPledgedGiftsViewState();
}

class _MyPledgedGiftsViewState extends State<MyPledgedGiftsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Purchased'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Placeholder for Pending Gifts
          Center(
            child: const Text('Pending Gifts will be displayed here.'),
          ),
          // Placeholder for Purchased Gifts
          Center(
            child: const Text('Purchased Gifts will be displayed here.'),
          ),
        ],
      ),
    );
  }
}
