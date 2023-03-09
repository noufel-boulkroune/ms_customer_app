import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/screens/customer_home_screen.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../models/product_data_model.dart';
import '../../widgets/appbar_widget.dart';

class SubCategoryProducts extends StatelessWidget {
  final String subCategoryName;
  final String mainCategoryName;
  final bool fromOnboardingScreen;
  const SubCategoryProducts(
      {super.key,
      required this.subCategoryName,
      required this.mainCategoryName,
      this.fromOnboardingScreen = false});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .where("mainCategory", isEqualTo: mainCategoryName)
        .where("subCaategory", isEqualTo: subCategoryName)
        .snapshots();
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: fromOnboardingScreen == false
                ? AppBarBackButton(
                    color: Colors.black,
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, CustomerHomeScreen.routeName);
                    },
                  ),
            title: AppBarTitle(title: subCategoryName)),
        body: StreamBuilder<QuerySnapshot>(
          stream: productsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Material(
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
        ));
  }
}
