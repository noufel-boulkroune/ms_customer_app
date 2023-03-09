import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:ms_customer_app/screens/customer_home_screen.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../models/product_data_model.dart';

class ShoesGalleryScreen extends StatefulWidget {
  final bool fromOnboarding;
  const ShoesGalleryScreen({super.key, this.fromOnboarding = false});

  @override
  State<ShoesGalleryScreen> createState() => _ShoesGalleryScreenState();
}

class _ShoesGalleryScreenState extends State<ShoesGalleryScreen> {
  final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
      .collection('products')
      .where("mainCategory", isEqualTo: "shoes")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromOnboarding == true
          ? AppBar(
              title: const AppBarTitle(title: "Shoes"),
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                ),
                onPressed: (() {
                  Navigator.pushReplacementNamed(
                      context, CustomerHomeScreen.routeName);
                }),
              ))
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
    );
  }
}
