import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Analytics'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('userdata').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<String> cartItems = [];
          Map<String, int> itemCounter = {};

          // Iterate over the documents in the collection
          for (var doc in snapshot.data!.docs) {
            if (doc.exists) {
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

              // Check if the document contains a 'cart' field
              if (data != null && data.containsKey('cart')) {
                List<dynamic> cart = data['cart'];

                // Iterate over the cart items in the document
                for (var item in cart) {
                  String itemName = item['name'];
                  if (itemCounter.containsKey(itemName)) {
                    itemCounter[itemName] = itemCounter[itemName]! + 1;
                  } else {
                    itemCounter[itemName] = 1;
                  }
                }
              }
            }
          }

          // Sort the items based on count
          var sortedItems = itemCounter.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Extract the top 5 items
          List<String> topItems = [];
          for (var i = 0; i < sortedItems.length && i < 5; i++) {
            topItems.add(sortedItems[i].key);
          }

          if (topItems.isEmpty) {
            return Center(child: Text('No cart items found.'));
          }

          return ListView.builder(
            itemCount: topItems.length,
            itemBuilder: (context, index) {
              // Display top 5 cart item names in the list
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    topItems[index],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Count: ${itemCounter[topItems[index]]}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
