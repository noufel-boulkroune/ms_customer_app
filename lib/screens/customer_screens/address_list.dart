import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/screens/customer_screens/add_address.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:ms_customer_app/widgets/blue_button.dart';
import 'package:provider/provider.dart';

class AddressList extends StatefulWidget {
  static const routeName = "address-list";
  const AddressList({super.key});

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  final Stream<QuerySnapshot> _addressStream = FirebaseFirestore.instance
      .collection('customers')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("address")
      .snapshots();

  bool processing = false;
  bool defaultAddress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: AppBarBackButton(color: Colors.black),
        title: const AppBarTitle(title: "Address List"),
      ),
      body: processing
          ? const Material(
              color: Colors.white,
              child: Center(
                child: Image(
                  image: AssetImage("assets/svgs/loading-animation-blue.gif"),
                ),
              ),
            )
          : SafeArea(
              child: Column(
              children: [
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                  stream: _addressStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Material(
                        color: Colors.white,
                        child: Center(
                          child: Image(
                            image: AssetImage(
                                "assets/svgs/loading-animation-blue.gif"),
                          ),
                        ),
                      );
                    }
                    final customerAddressData = snapshot.data!.docs;
                    if (customerAddressData.isEmpty) {
                      return const Center(
                        child: Text(
                          "You didn't set any address yet !",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: customerAddressData.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) async {
                            customerAddressData[index]["default"] == true
                                ? defaultAddress = true
                                : defaultAddress = false;
                            await FirebaseFirestore.instance
                                .runTransaction((transaction) async {
                              DocumentReference docReference = FirebaseFirestore
                                  .instance
                                  .collection("customers")
                                  .doc(context.read<IdProvider>().getData)
                                  .collection("address")
                                  .doc(customerAddressData[index]["addressId"]);
                              transaction.delete(docReference);
                            }).then((value) async => defaultAddress == true
                                    ? await FirebaseFirestore.instance
                                        .runTransaction((transaction) async {
                                        DocumentReference docReference =
                                            FirebaseFirestore.instance
                                                .collection("customers")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        transaction.update(docReference, {
                                          "phone": "",
                                          "address": "",
                                        });
                                      })
                                    : null);
                          },
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                processing = true;
                              });

                              for (var item in customerAddressData) {
                                await FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  DocumentReference documentReference =
                                      FirebaseFirestore.instance
                                          .collection("customers")
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection("address")
                                          .doc(item.id);
                                  transaction.update(documentReference, {
                                    "default": false,
                                  });
                                }).then((value) async {
                                  await FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    DocumentReference documentReference =
                                        FirebaseFirestore.instance
                                            .collection("customers")
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .collection("address")
                                            .doc(customerAddressData[index]
                                                ["addressId"]);
                                    transaction.update(documentReference, {
                                      "default": true,
                                    });
                                  });
                                }).then((value) async {
                                  await FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    // DocumentReference documentReference =
                                    //     FirebaseFirestore.instance
                                    //         .collection("customers")
                                    //         .doc(FirebaseAuth
                                    //             .instance.currentUser!.uid);
                                    // DocumentSnapshot documentSnapshot =
                                    //     await transaction
                                    //         .get(documentReference);
                                    // transaction.update(documentReference, {
                                    //   "phone": customerAddressData[index]
                                    //       ["phoneNumber"],
                                    //   "address":
                                    //       "${customerAddressData[index]["country"]} / ${customerAddressData[index]["state"]} / ${customerAddressData[index]["city"]}",
                                    // });
                                  });
                                  setState(() {
                                    processing = false;
                                  });
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: customerAddressData[index]["default"] ==
                                        true
                                    ? Colors.lightBlueAccent.withOpacity(.5)
                                    : Colors.white,
                                child: ListTile(
                                  trailing: customerAddressData[index]
                                              ["default"] ==
                                          true
                                      ? const Icon(
                                          Icons.home,
                                          color: Colors.white,
                                        )
                                      : const SizedBox(),
                                  title: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    height: 55,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${customerAddressData[index]["firstName"]} - ${customerAddressData[index]["lastName"]}"),
                                        Text(
                                            "${customerAddressData[index]["phoneNumber"]}"),
                                      ],
                                    ),
                                  ),
                                  subtitle: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    height: 55,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "City/State: ${customerAddressData[index]["city"]} / ${customerAddressData[index]["state"]}"),
                                        Text(
                                            " Country: ${customerAddressData[index]["country"]}"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )),
                BlueButton(
                    lable: "Add New Address",
                    onPressed: () {
                      Navigator.pushNamed(context, AddAddress.routeName);
                    },
                    width: .8,
                    color: Colors.lightBlueAccent)
              ],
            )),
    );
  }
}
