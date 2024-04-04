import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:glitzproject/core/app_data.dart';
import 'package:glitzproject/core/app_color.dart';
import 'package:glitzproject/src/controller/product_controller.dart';
import 'package:glitzproject/src/view/screen/db.dart';
import 'package:glitzproject/src/view/widget/product_grid_view.dart';
import 'package:glitzproject/src/view/widget/list_item_selector.dart';


final ProductController controller = ProductController();

enum AppbarActionType { leading, trailing }

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  Widget appBarActionButton(AppbarActionType type) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.lightGrey,
      ),
      child: IconButton(
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        onPressed: () {
          Get.to(() => MyApp());
        },
        icon: const Icon(Icons.search, color: Colors.black),
      ),
    );
  }

  PreferredSize get _appBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(150),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appBarActionButton(AppbarActionType.leading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recommendedProductListView(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: AppData.recommendedProducts.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                color: AppData.recommendedProducts[index].cardBackgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Only Personalized Gifts',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await _addProduct();
                            await _addLoginActivity(); // Call the method to add product
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyApp()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppData.recommendedProducts[index]
                                .buttonBackgroundColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            "Only in Glitz",
                            style: TextStyle(
                              color: AppData
                                  .recommendedProducts[index].buttonTextColor!,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/shopping.png',
                    height: 125,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _topCategoriesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Top categories",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: AppColor.darkOrange),
            child: Text(
              "Categories",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.deepOrange.withOpacity(0.7)),
            ),
          )
        ],
      ),
    );
  }

  Widget _topCategoriesListView() {
    return ListItemSelector(
      categories: controller.categories,
      onItemPressed: (index) {
        controller.filterItemsByCategory(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.getAllItems();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      Map<String, dynamic>? userData = snapshot.data!.data() as Map<
                          String,
                          dynamic>?; // Cast the return value of data() to Map<String, dynamic> or null
                      if (userData != null &&
                          userData.containsKey('username')) {
                        String username = userData['username']
                            as String; // Access the 'username' field from the user data
                        return Text(
                          "Hello $username!",
                          style: Theme.of(context).textTheme.displayLarge,
                        );
                      }
                    }
                    return Text(
                      "Hello Guest!",
                      style: Theme.of(context).textTheme.displayLarge,
                    );
                  },
                ),
                Text(
                  "Lets gets somethings?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _recommendedProductListView(context),
                _topCategoriesHeader(context),
                _topCategoriesListView(),
                GetBuilder(builder: (ProductController controller) {
                  return ProductGridView(
                    items: controller.filteredProducts,
                    likeButtonPressed: (index) => controller.isFavorite(index),
                    isPriceOff: (product) => controller.isPriceOff(product),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Retrieve user data from the 'users' collection
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (userSnapshot.docs.isNotEmpty) {
          String userId = userSnapshot.docs.first.id;
          Map<String, dynamic> userData =
              userSnapshot.docs.first.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> favoriteItems = [];

          // Assuming you have access to 'controller.filteredProducts' and 'controller.cartProducts'
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
              await FirebaseFirestore.instance.collection('userdata').add({
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

  Future<void> _addLoginActivity() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get user ID and email from Firebase Authentication
        String userId = user.uid;
        String? email = user.email;

        // Add a new document to the "loginActivity" collection with current timestamp
        await FirebaseFirestore.instance.collection('loginActivity').add({
          'userId': userId,
          'email': email,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Login activity added successfully.');
      } else {
        print('No user signed in.');
      }
    } catch (e) {
      print('Error adding login activity: $e');
    }
  }
}
