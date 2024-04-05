import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:glitzproject/core/app_data.dart';
import 'package:glitzproject/src/model/product.dart';
import 'package:glitzproject/src/model/numerical.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:glitzproject/src/model/product_category.dart';
import 'package:glitzproject/src/model/product_size_type.dart';

class ProductController extends GetxController {
  List<Product> allProducts = AppData.products;
  RxList<Product> filteredProducts = AppData.products.obs;
  RxList<Product> cartProducts = <Product>[].obs;
  RxList<ProductCategory> categories = AppData.categories.obs;
  RxInt totalPrice = 0.obs;

  void filterItemsByCategory(int index) {
    for (ProductCategory element in categories) {
      element.isSelected = false;
    }
    categories[index].isSelected = true;

    if (categories[index].type == ProductType.all) {
      filteredProducts.assignAll(allProducts);
    } else {
      filteredProducts.assignAll(allProducts.where((item) {
        return item.type == categories[index].type;
      }).toList());
    }
    update();
  }

  void isFavorite(int index) {
    filteredProducts[index].isFavorite = !filteredProducts[index].isFavorite;
    update();
  }

  void addToCart(Product product) async {
  // Increment the quantity of the product
  product.quantity++;
  
  // Add the product to the cart list in the local state
  cartProducts.add(product);
  
  // Update the cart in Firestore
  await _updateCartInFirebase(product);
  
  // Recalculate the total price
  calculateTotalPrice();
}

Future<void> _updateCartInFirebase(Product product) async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    
    // Add the product to the cart in Firestore
    await userRef.update({
      'cart': FieldValue.arrayUnion([{
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
        // Add any other relevant details here
      }]),
    });
  } catch (e) {
    print('Error updating cart in Firebase: $e');
  }
}


  void increaseItemQuantity(Product product) async{
    product.quantity++;
    await _updateCartItemQuantityInFirebase(product);
    calculateTotalPrice();
    update();
  }


  void decreaseItemQuantity(Product product) async {
     if (product.quantity >1) {
      product.quantity--;
      await _updateCartItemQuantityInFirebase(product);
    }
      else if (product.quantity == 1 ) {
       product.quantity--;
      await _updateCartItemQuantityInFirebase(product);

    }
    else if (product.quantity == 0 ) {
    product.quantity--;
     await removeCartItemFromFirebase(product);
      
    }
    else {

    }
  
    calculateTotalPrice();
    update();
  }


 Future<void> removeCartItemFromFirebase(Product product) async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    
    if (product.quantity <= 0) {
      // If quantity is zero or less, remove the item from the cart
      await userRef.update({
        'cart': FieldValue.arrayRemove([
          {'name': product.name, 'price': product.price}
        ]),
      });
    }
  } catch (e) {
    print('Error removing cart item from Firebase: $e');
  }
}



   Future<void> _updateCartItemQuantityInFirebase(Product product) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'cart': cartProducts.map((product) => {'name': product.name, 'price': product.price, 'quantity': product.quantity}).toList(),
      });
    } catch (e) {
      print('Error updating cart in Firebase: $e');
    }
  }


  bool isPriceOff(Product product) => product.off != null;

  bool get isEmptyCart => cartProducts.isEmpty;

  bool isNominal(Product product) => product.sizes?.numerical != null;



  void calculateTotalPrice() {
    totalPrice.value = 0;
    for (var element in cartProducts) {
      if (isPriceOff(element)) {
        totalPrice.value += element.quantity * element.off!;
      } else {
        totalPrice.value += element.quantity * element.price;
      }
    }
  }

  getFavoriteItems() {
    filteredProducts.assignAll(
      allProducts.where((item) => item.isFavorite),
    );
  }

  getCartItems() {
    cartProducts.assignAll(
      allProducts.where((item) => item.quantity > 0),
    );
  }

  getAllItems() {
    filteredProducts.assignAll(allProducts);
  }

  List<Numerical> sizeType(Product product) {
    ProductSizeType? productSize = product.sizes;
    List<Numerical> numericalList = [];

    if (productSize?.numerical != null) {
      for (var element in productSize!.numerical!) {
        numericalList.add(Numerical(element.numerical, element.isSelected));
      }
    }

    if (productSize?.categorical != null) {
      for (var element in productSize!.categorical!) {
        numericalList.add(
          Numerical(
            element.categorical.name,
            element.isSelected,
          ),
        );
      }
    }

    return numericalList;
  }

  void switchBetweenProductSizes(Product product, int index) {
    sizeType(product).forEach((element) {
      element.isSelected = false;
    });

    if (product.sizes?.categorical != null) {
      for (var element in product.sizes!.categorical!) {
        element.isSelected = false;
      }

      product.sizes?.categorical![index].isSelected = true;
    }

    if (product.sizes?.numerical != null) {
      for (var element in product.sizes!.numerical!) {
        element.isSelected = false;
      }

      product.sizes?.numerical![index].isSelected = true;
    }

    update();
  }

  String getCurrentSize(Product product) {
    String currentSize = "";
    if (product.sizes?.categorical != null) {
      for (var element in product.sizes!.categorical!) {
        if (element.isSelected) {
          currentSize = "Size: ${element.categorical.name}";
        }
      }
    }

    if (product.sizes?.numerical != null) {
      for (var element in product.sizes!.numerical!) {
        if (element.isSelected) {
          currentSize = "Size: ${element.numerical}";
        }
      }
    }
    return currentSize;
  }
}
//code ends