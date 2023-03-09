import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/providers/cart_provider.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/screens/customer_screens/add_address.dart';
import 'package:ms_customer_app/screens/minor_screen/payment_screen.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:ms_customer_app/widgets/blue_button.dart';
import 'package:provider/provider.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({
    super.key,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  late String docId;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');
  @override
  void initState() {
    docId = context.read<IdProvider>().getData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = context.watch<CartProvider>().totalPrice;
    return FutureBuilder<DocumentSnapshot>(
        future: customers.doc(FirebaseAuth.instance.currentUser!.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("Document does not exist");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Material(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> customerData =
                snapshot.data!.data() as Map<String, dynamic>;
            return Material(
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.grey.shade200,
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.grey.shade200,
                    leading: AppBarBackButton(color: Colors.black),
                    title: const AppBarTitle(title: "Place order"),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                    child: Column(
                      children: [
                        customerData["address"] == ""
                            ? GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AddAddress.routeName,
                                ),
                                child: Container(
                                  height: 90,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: const Center(
                                      child: Text(
                                    "Set Your Address",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: Colors.blueGrey,
                                    ),
                                  )),
                                ),
                              )
                            : Container(
                                height: 90,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text("Name: ${customerData["name"]}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text("Phone: ${customerData["phone"]}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text(
                                            "Address: ${customerData["address"]}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ]),
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Consumer<CartProvider>(
                                builder: (_, cartProduct, __) =>
                                    ListView.builder(
                                      itemCount:
                                          cartProduct.productsList.length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            cartProduct.productsList[index];
                                        return Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(width: .1),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15)),
                                                  child: SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: Image.network(
                                                          order.imagesUrl)),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Text(
                                                          order.name,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors.grey
                                                                  .shade600),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              order.price
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
                                                            ),
                                                            Text(
                                                              " x ${order.quentity.toString()}",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600),
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
                                        );
                                      },
                                    )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottomSheet: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: customerData["address"] == ""
                        ? BlueButton(
                            lable: "Add New Address",
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AddAddress.routeName);
                            },
                            width: double.infinity,
                            color: Colors.lightBlueAccent)
                        : BlueButton(
                            lable:
                                "Confirm ${totalPrice.toStringAsFixed(2)} USD",
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaymentScreen(),
                                  ));
                            },
                            width: double.infinity,
                            color: Colors.lightBlueAccent),
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlueAccent,
              ),
            ),
          );
        });
  }
}
