import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ms_customer_app/widgets/blue_button.dart';

class CustomerOrderModel extends StatefulWidget {
  final dynamic order;
  const CustomerOrderModel({super.key, required this.order});

  @override
  State<CustomerOrderModel> createState() => _CustomerOrderModelState();
}

class _CustomerOrderModelState extends State<CustomerOrderModel> {
  late double rate;
  late String comment;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Container(
        constraints:
            const BoxConstraints(maxHeight: 80, maxWidth: double.infinity),
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 80, maxWidth: 80),
              child: Image.network(widget.order["orderImage"]),
            ),
            Flexible(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.order["productName"],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "\$ ${widget.order["orderPrice"].toStringAsFixed(2)}"),
                      Text("x ${widget.order["orderQuantity"].toString()}")
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("See more .."),
          Text(widget.order["deliveryStatus"])
        ],
      ),
      children: [
        Container(
          // height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: widget.order["deliveryStatus"] == "delivered"
                  ? Colors.amber.shade100
                  : Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${widget.order["customerName"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Phone: ${widget.order["customerPhone"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Email Address: ${widget.order["customerEmail"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  "Address: ${widget.order["customerAddress"]}",
                  style: const TextStyle(fontSize: 15),
                ),
                Row(
                  children: [
                    const Text(
                      "Payment Status: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${widget.order["paymentStatus"]}",
                      style:
                          const TextStyle(fontSize: 15, color: Colors.purple),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Delivry Status: ",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${widget.order["deliveryStatus"]}",
                      style: const TextStyle(fontSize: 15, color: Colors.green),
                    ),
                  ],
                ),
                widget.order["deliveryStatus"] == "shipping"
                    ? Text(
                        "Estimated Delivery Date: ${DateFormat("yyyy-MM-dd").format(widget.order["deliveryDate"].toDate())}",
                        style: const TextStyle(fontSize: 15),
                      )
                    : const Text(""),
                widget.order["orderReview"] == false &&
                        widget.order["deliveryStatus"] == "delivered"
                    ? TextButton(

                        //Rating produacts

                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusManager.instance.primaryFocus
                                    ?.unfocus(),
                                child: Material(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        RatingBar.builder(
                                            initialRating: 1,
                                            minRating: 1,
                                            allowHalfRating: true,
                                            itemBuilder: (context, index) {
                                              return const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              );
                                            },
                                            onRatingUpdate: (value) {
                                              rate = value;
                                            }),
                                        TextField(
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: "Enter your review",
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                          ),
                                          onChanged: (value) => comment = value,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            BlueButton(
                                                lable: "cancel",
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                width: .4,
                                                color: Colors.lightBlueAccent),
                                            BlueButton(
                                                lable: "Ok",
                                                onPressed: () async {
                                                  //Creat new collection called reviews in products collection

                                                  CollectionReference
                                                      productReviews =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "products")
                                                          .doc(widget.order[
                                                              "productId"])
                                                          .collection(
                                                              "reviews");

                                                  await productReviews
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .set({
                                                    "customerName": widget
                                                        .order["customerName"],
                                                    "customerEmail": widget
                                                        .order["customerEmail"],
                                                    "customerProfileImage": widget
                                                            .order[
                                                        "customerProfileImage"],
                                                    "rate": rate,
                                                    "comment": comment
                                                  }).whenComplete(() async {
                                                    // await FirebaseFirestore
                                                    //     .instance
                                                    //     .collection("orders")
                                                    //     .doc(widget
                                                    //         .order["order"])
                                                    //     .update({
                                                    //   "orderReview": true
                                                    // });

                                                    await FirebaseFirestore
                                                        .instance
                                                        .runTransaction(
                                                            (transaction) async {
                                                      DocumentReference
                                                          documentReference =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "orders")
                                                              .doc(widget.order[
                                                                  "order"]);
                                                      transaction.update(
                                                          documentReference, {
                                                        "orderReview": true
                                                      });
                                                    });
                                                  });
                                                  await Future.delayed(
                                                          const Duration(
                                                              microseconds: 10))
                                                      .then((value) =>
                                                          Navigator.pop(
                                                              context));
                                                },
                                                width: .4,
                                                color: Colors.lightBlueAccent),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const Text("Write Review"))
                    : const Text(""),
                widget.order["orderReview"] == true &&
                        widget.order["deliveryStatus"] == "delivered"
                    ? Row(
                        children: const [
                          Icon(
                            Icons.check,
                            color: Colors.lightBlueAccent,
                          ),
                          Text(
                            "Review Added",
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.lightBlueAccent),
                          )
                        ],
                      )
                    : const Text(""),
              ],
            ),
          ),
        )
      ],
    );
  }
}
