import 'package:flutter/material.dart';
import 'package:ms_customer_app/galleries/accessories_gallery_screen.dart';
import 'package:ms_customer_app/galleries/bags_gallery_screen.dart';
import 'package:ms_customer_app/galleries/beauty_gallery_screen.dart';
import 'package:ms_customer_app/galleries/electronics_gallery_screen.dart';
import 'package:ms_customer_app/galleries/home_and_garden_gallery_screen.dart';
import 'package:ms_customer_app/galleries/kids_gallery_screen.dart';
import 'package:ms_customer_app/galleries/shoes_gallery_screen.dart';
import 'package:ms_customer_app/galleries/women_gallery_screen.dart';

import '../galleries/men_gallery_screen.dart';
import '../widgets/custom_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade100.withOpacity(0.5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const CustomSearchBar(),
          bottom: const TabBar(
              isScrollable: true,
              indicatorColor: Colors.lightBlueAccent,
              indicatorWeight: 1,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                RepeatedTab(label: 'Men'),
                RepeatedTab(label: 'Women'),
                RepeatedTab(label: 'Shoes'),
                RepeatedTab(label: 'Bags'),
                RepeatedTab(label: 'Electronics'),
                RepeatedTab(label: 'Accessories'),
                RepeatedTab(label: 'Home & Garden'),
                RepeatedTab(label: 'Kisds'),
                RepeatedTab(label: 'Beauty'),
              ]),
        ),
        body: const TabBarView(children: [
          MenGalleryScreen(),
          WomenGalleryScreen(),
          ShoesGalleryScreen(),
          BagsGalleryScreen(),
          ElectronicsGalleryScreen(),
          AccessoriesGalleryScreen(),
          HomeAndGardenGalleryScreen(),
          KidsGalleryScreen(),
          BeautyGalleryScreen(),
        ]),
      ),
    );
  }
}

class RepeatedTab extends StatelessWidget {
  final String label;
  const RepeatedTab({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
