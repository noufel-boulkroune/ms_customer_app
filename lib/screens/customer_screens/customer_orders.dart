import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';

import '../../models/customer_order_model.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> orderStream = FirebaseFirestore.instance
        .collection("orders")
        .where("customerId", isEqualTo: context.read<IdProvider>().getData)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const AppBarTitle(title: "Orders"),
        leading: AppBarBackButton(
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Material(
              color: Colors.white,
              child: Center(
                child: Image(
                  image: AssetImage("assets/svgs/loading-animation-blue.gif"),
                ),
              ),
            );
          }
          final order = snapshot.data!.docs;
          if (order.isEmpty) {
            return const Center(
              child: Text(
                "You Have Not \n\n Active Orders !",
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
              itemCount: order.length,
              itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: Colors.lightBlueAccent),
                      borderRadius: BorderRadius.circular(15)),
                  child: CustomerOrderModel(
                    order: order[index],
                  )));
        },
      ),
    );
  }
}
