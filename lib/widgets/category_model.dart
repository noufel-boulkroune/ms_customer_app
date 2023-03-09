import 'package:flutter/material.dart';

import '../screens/minor_screen/sub_category_products.dart';

class SliderBar extends StatelessWidget {
  final String mainCategoryName;
  const SliderBar({
    Key? key,
    required this.size,
    required this.mainCategoryName,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      height: size.height * .8,
      width: size.width * .05,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(50),
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              mainCategoryName == "kids"
                  ? Text(
                      "<<",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade300,
                          letterSpacing: 10,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    )
                  : const Text(
                      "<<",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          letterSpacing: 10,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
              Text(
                mainCategoryName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.lightBlueAccent,
                    letterSpacing: 10,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              mainCategoryName == "men"
                  ? Text(
                      ">>",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade300,
                          letterSpacing: 10,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    )
                  : const Text(
                      ">>",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.lightBlueAccent,
                          letterSpacing: 10,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubCategoryModel extends StatelessWidget {
  final String mainCategoryName;
  final String subCategoryName;
  final String imageName;
  final String subCategoryLable;
  const SubCategoryModel({
    Key? key,
    required this.mainCategoryName,
    required this.subCategoryName,
    required this.imageName,
    required this.subCategoryLable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategoryProducts(
                subCategoryName: subCategoryName,
                mainCategoryName: mainCategoryName,
              ),
            ));
      },
      child: Column(
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Image.asset(
              imageName,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            subCategoryLable,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CategoryHeaderLable extends StatelessWidget {
  final String headerLable;
  const CategoryHeaderLable({
    Key? key,
    required this.headerLable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Text(
        headerLable,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.blue),
      ),
    );
  }
}
