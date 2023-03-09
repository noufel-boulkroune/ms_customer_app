import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../models/product_data_model.dart';

class VisitStoreScreen extends StatefulWidget {
  final String supplierId;

  const VisitStoreScreen({super.key, required this.supplierId});

  @override
  State<VisitStoreScreen> createState() => _VisitStoreScreenState();
}

class _VisitStoreScreenState extends State<VisitStoreScreen> {
  bool following = false;
  String customerId = "";
  List<String> subscriptionsList = [];

  checkUserSubscriptions() {
    FirebaseFirestore.instance
        .collection("suppliers")
        .doc(widget.supplierId)
        .collection("subscriptions")
        .get()
        .then((QuerySnapshot subscriptions) {
      for (var doc in subscriptions.docs) {
        subscriptionsList.add(doc["cutomerId"]);
      }
    }).whenComplete(() {
      following =
          subscriptionsList.contains(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  subscribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('topic');
    String customerId = FirebaseFirestore.instance
        .collection("customers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .id;
    FirebaseFirestore.instance
        .collection("suppliers")
        .doc(widget.supplierId)
        .collection("subscriptions")
        .doc(customerId)
        .set({"cutomerId": customerId});
    setState(() {
      following = true;
    });
  }

  unsubscibeFromTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('topic');
    String customerId = FirebaseFirestore.instance
        .collection("customers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .id;
    FirebaseFirestore.instance
        .collection("suppliers")
        .doc(widget.supplierId)
        .collection("subscriptions")
        .doc(customerId)
        .delete();
    setState(() {
      following = false;
    });
  }

  @override
  void initState() {
    customerId = context.read<IdProvider>().getData;
    customerId == "" ? null : checkUserSubscriptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference suppliers =
        FirebaseFirestore.instance.collection('suppliers');

    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .where("supplierId", isEqualTo: widget.supplierId)
        .snapshots();

    return FutureBuilder<DocumentSnapshot>(
      future: suppliers.doc(widget.supplierId).get(),
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
            color: Colors.white,
            child: Center(
              child: Image(
                image: AssetImage("assets/svgs/loading-animation-blue.gif"),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              leading: AppBarBackButton(
                color: Colors.white,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: Colors.lightBlueAccent,
                        ),
                        borderRadius: BorderRadius.circular(15)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data["storeLogo"],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data["storeName"].toString().toUpperCase(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: 35,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                                color: Colors.lightBlueAccent.withOpacity(.7),
                                border:
                                    Border.all(width: 1, color: Colors.white),
                                borderRadius: BorderRadius.circular(25)),
                            child:
                                // data["supplierId"] ==
                                //         FirebaseAuth.instance.currentUser!.uid
                                //     ? MaterialButton(
                                //         onPressed: () {
                                //           setState(() {
                                //             Navigator.pushNamed(
                                //                 context, EditStore.routeName,
                                //                 arguments: data);
                                //           });
                                //         },
                                //         child: Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceBetween,
                                //           children: const [
                                //             Text(
                                //               "EDIT",
                                //               style: TextStyle(color: Colors.white),
                                //             ),
                                //             Icon(
                                //               Icons.edit,
                                //               color: Colors.white,
                                //             )
                                //           ],
                                //         ))
                                // :
                                MaterialButton(
                              onPressed: following == false
                                  ? () {
                                      subscribeToTopic();
                                    }
                                  : () {
                                      unsubscibeFromTopic();
                                    },
                              child: following
                                  ? const Text(
                                      "FOLLOWING",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  : const Text(
                                      "FOLLOW",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ))
                      ],
                    ),
                  )
                ],
              ),
              toolbarHeight: 100,
              flexibleSpace: data["coverImage"] == ""
                  ? Image.asset(
                      "assets/images/inapp/coverimage.jpg",
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      data["coverImage"],
                      fit: BoxFit.cover,
                    ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: productsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Material(
                    child: Center(
                      child: Image(
                        image: AssetImage(
                            "assets/svgs/loading-animation-blue.gif"),
                      ),
                    ),
                  );
                }
                final data = snapshot.data!.docs;
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "This stored \n has no items yet !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return StaggeredGridView.countBuilder(
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
                );
              },
            ),
            floatingActionButton:
                data["supplierId"] == FirebaseAuth.instance.currentUser!.uid
                    ? null
                    : FloatingActionButton(
                        backgroundColor: Colors.lightBlueAccent,
                        onPressed: () {},
                        child: const Icon(Icons.phone),
                      ),
          );
        }

        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Image(
              image: AssetImage("assets/svgs/loading-animation-blue.gif"),
            ),
          ),
        );
      },
    );
  }
}
