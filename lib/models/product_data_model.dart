// import 'dart:ui';

import 'package:flutter/material.dart';
import '../screens/minor_screen/product_detail_screen.dart';

class ProductDataModel extends StatelessWidget {
  final dynamic data;

  const ProductDataModel({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //  dynamic product = data;
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: data),
          )),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxHeight: 250, minHeight: 100),
                    child: Image(image: NetworkImage(data["productImages"][0])),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    data["productName"],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Text(
                            "\$ ",
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          data["discount"] != 0
                              ? Text(data["price"].toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w600,
                                  ))
                              : Text(
                                  data["price"].toStringAsFixed(2),
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ],
                      ),
                      data["discount"] != 0
                          ? Text(
                              ((1 - (data["discount"] / 100)) * data["price"])
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const Text(""),
                    ],
                  ),
                )
              ],
            ),
          ),
          data["discount"] == 0
              ? const SizedBox()
              : Positioned(
                  top: 30,
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    child: Center(
                      child: Text(
                        "Save ${data["discount"]} %",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
        ]),
      ),
    );
  }
}
