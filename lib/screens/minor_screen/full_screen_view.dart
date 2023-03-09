import 'package:flutter/material.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';

class FullScreenView extends StatefulWidget {
  final List<dynamic> imagesList;
  const FullScreenView({super.key, required this.imagesList});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

final PageController _controller = PageController();

class _FullScreenViewState extends State<FullScreenView> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<dynamic> imagesList = widget.imagesList;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: AppBarBackButton(
          color: Colors.black,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
              child: Text(
            "${pageIndex + 1} / ${imagesList.length}",
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 4,
            ),
          )),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: size.height * .4,
            child: PageView(
              onPageChanged: (value) {
                setState(() {
                  pageIndex = value;
                });
              },
              controller: _controller,
              children: List.generate(
                imagesList.length,
                (index) => InteractiveViewer(
                  child: Image(
                    image: NetworkImage(
                      imagesList[index].toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            height: size.height * .22,
            // width: size.width * .3,
            child: ListImagesView(imagesList),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ListImagesView(List imagesList) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imagesList.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          _controller.jumpToPage(index);
        },
        child: Container(
          width: 120,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 4, color: Colors.lightBlueAccent)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imagesList[index].toString(),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
