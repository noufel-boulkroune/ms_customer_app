import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ms_customer_app/constante/stripe_keys.dart';
import 'package:ms_customer_app/providers/cart_provider.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/screens/customer_home_screen.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:ms_customer_app/widgets/blue_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedValue = 1;
  var paymentMethod = PaymentMethods.cash;
  late String orderId;
  bool transactin = false;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  @override
  Widget build(BuildContext context) {
    String docId = context.read<IdProvider>().getData;
    double totalPrice = context.watch<CartProvider>().totalPrice;
    double totalPaid = totalPrice + 10;
    return FutureBuilder<DocumentSnapshot>(
        future: customers
            .doc(/*FirebaseAuth.instance.currentUser!.uid*/ docId)
            .get(),
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
                    title: const AppBarTitle(title: "Payment"),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        "${totalPaid.toStringAsFixed(2)} USD",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total Order",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                      Text(
                                        "${totalPrice.toStringAsFixed(2)} USD",
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Shipping Coast",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                      Text(
                                        "10.00 USD",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ],
                                  )
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
                              child: Column(
                                children: [
                                  RadioListTile(
                                    value: 1,
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                        paymentMethod = PaymentMethods.cash;
                                      });
                                    },
                                    title: const Text("Cash On Delivery"),
                                    subtitle: const Text("Pay Cash At Home"),
                                  ),
                                  RadioListTile(
                                    value: 2,
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                        paymentMethod = PaymentMethods.visa;
                                      });
                                    },
                                    title: const Text(
                                        "Pay Via Visa / Master Card"),
                                    subtitle: Row(
                                      children: const [
                                        Icon(
                                          Icons.payment,
                                          color: Colors.blueAccent,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Icon(
                                            Icons.payment,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        Icon(
                                          Icons.payment,
                                          color: Colors.blueAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                  RadioListTile(
                                    value: 3,
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value!;
                                        paymentMethod = PaymentMethods.paypal;
                                      });
                                    },
                                    title: const Text("Pay Via Paypal"),
                                    subtitle: Row(
                                      children: const [
                                        Icon(
                                          Icons.payment,
                                          color: Colors.blueAccent,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Icon(
                                            Icons.payment,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  bottomSheet: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: transactin == true
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : BlueButton(
                            lable:
                                "Confirm ${totalPaid.toStringAsFixed(2)} USD",
                            onPressed: () {
                              if (paymentMethod == PaymentMethods.cash) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * .3,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Pay At Home ${totalPaid.toStringAsFixed(2)} \$",
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                          transactin == true
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : BlueButton(
                                                  lable:
                                                      "Confirm ${totalPaid.toStringAsFixed(2)} \$",
                                                  onPressed: () async {
                                                    setState(() {
                                                      transactin = true;
                                                    });
                                                    for (var item in context
                                                        .read<CartProvider>()
                                                        .productsList) {
                                                      CollectionReference
                                                          orderRef =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "orders");
                                                      orderId =
                                                          const Uuid().v4();
                                                      await orderRef
                                                          .doc(orderId)
                                                          .set({
                                                        //customer info
                                                        "customerId":
                                                            customerData[
                                                                "customerId"],
                                                        "customerName":
                                                            customerData[
                                                                "name"],
                                                        "customerEmail":
                                                            customerData[
                                                                "email"],
                                                        "customerAddress":
                                                            customerData[
                                                                "address"],
                                                        "customerPhone":
                                                            customerData[
                                                                "phone"],
                                                        "customerProfileImage":
                                                            customerData[
                                                                "profileImage"],
                                                        //supplier info
                                                        "supplierId":
                                                            item.supplierId,
                                                        //produst info
                                                        "productName":
                                                            item.name,
                                                        "productId":
                                                            item.documentId,
                                                        "order": orderId,
                                                        "orderImage":
                                                            item.imagesUrl,
                                                        "orderQuantity":
                                                            item.quentity,
                                                        "orderPrice":
                                                            item.quentity *
                                                                item.price,

                                                        //delivery info
                                                        "deliveryStatus":
                                                            "preparing",
                                                        "deliveryDate": "",
                                                        "orderDate":
                                                            DateTime.now(),
                                                        "paymentStatus":
                                                            "cash on delivery",
                                                        "orderReview": false,
                                                      }).then((value) async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .runTransaction(
                                                                (transaction) async {
                                                          DocumentReference
                                                              documentReference =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "products")
                                                                  .doc(item
                                                                      .documentId);
                                                          DocumentSnapshot
                                                              documentSnapshot =
                                                              await transaction.get(
                                                                  documentReference);
                                                          transaction.update(
                                                              documentReference,
                                                              {
                                                                "inStock": documentSnapshot[
                                                                        "inStock"] -
                                                                    item.quentity
                                                              });
                                                        });
                                                      });
                                                    }
                                                    setState(() {
                                                      transactin = false;
                                                    });
                                                    //clear the cart product list
                                                    Future.delayed(
                                                            const Duration(
                                                                microseconds:
                                                                    10))
                                                        .whenComplete(() => context
                                                            .read<
                                                                CartProvider>()
                                                            .clearCart());
                                                    Future.delayed(
                                                            const Duration(
                                                                microseconds:
                                                                    10))
                                                        .whenComplete(() =>
                                                            Navigator.pushNamed(
                                                                context,
                                                                CustomerHomeScreen
                                                                    .routeName));
                                                  },
                                                  width: 1,
                                                  color: Colors.lightBlueAccent)
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                //clear the cart product list
                              } else if (paymentMethod == PaymentMethods.visa) {
                                int payment = totalPaid.round() * 100;
                                makePayment(
                                    customerData, payment.toString(), "USD");
                              } else if (paymentMethod ==
                                  PaymentMethods.paypal) {
                                //   print("paypal");
                              }
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

  Map<String, dynamic>? paymentIntentData;
  Future<void> makePayment(Map<String, dynamic> customerData, String totalPrice,
      String currency) async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntentData = await createPaymentIntent(totalPrice, currency);

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            style: ThemeMode.light,
            applePay: const PaymentSheetApplePay(
              merchantCountryCode: "+92",
            ),
            googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: "US",
              testEnv: true,
            ),
            customerId: paymentIntentData!['customer'],
            merchantDisplayName: "anyName",
          ))
          .then((value) {});
      //STEP 3: Display Payment sheet
      await displayPaymentSheet(customerData);
    } catch (error) {
      throw Exception(error);
    }
  }

  createPaymentIntent(String totalPrice, String currency) async {
    try {
      Map<String, dynamic> body = {
        "amount": totalPrice, // = to 12$
        "currency": currency,
        "payment_method_types[]": "card"
      };

      await dotenv.load(fileName: ".env");
      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          //   'Authorization': 'Bearer ${dotenv.env['stripeSecretKey']}',
          'Authorization': 'Bearer $stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );
      return json.decode(response.body);
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  displayPaymentSheet(Map<String, dynamic> customerData) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        //Clear paymentIntent variable after successful payment
        paymentIntentData = null;
        //upload the orders to firebase
        setState(() {
          transactin = true;
        });
        for (var item in context.read<CartProvider>().productsList) {
          CollectionReference orderRef =
              FirebaseFirestore.instance.collection("orders");
          orderId = const Uuid().v4();
          await orderRef.doc(orderId).set({
            //customer info
            "customerId": customerData["customerId"],
            "customerName": customerData["name"],
            "customerEmail": customerData["email"],
            "customerAddress": customerData["address"],
            "customerPhone": customerData["phone"],
            "customerProfileImage": customerData["profileImage"],
            //supplier info
            "supplierId": item.supplierId,
            //produst info
            "productName": item.name,
            "productId": item.documentId,
            "order": orderId,
            "orderImage": item.imagesUrl,
            "orderQuantity": item.quentity,
            "orderPrice": item.quentity * item.price,

            //delivery info
            "deliveryStatus": "preparing",
            "deliveryDate": "",
            "orderDate": DateTime.now(),
            "paymentStatus": "paid online",
            "orderReview": false,
          }).then((value) async {
            await FirebaseFirestore.instance
                .runTransaction((transaction) async {
              DocumentReference documentReference = FirebaseFirestore.instance
                  .collection("products")
                  .doc(item.documentId);
              DocumentSnapshot documentSnapshot =
                  await transaction.get(documentReference);
              transaction.update(documentReference,
                  {"inStock": documentSnapshot["inStock"] - item.quentity});
            });
          });
        }
        setState(() {
          transactin = false;
        });
        //clear the cart product list
        Future.delayed(const Duration(microseconds: 10))
            .whenComplete(() => context.read<CartProvider>().clearCart());
        Future.delayed(const Duration(microseconds: 10)).whenComplete(
            () => Navigator.pushNamed(context, CustomerHomeScreen.routeName));
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (error) {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}

enum PaymentMethods {
  cash,
  visa,
  paypal,
}
