import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../models/product_data_model.dart';

class HomeAndGardenGalleryScreen extends StatefulWidget {
  const HomeAndGardenGalleryScreen({super.key});

  @override
  State<HomeAndGardenGalleryScreen> createState() =>
      _HomeAndGardenGalleryScreenState();
}

class _HomeAndGardenGalleryScreenState
    extends State<HomeAndGardenGalleryScreen> {
  final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
      .collection('products')
      .where("mainCategory", isEqualTo: "home & garden")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
    );
  }
}
