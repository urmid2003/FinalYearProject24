import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glitzproject/core/extensions.dart';
import 'package:glitzproject/src/model/product.dart';
import 'package:glitzproject/src/view/widget/empty_cart.dart';
import 'package:glitzproject/src/controller/product_controller.dart';
import 'package:glitzproject/src/view/animation/animated_switcher_wrapper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

final ProductController controller = Get.put(ProductController());

class CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    _razorpay.clear();
    amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment Done");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Fail");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  @override
  Widget build(BuildContext context) {
    controller.getCartItems();
    return Scaffold(
      appBar: _appBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: !controller.isEmptyCart ? cartList() : const EmptyCart(),
          ),
          bottomBarTitle(),
          bottomBarButton()
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        "My cart",
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget cartList() {
    return SingleChildScrollView(
      child: Column(
        children: controller.cartProducts.mapWithIndex((index, _) {
          Product product = controller.cartProducts[index];
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[200]?.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorExtension.randomColor,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          product.images[0],
                          width: 100,
                          height: 90,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.nextLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.getCurrentSize(product),
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      controller.isPriceOff(product)
                          ? "\$${product.off}"
                          : "\$${product.price}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 23,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        splashRadius: 10.0,
                        onPressed: () =>
                            controller.decreaseItemQuantity(product),
                        icon: const Icon(
                          Icons.remove,
                          color: Color(0xFFEC6813),
                        ),
                      ),
                      GetBuilder<ProductController>(
                        builder: (ProductController controller) {
                          return AnimatedSwitcherWrapper(
                            child: Text(
                              '${controller.cartProducts[index].quantity}',
                              key: ValueKey<int>(
                                controller.cartProducts[index].quantity,
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        splashRadius: 10.0,
                        onPressed: () =>
                            controller.increaseItemQuantity(product),
                        icon: const Icon(Icons.add, color: Color(0xFFEC6813)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget bottomBarTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
          ),
          Obx(
            () {
              return AnimatedSwitcherWrapper(
                child: Text(
                  "\$${controller.totalPrice.value}",
                  key: ValueKey<int>(controller.totalPrice.value),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEC6813),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget bottomBarButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
          onPressed: controller.isEmptyCart
              ? null
              : () {
                  ///Make payment
                  var options = {
                    'key': "rzp_test_xvlZZBGCo0SzL0",
                    // amount will be multiple of 100
                    'amount': 50000, //So it pays 500
                    'name': 'Glitz Pvt ltd',
                    'description': 'Demo',
                    'timeout': 300, // in seconds
                    'prefill': {
                      'contact': '8787878787',
                      'email': 'codewithpatel@gmail.com'
                    }
                  };
                  _razorpay.open(options);
                },
          child: const Text("Buy Now"),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => CartScreenState();
}