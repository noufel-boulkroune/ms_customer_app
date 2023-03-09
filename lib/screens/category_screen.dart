import 'package:flutter/material.dart';
import 'package:ms_customer_app/screens/categorys_screens/women_category_screen.dart';
import 'package:ms_customer_app/widgets/custom_search_bar.dart';

import 'categorys_screens/accessories_category_screen.dart';
import 'categorys_screens/bags_category_screen.dart';
import 'categorys_screens/beauty_category_screen.dart';
import 'categorys_screens/electronics_category_screen.dart';
import 'categorys_screens/home_and_garden_category_screen.dart';
import 'categorys_screens/kids_category_screen.dart';
import 'categorys_screens/men_category_screen.dart';
import 'categorys_screens/shoes_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

List<ItemData> items = [
  ItemData(lable: 'men'),
  ItemData(lable: 'women'),
  ItemData(lable: 'electronics'),
  ItemData(lable: 'accessories'),
  ItemData(lable: 'shoes'),
  ItemData(lable: 'home & garden'),
  ItemData(lable: 'beauty'),
  ItemData(lable: 'kids'),
  ItemData(lable: 'bags'),
];

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    for (var element in items) {
      element.isSelected = false;
    }

    items[0].isSelected = true;

    super.initState();
  }

  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const CustomSearchBar(),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            child: sideNavigator(size),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: categoryView(size),
          ),
        ],
      ),
    );
  }

  Widget categoryView(Size size) {
    return Container(
      height: size.height * .80,
      width: size.width * 0.8,
      decoration: const BoxDecoration(color: Colors.white),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            for (var element in items) {
              element.isSelected = false;
            }
            setState(() {
              items[index].isSelected = true;
            });
          });
        },
        scrollDirection: Axis.vertical,
        children: const [
          MenCategoryScreen(),
          WomenCategoryScreen(),
          ElectronicsCategoryScreen(),
          AccessoriesCategoryScreen(),
          ShoesCategoryScreen(),
          HomeAndGardenCategoryScreen(),
          BeautyCategoryScreen(),
          KidsCategoryScreen(),
          BagsCategoryScreen(),
        ],
      ),
    );
  }

  Widget sideNavigator(Size size) {
    return SizedBox(
      height: size.height * .8,
      width: size.width * 0.2,
      // decoration: BoxDecoration(color: Colors.grey.shade400),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(microseconds: 300),
              curve: Curves.fastOutSlowIn,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            height: 80,
            color:
                items[index].isSelected ? Colors.white : Colors.grey.shade300,
            child: Center(
                child: Text(
              items[index].lable,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            )),
          ),
        ),
      ),
    );
  }
}

class ItemData {
  String lable;
  bool isSelected;
  ItemData({required this.lable, this.isSelected = false});
}
