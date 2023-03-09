import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/providers/cart_provider.dart';
import 'package:ms_customer_app/providers/products_class.dart';
import 'package:ms_customer_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:badges/badges.dart' as badge;
import 'package:collection/collection.dart';

import '../../providers/wichlist_provider.dart';
import '/screens/cart_screen.dart';
import '/screens/minor_screen/visit_store_screen.dart';
import '/widgets/appbar_widget.dart';
import '../../models/product_data_model.dart';
import '../../widgets/blue_button.dart';
import 'full_screen_view.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = "product_detail_screen";
  final dynamic product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey<ScaffoldMessengerState> scafoldKey =
      GlobalKey<ScaffoldMessengerState>();
  late List<dynamic> imagesList = widget.product["productImages"];
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .where("mainCategory", isEqualTo: product["mainCategory"])
        .snapshots();
    final Stream<QuerySnapshot> reviewsStream = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product["productId"])
        .collection("reviews")
        .snapshots();
    return SafeArea(
      child: ScaffoldMessenger(
        key: scafoldKey,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenView(
                                imagesList: imagesList,
                              ),
                            ));
                      },
                      child: Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .45,
                            // width: double.infinity,
                            child: Swiper(
                                pagination: const SwiperPagination(
                                  builder: SwiperPagination.fraction,
                                ),
                                itemBuilder: (context, index) {
                                  return Image(
                                    image: NetworkImage(imagesList[index]),
                                    fit: BoxFit.cover,
                                  );
                                },
                                itemCount: imagesList.length),
                          ),
                          Positioned(
                              top: 20,
                              left: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.lightBlueAccent,
                                child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.arrow_back_ios_new)),
                              )),
                          Positioned(
                              top: 20,
                              right: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.lightBlueAccent,
                                child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {},
                                    icon: const Icon(Icons.share)),
                              )),
                        ],
                      ),
                    ),
                    Text(
                      product["productName"],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "USD",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: [
                                // Text(
                                //   "\$ ",
                                //   style: TextStyle(
                                //     color: Colors.red.shade600,
                                //     fontSize: 20,
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                product["discount"] != 0
                                    ? Text(product["price"].toStringAsFixed(2),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.w600,
                                        ))
                                    : Text(
                                        product["price"].toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.red.shade600,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            product["discount"] != 0
                                ? Text(
                                    ((1 - (product["discount"] / 100)) *
                                            product["price"])
                                        .toStringAsFixed(2),
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : const Text(""),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              context
                                          .read<WishlistProvider>()
                                          .wishlistList
                                          .firstWhereOrNull(
                                            (wishlistProduct) =>
                                                wishlistProduct.documentId ==
                                                product["productId"],
                                          ) !=
                                      null
                                  ? context
                                      .read<WishlistProvider>()
                                      .removeFromWishlist(product["productId"])
                                  : context
                                      .read<WishlistProvider>()
                                      .addWishItem(
                                          product["productName"],
                                          product["discount"] != 0
                                              ? ((1 -
                                                      (product["discount"] /
                                                          100)) *
                                                  product["price"])
                                              : product["price"],
                                          1,
                                          product["inStock"],
                                          product["productImages"],
                                          product["productId"],
                                          product["supplierId"]);
                            },
                            icon: context
                                        .watch<WishlistProvider>()
                                        .wishlistList
                                        .firstWhereOrNull(
                                          (wishlistProduct) =>
                                              wishlistProduct.documentId ==
                                              product["productId"],
                                        ) !=
                                    null
                                ? const Icon(
                                    Icons.favorite,
                                    size: 30,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.favorite_border_outlined,
                                    size: 30,
                                    color: Colors.red,
                                  )),
                      ],
                    ),
                    product["inStock"] == 0
                        ? const Text(
                            "This item is out of stock",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16,
                            ),
                          )
                        : Text(
                            "${product["inStock"]} pieces available in stock",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16,
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ProductDetailsHeader(
                      lable: "   Item Description   ",
                    ),
                    Text(
                      product["productDescription"],
                      style: TextStyle(
                        color: Colors.blueGrey.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    //Reviews
                    Stack(
                      children: [
                        ExpandableTheme(
                            data: const ExpandableThemeData(
                                iconSize: 24,
                                iconColor: Colors.lightBlueAccent),
                            child: reviews(reviewsStream)),
                        const Positioned(
                            right: 35, top: 10, child: Text("rate%"))
                      ],
                    ),

                    const ProductDetailsHeader(
                      lable: "   Similar Items   ",
                    ),
                    SizedBox(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: productsStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: Text("Waiting"));
                          }
                          final data = snapshot.data!.docs;
                          if (data.isEmpty) {
                            return const Center(
                              child: Text(
                                "This category \n has no items yet !",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            child: StaggeredGridView.countBuilder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data.length,
                              crossAxisCount: 2,
                              itemBuilder: (context, index) {
                                return ProductDataModel(
                                  data: data[index],
                                );
                              },
                              staggeredTileBuilder: (index) {
                                return const StaggeredTile.fit(1);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
            ),
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisitStoreScreen(
                                    supplierId: product["supplierId"]),
                              ));
                        },
                        icon: const Icon(Icons.store)),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(
                                  back: AppBarBackButton(color: Colors.black)),
                            ));
                      },
                      icon: badge.Badge(
                          animationType: badge.BadgeAnimationType.slide,
                          badgeColor: Colors.lightBlueAccent,
                          badgeContent: Text(context
                              .watch<CartProvider>()
                              .productsList
                              .length
                              .toString()),
                          child: const Icon(Icons.shopping_cart)),
                    ),
                  ],
                ),
                BlueButton(
                  lable: context
                              .read<CartProvider>()
                              .productsList
                              .firstWhereOrNull(
                                (cartProduct) =>
                                    cartProduct.documentId ==
                                    product["productId"],
                              ) !=
                          null
                      ? "Added to cart"
                      : 'ADD TO CART',
                  color: Colors.lightBlueAccent,
                  width: .5,
                  onPressed: () {
                    if (product["inStock"] == 0) {
                      SnackBarHundler.showSnackBar(
                          scafoldKey, "This item is out of stock");
                    } else if (context
                            .read<CartProvider>()
                            .productsList
                            .firstWhereOrNull(
                              (cartProduct) =>
                                  cartProduct.documentId ==
                                  product["productId"],
                            ) !=
                        null) {
                      SnackBarHundler.showSnackBar(
                          scafoldKey, "This item already in your cart");
                    } else {
                      context.read<CartProvider>().addItem(
                            Product(
                                name: product["productName"],
                                price: product["discount"] != 0
                                    ? ((1 - (product["discount"] / 100)) *
                                        product["price"])
                                    : product["price"],
                                quentity: 1,
                                inStock: product["inStock"],
                                imagesUrl: imagesList.first,
                                documentId: product["productId"],
                                supplierId: product["supplierId"]),
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget reviews(reviewsStream) {
  return ExpandablePanel(
      header: const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          "reviews",
          style: TextStyle(
              fontSize: 24,
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold),
        ),
      ),
      collapsed: SizedBox(height: 70, child: reviewExpanded(reviewsStream)),
      expanded: SizedBox(height: 250, child: reviewExpanded(reviewsStream)));
}

Widget reviewExpanded(reviewsStream) {
  return StreamBuilder<QuerySnapshot>(
    stream: reviewsStream,
    builder:
        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshotReview) {
      if (snapshotReview.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshotReview.connectionState == ConnectionState.waiting) {
        return const Material(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final review = snapshotReview.data!.docs;
      if (review.isEmpty) {
        return const Text(
          "This item has no reviwes yet !",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 18,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        );
      }

      return ListView.builder(
        itemCount: review.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              height: 70,
              width: 70,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  review[index]["customerProfileImage"],
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review[index]["customerName"]),
                Row(
                  children: [
                    Text(review[index]["rate"].toString()),
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                    )
                  ],
                )
              ],
            ),
            subtitle: Text(
              review[index]["comment"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      );
    },
  );
}

class ProductDetailsHeader extends StatelessWidget {
  final String lable;
  const ProductDetailsHeader({
    Key? key,
    required this.lable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 40,
            child: Divider(
              thickness: 3,
              height: 2,
              color: Colors.lightBlueAccent,
            ),
          ),
          Text(
            lable,
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
              width: 50,
              height: 40,
              child: Divider(
                thickness: 3,
                height: 2,
                color: Colors.lightBlueAccent,
              )),
        ],
      ),
    );
  }
}
