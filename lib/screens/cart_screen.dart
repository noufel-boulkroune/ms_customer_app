import 'package:flutter/material.dart';
import 'package:ms_customer_app/auth/customer_login_screen.dart';

import 'package:ms_customer_app/providers/cart_provider.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/widgets/alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/wichlist_provider.dart';
import '../screens/customer_home_screen.dart';
import '../widgets/appbar_widget.dart';

import 'minor_screen/place_order_screen.dart';

class CartScreen extends StatefulWidget {
  final Widget? back;
  const CartScreen({super.key, this.back});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String docId;

  @override
  void initState() {
    docId = context.read<IdProvider>().getData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const AppBarTitle(title: "Cart"),
            leading: widget.back,
            actions: [
              context.watch<CartProvider>().productsList.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        GeneralAlertDialog.showMyDialog(
                            context: context,
                            title: "Clear cart",
                            contet: "Are you sure you want to clear cart?",
                            tabNo: () {
                              Navigator.pop(context);
                            },
                            tabYes: () {
                              context.read<CartProvider>().clearCart();
                              Navigator.pop(context);
                            });
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.black,
                      ))
                  : const SizedBox()
            ],
          ),
          body: context.watch<CartProvider>().productsList.isNotEmpty
              ? const CartItems()
              : const EmptyCart(),
          bottomSheet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Text(
                  "Total : \$ ",
                  style: TextStyle(fontSize: 18),
                ),
                Consumer<CartProvider>(
                  builder: (_, cart, __) {
                    return Expanded(
                      child: Text(
                        cart.totalPrice.toStringAsFixed(2),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent),
                      ),
                    );
                  },
                ),
                MaterialButton(
                  onPressed: context.watch<CartProvider>().totalPrice == 0
                      ? null
                      : docId == ""
                          ? () {
                              GeneralAlertDialog.showMyDialog(
                                  context: context,
                                  title: "Please Log In",
                                  contet:
                                      "you should be logged in to take an action",
                                  tabNo: () {
                                    Navigator.pop(context);
                                  },
                                  tabYes: () {
                                    Navigator.pushReplacementNamed(
                                        context, CustomerLoginScreen.routeName);
                                    Navigator.pop(context);
                                  });
                            }
                          : () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const PlaceOrderScreen();
                              }));
                            },
                  color: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: const Text('CHECK OUT'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  const EmptyCart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "Your Cart Is Empty!",
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(
          height: 50,
        ),
        Material(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(25),
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width * .6,
            onPressed: () {
              Navigator.canPop(context)
                  ? Navigator.pop(context)
                  : Navigator.pushReplacementNamed(
                      context, CustomerHomeScreen.routeName);
            },
            child: const Text(
              "continue shopping",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class CartItems extends StatelessWidget {
  const CartItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        return ListView.builder(
          itemCount: cart.count,
          itemBuilder: (context, index) {
            final product = cart.productsList[index];
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                child: SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.network(
                            product.imagesUrl,
                            fit: BoxFit.cover,
                          )),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${product.price.toStringAsFixed(2)} \$",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          product.quentity == 1
                                              ? IconButton(
                                                  onPressed: () {
                                                    GeneralAlertDialog
                                                        .showMyDialog(
                                                            context: context,
                                                            title:
                                                                "Remove item from cart",
                                                            contet: context
                                                                        .read<
                                                                            WishlistProvider>()
                                                                        .wishlistList
                                                                        .firstWhereOrNull(
                                                                          (wishlistProduct) =>
                                                                              wishlistProduct.documentId ==
                                                                              product.documentId,
                                                                        ) ==
                                                                    null
                                                                ? "Do you want to add this product to wishlist?"
                                                                : "Do you want to remove this item from cart?",
                                                            tabYes: () {
                                                              context
                                                                          .read<
                                                                              WishlistProvider>()
                                                                          .wishlistList
                                                                          .firstWhereOrNull(
                                                                            (wishlistProduct) =>
                                                                                wishlistProduct.documentId ==
                                                                                product.documentId,
                                                                          ) ==
                                                                      null
                                                                  ? context.read<WishlistProvider>().addWishItem(
                                                                      product
                                                                          .name,
                                                                      product
                                                                          .price,
                                                                      1,
                                                                      product
                                                                          .inStock,
                                                                      product
                                                                          .imagesUrl,
                                                                      product
                                                                          .documentId,
                                                                      product
                                                                          .supplierId)
                                                                  : null;
                                                              cart.removeItem(
                                                                  product);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            tabNo: () {
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                  },
                                                  icon: const Icon(
                                                      Icons.delete_forever))
                                              : IconButton(
                                                  onPressed: () {
                                                    cart.decrementQuentity(
                                                        product);
                                                  },
                                                  icon:
                                                      const Icon(Icons.remove)),
                                          Text(
                                            product.quentity.toString(),
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: product.quentity ==
                                                        product.inStock
                                                    ? Colors.red
                                                    : Colors.black),
                                          ),
                                          IconButton(
                                              onPressed: product.quentity ==
                                                      product.inStock
                                                  ? null
                                                  : () {
                                                      cart.incrementQuentity(
                                                          product);
                                                    },
                                              icon: const Icon(Icons.add)),
                                        ]),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
