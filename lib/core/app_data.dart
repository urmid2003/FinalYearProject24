import 'package:glitzproject/src/model/bottom_navy_bar_item.dart';
import 'package:glitzproject/src/model/recommended_product.dart';
import 'package:glitzproject/src/model/product_size_type.dart';
import 'package:glitzproject/src/model/product_category.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glitzproject/src/model/categorical.dart';
import 'package:glitzproject/src/model/numerical.dart';
import 'package:glitzproject/src/model/product.dart';
import 'package:flutter/material.dart';

class AppData {
  const AppData._();

  static String dummyText =
      'Lorem Ipsum is simply dummy text of the printing and typesetting'
      ' industry. Lorem Ipsum has been the industry\'s standard dummy text'
      ' ever since the 1500s, when an unknown printer took a galley of type'
      ' and scrambled it to make a type specimen book.';

  static List<Product> products = [
    Product(
      name: 'Personalized Cuff Bracelet',
      price: 460,
      about: dummyText,
      isAvailable: true,
      off: 300,
      quantity: 0,
      images: [
        'assets/images/cuff_bracelet_1.jpg',
        'assets/images/cuff_bracelet_2.jpeg',
        'assets/images/cuff_bracelet_2.jpg'
      ],
      isFavorite: true,
      rating: 1,
      type: ProductType.mobile,
    ),
    Product(
      name: 'Personalized Name Lamp',
      price: 380,
      about: dummyText,
      isAvailable: false,
      off: 220,
      quantity: 0,
      images: [
        'assets/images/name_lamp_1.jpg',
        'assets/images/name_lamp_2.jpg',
        'assets/images/name_lamp_3.jpg'
      ],
      isFavorite: false,
      rating: 4,
      type: ProductType.tablet,
    ),
    Product(
      name: 'Personalized Cute Caricature',
      price: 650,
      about: dummyText,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/cute_caricapture_2.jpg',
        'assets/images/cute_caricature_1.jpg',
        'assets/images/cute_caricature_3.jpg',
      ],
      isFavorite: false,
      rating: 3,
      type: ProductType.tablet,
    ),
    Product(
      name: 'Handmade Wooden Photo Stand',
      price: 229,
      about: dummyText,
      isAvailable: true,
      off: 200,
      quantity: 0,
      images: [
        'assets/images/wooden_frame_2.jpg',
        'assets/images/wooden_frame_1.jpg',
        'assets/images/wooden_frame_3.jpg'
      ],
      isFavorite: false,
      rating: 5,
      sizes: ProductSizeType(
        categorical: [
          Categorical(CategoricalType.small, true),
          Categorical(CategoricalType.medium, false),
          Categorical(CategoricalType.large, false),
        ],
      ),
      type: ProductType.watch,
    ),
    Product(
      name: 'Personalized Mug Picture/Name',
      price: 330,
      about: dummyText,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/per_mug_2.jpg',
        'assets/images/per_mug_1.jpg',
        'assets/images/per_mug_3.jpg',
      ],
      isFavorite: false,
      rating: 4,
      sizes: ProductSizeType(
        numerical: [Numerical('41', true), Numerical('45', false)],
      ),
      type: ProductType.watch,
    ),
    Product(
        name: 'EGD Acrylic Spotify Plaque',
        price: 230,
        about: dummyText,
        isAvailable: true,
        off: null,
        quantity: 0,
        images: [
          'assets/images/EGD_plaque_1.jpg',
          'assets/images/EGD_plaque_2.jpg',
          'assets/images/EGD_plaque_3.jpg',
          'assets/images/EGD_plaque_1.jpg',
        ],
        isFavorite: false,
        rating: 2,
        type: ProductType.headphone),
    Product(
      name: 'Customized Neon Name Sign',
      price: 497,
      about: dummyText,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/Neon_name_3.jpg',
        'assets/images/Neon_name_1.jpg',
      ],
      isFavorite: false,
      rating: 3,
      sizes: ProductSizeType(
        numerical: [
          Numerical('43', true),
          Numerical('50', false),
          Numerical('55', false)
        ],
      ),
      type: ProductType.tv,
    ),
    Product(
      name: 'Personalized Photo Cushion',
      price: 498,
      about: dummyText,
      isAvailable: true,
      off: null,
      quantity: 0,
      images: [
        'assets/images/Cushion_3.jpg',
        'assets/images/Cushion_1.jpg',
      ],
      isFavorite: false,
      sizes: ProductSizeType(
        numerical: [
          Numerical('50', true),
          Numerical('65', false),
          Numerical('85', false)
        ],
      ),
      rating: 2,
      type: ProductType.tv,
    ),
  ];

  static List<ProductCategory> categories = [
    ProductCategory(
      ProductType.all,
      true,
      Icons.all_inclusive,
    ),
    ProductCategory(
      ProductType.mobile,
      false,
      Icons.art_track,
    ),
    ProductCategory(ProductType.watch, false, Icons.backup_table_outlined),
    
    ProductCategory(
      ProductType.tablet,
      false,
      Icons.assignment_ind_sharp,
    ),
    ProductCategory(
      ProductType.headphone,
      false,
      Icons.auto_awesome_mosaic,
    ),
    ProductCategory(
      ProductType.tv,
      false,
      Icons.auto_graph_sharp,
    ),
  ];

  static List<Color> randomColors = [
    const Color(0xFFFCE4EC),
    const Color(0xFFF3E5F5),
    const Color(0xFFEDE7F6),
    const Color(0xFFE3F2FD),
    const Color(0xFFE0F2F1),
    const Color(0xFFF1F8E9),
    const Color(0xFFFFF8E1),
    const Color(0xFFECEFF1),
  ];

  static List<BottomNavyBarItem> bottomNavyBarItems = [
    BottomNavyBarItem(
      "Home",
      const Icon(Icons.home),
      const Color(0xFFEC6813),
      Colors.grey,
    ),
    BottomNavyBarItem(
      "Favorite",
      const Icon(Icons.favorite),
      const Color(0xFFEC6813),
      Colors.grey,
    ),
    BottomNavyBarItem(
      "Cart",
      const Icon(Icons.shopping_cart),
      const Color(0xFFEC6813),
      Colors.grey,
    ),
    BottomNavyBarItem(
      "Profile",
      const Icon(Icons.person),
      const Color(0xFFEC6813),
      Colors.grey,
    ),
  ];

  static List<RecommendedProduct> recommendedProducts = [
    RecommendedProduct(
      imagePath: "",
      cardBackgroundColor: const Color(0xFFEC6813),
    ),
    RecommendedProduct(
      imagePath: "",
      cardBackgroundColor: const Color(0xFF3081E1),
      buttonBackgroundColor: const Color(0xFF9C46FF),
      buttonTextColor: Colors.white,
    ),
  ];
}
