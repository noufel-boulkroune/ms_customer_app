import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ms_customer_app/widgets/appbar_widget.dart';

import 'minor_screen/visit_store_screen.dart';

class StoresScreen extends StatelessWidget {
  StoresScreen({super.key});
  final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
      .collection('suppliers')
      // .where("mainCategory", isEqualTo: "home & garden")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const AppBarTitle(title: "Stors"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _productsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Image(
                  image: AssetImage("assets/svgs/loading-animation-blue.gif"),
                ),
              );
            }

            if (snapshot.hasData) {
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
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 15,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VisitStoreScreen(
                              supplierId: data[index]["supplierId"],
                            ),
                          ));
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            data[index]["storeLogo"],
                          ),

                          maxRadius: 50,
                          // child: Image.network(
                          //   data[index]["storeLogo"],
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        Text(
                          data[index]["storeName"].toString().toLowerCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const Text('Something went wrong');
          },
        ),
      ),
    );
  }
}
