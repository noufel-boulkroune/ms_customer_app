import 'package:flutter/material.dart';
import 'package:ms_customer_app/utilities/category_list.dart';

import '../../widgets/category_model.dart';

class ShoesCategoryScreen extends StatelessWidget {
  const ShoesCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Stack(children: [
        Positioned(
          bottom: 0,
          left: 0,
          child: SizedBox(
            height: size.height * .8,
            width: size.width * .74,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CategoryHeaderLable(headerLable: 'Shoes'),
                SizedBox(
                  height: size.height * 0.71,
                  child: GridView.count(
                    mainAxisSpacing: 35,
                    crossAxisSpacing: 15,
                    crossAxisCount: 3,
                    children: List.generate(shoes.length, (index) {
                      return SubCategoryModel(
                        imageName: 'assets/images/shoes/shoes$index.jpg',
                        mainCategoryName: 'shoes',
                        subCategoryName: shoes[index],
                        subCategoryLable: shoes[index],
                      );
                    }),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: SliderBar(
            size: size,
            mainCategoryName: 'shoes',
          ),
        )
      ]),
    );
  }
}
