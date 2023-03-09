import 'package:flutter/material.dart';

import '../screens/minor_screen/search_screen.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.search,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const Expanded(
                child: Text(
                  "What are you looking for?",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              Container(
                height: 32,
                width: 75,
                decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                    child: Text(
                  "Search",
                  style: TextStyle(fontSize: 16),
                )),
              )
            ],
          ),
        ));
  }
}
