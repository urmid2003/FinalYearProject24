import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glitzproject/core/app_data.dart';
import 'package:glitzproject/core/app_color.dart';
import 'package:glitzproject/src/controller/product_controller.dart';
import 'package:glitzproject/src/view/screen/db.dart';
import 'package:glitzproject/src/view/widget/product_grid_view.dart';
import 'package:glitzproject/src/view/widget/list_item_selector.dart';
import 'signin_screen.dart';

enum AppbarActionType { leading, trailing }

final ProductController controller = Get.put(ProductController());

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool isFavorite = false;

  void _addToFavorites(String productName, double productPrice, int index) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({
      'isFavorite': FieldValue.arrayUnion([{
        'name': productName,
        'price': productPrice,
      }]),
    });
  }

  void _removeFromFavorites(String productName, double productPrice, int index) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({
      'isFavorite': FieldValue.arrayRemove([{
        'name': productName,
        'price': productPrice,
      }]),
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.getAllItems();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.lightGrey,
            ),
            child: IconButton(
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
              onPressed: () {
                Get.to(() => MyApp());
              },
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
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
                      Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?; // Cast the return value of data() to Map<String, dynamic> or null
                      if (userData != null && userData.containsKey('username')){
                        String username = userData['username'] as String; // Access the 'username' field from the user data
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
                    likeButtonPressed: (index) {
                      final product = controller.filteredProducts[index];
                      if (product.isFavorite) {
                        _removeFromFavorites(product.name, product.price.toDouble(), index);
                      } else {
                        _addToFavorites(product.name, product.price.toDouble(), index);
                      }
                      setState(() {
                        product.isFavorite = !product.isFavorite;
                      });
                    },
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
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FirestoreExample()),
                            );
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
                            "Recommendations",
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
}