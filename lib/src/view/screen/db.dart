import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FirestoreExample(),
    );
  }
}

class FirestoreExample extends StatefulWidget {
  @override
  _FirestoreExampleState createState() => _FirestoreExampleState();
}

class _FirestoreExampleState extends State<FirestoreExample> {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('userdata');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _addProduct();
          },
          child: Text('Add Product'),
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Retrieve user data from the 'users' collection
        QuerySnapshot userSnapshot =
            await usersCollection.where('email', isEqualTo: user.email).get();
        if (userSnapshot.docs.isNotEmpty) {
          String userId = userSnapshot.docs.first.id;
          Map<String, dynamic> userData =
              userSnapshot.docs.first.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> favoriteItems = [];

          for (var product in controller.filteredProducts) {
            if (product.isFavorite) {
              favoriteItems.add({
                'name': product.name,
                'price': product.price,
                // Add other properties as needed
              });
            }
          }

          List<Map<String, dynamic>> cartProductsData = [];

          // Iterate over cartProducts and add each one to Firestore
          for (var product in controller.cartProducts) {
            cartProductsData.add({
              'name': product.name,
              'price': product.price,
              // Add other properties as needed
            });
          }

          // Add favorite items to the 'products' collection
          for (var product in controller.filteredProducts) {
            if (product.isFavorite) {
              await productsCollection.add({
                'userId': userId,
                'email': user.email,
                'username': userData['username'],
                'isFavorite': favoriteItems,
                'cart': cartProductsData,
              });
            }
          }

          print('Product added successfully!');
        } else {
          print('User not found!');
        }
      } else {
        print('User not logged in!');
      }
    } catch (e) {
      print('Error adding product: $e');
    }
  }
}
