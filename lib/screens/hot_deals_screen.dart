import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/screens/customer_home_screen.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../models/product_data_model.dart';

class HotDealsScreen extends StatefulWidget {
  final bool fromOnboarding;
  final String maxDiscount;
  const HotDealsScreen(
      {super.key, this.fromOnboarding = false, required this.maxDiscount});

  @override
  State<HotDealsScreen> createState() => _HotDealsScreenState();
}

class _HotDealsScreenState extends State<HotDealsScreen> {
  final Stream<QuerySnapshot> _productsStream = FirebaseFirestore.instance
      .collection('products')
      .where("discount", isNotEqualTo: 0)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        leading: widget.fromOnboarding == true
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, CustomerHomeScreen.routeName);
                },
              )
            : AppBarBackButton(color: Colors.white),
        title: SizedBox(
          height: 160,
          child: Stack(
            children: [
              Positioned(
                left: 30,
                top: 68,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    height: 1.2,
                    color: Colors.white,
                    fontSize: 30,
                  ),
                  child: AnimatedTextKit(
                    totalRepeatCount: 5,
                    animatedTexts: [
                      TyperAnimatedText(
                        "    Hot Deal    ",
                        speed: const Duration(microseconds: 60),
                      ),
                      TyperAnimatedText(
                        "Up to ${widget.maxDiscount} % off",
                        speed: const Duration(microseconds: 60),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 60,
            color: Colors.lightBlue,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _productsStream,
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
            ),
          ),
        ],
      ),
    );
  }
}
