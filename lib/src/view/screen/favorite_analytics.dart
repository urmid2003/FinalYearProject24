import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Items'),
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
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favorite items found.'));
          }

          List<String> favoriteItems = [];
          Map<String, int> itemCounter = {};

          for (var doc in snapshot.data!.docs) {
            if (doc.exists) {
              Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
              if (data != null && data.containsKey('isFavorite')) {
                List<dynamic> favorites = data['isFavorite'];
                if (favorites.isNotEmpty) {
                  // Count the occurrences of each favorite item
                  for (var item in favorites) {
                    String itemName = item.toString();
                    if (itemCounter.containsKey(itemName)) {
                      itemCounter[itemName] = itemCounter[itemName]! + 1;
                    } else {
                      itemCounter[itemName] = 1;
                    }
                  }
                }
              }
            }
          }

          // Sort the items based on count
          var sortedItems = itemCounter.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Extract the top 3 items
          List<String> topItems = [];
          for (var i = 0; i < sortedItems.length && i < 3; i++) {
            topItems.add(sortedItems[i].key);
          }

          if (topItems.isEmpty) {
            return Center(child: Text('No favorite items found.'));
          }

          return ListView.builder(
            itemCount: topItems.length,
            itemBuilder: (context, index) {
              // Display top favorite item names in the list
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ListTile(
                  title: Text(
                    topItems[index],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
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
