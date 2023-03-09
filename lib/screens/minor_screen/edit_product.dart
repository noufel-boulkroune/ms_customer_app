import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storege;
import 'package:ms_customer_app/widgets/blue_button.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../widgets/snackbar.dart';
import '/utilities/category_list.dart';

class EditProduct extends StatefulWidget {
  static const routeName = "edit-product";

  const EditProduct({
    super.key,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scafoldKey =
      GlobalKey<ScaffoldMessengerState>();

  final supplierUid = FirebaseAuth.instance.currentUser!.uid;
  late double price;
  int discount = 0;
  late int quantity;
  late String productName;
  late String productDescription;
  late String productId;
  String? mainCategoryValue = mainCategory[0];
  String? subCategoryValue = men[0];
  List<String> subCategoryList = [];

  List<XFile> _imagesFileList = [];
  List<dynamic> _imagesUrlList = [];
  // dynamic _pickedImageError;

  bool processing = false;
  bool deletProccesing = false;

  var uuid = const Uuid();

  @override
  void initState() {
    subCategoryList = men;
    super.initState();
  }

  void pickProductImages() async {
    try {
      await ImagePicker()
          .pickMultiImage(
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      )
          .then((value) {
        setState(() {
          _imagesFileList = value;
        });
      });
    } catch (error) {
      setState(() {
        // _pickedImageError = error;
      });
      // print(_pickedImageError);
    }
  }

  Widget previewImages() {
    if (_imagesFileList.isNotEmpty) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return Image.file(
            File(_imagesFileList[index].path),
            fit: BoxFit.fill,
          );
        },
        itemCount: _imagesFileList.length,
      );
    } else {
      return const Center(
        child: Text(
          "You didn't \n pick images",
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget previewCurrentImages(productData) {
    List<dynamic> productImages = productData["productImages"];
    return ListView.builder(
      itemCount: productImages.length,
      itemBuilder: (context, index) {
        return Image.network(productImages[index]);
      },
    );
  }

  Future uploadImages(productData) async {
    if (_imagesFileList.isNotEmpty) {
      try {
        setState(() {
          _imagesUrlList = [];
        });

        for (var image in _imagesFileList) {
          firebase_storege.Reference reference =
              firebase_storege.FirebaseStorage.instance.ref(
            "product-images/${path.basename(image.path)}.jpg",
          );
          await reference.putFile(File(image.path)).whenComplete(() async {
            await reference.getDownloadURL().then((value) {
              _imagesUrlList.add(value);
            });
          });
        }
        //upload data
      } catch (error) {
        //  print(error);
      }
    } else {
      _imagesUrlList = productData["productImages"];
    }
  }

  Future editProductData(productData) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("products")
          .doc(productData["productId"]);

      transaction.update(documentReference, {
        "mainCategory": mainCategoryValue,
        "subCaategory": subCategoryValue,
        "price": price,
        "inStock": quantity,
        "productName": productName,
        "productDescription": productDescription,
        "productImages": _imagesUrlList,
        "discount": discount,
      });
    });
  }

  void saveChanges(productData) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        processing = true;
      });
      await uploadImages(productData).then((value) => subcategorySelector());
      editProductData(productData);
      setState(() {
        processing = false;
      });
      Future.delayed(const Duration(microseconds: 10))
          .then((value) => Navigator.pop(context));
    } else {
      SnackBarHundler.showSnackBar(_scafoldKey, "pleas fill all fields");
    }
  }

  void subcategorySelector() {
    switch (mainCategoryValue) {
      case "women":
        {
          subCategoryList = women;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "electronics":
        {
          subCategoryList = electronics;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "accessories":
        {
          subCategoryList = accessories;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "shoes":
        {
          subCategoryList = shoes;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "home & garden":
        {
          subCategoryList = homeAndGarden;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "beauty":
        {
          subCategoryList = beauty;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "kids":
        {
          subCategoryList = kids;
          subCategoryValue = subCategoryList[0];
        }
        break;
      case "bags":
        {
          subCategoryList = bags;
          subCategoryValue = subCategoryList[0];
        }
        break;

      default:
        {
          subCategoryList = men;
          subCategoryValue = subCategoryList[0];
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final productData = ModalRoute.of(context)?.settings.arguments as dynamic;
    return ScaffoldMessenger(
      key: _scafoldKey,
      child: Scaffold(
        body: deletProccesing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // pickProductImages();
                                    },
                                    child: Container(
                                        color: Colors.blueGrey.shade100,
                                        width: size.width * 0.45,
                                        height: size.width * 0.45,
                                        child:
                                            previewCurrentImages(productData)),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: size.width * 0.45,
                                height: size.width * 0.45,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Current main category",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      margin: const EdgeInsets.all(6),
                                      constraints: BoxConstraints(
                                          maxWidth: size.width * .35),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlueAccent.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                          child: Text(
                                              productData["mainCategory"])),
                                    ),
                                    const Text(
                                      "Current subcategory",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      margin: const EdgeInsets.all(6),
                                      constraints: BoxConstraints(
                                          maxWidth: size.width * .35),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlueAccent.shade100,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                          child: Text(
                                              productData["subCaategory"])),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          ExpandablePanel(
                              header: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Change Image & Categories",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              collapsed: const SizedBox(),
                              expanded: SizedBox(child: changeIamges(size)))
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Divider(
                          color: Colors.lightBlueAccent,
                          thickness: 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size.width * .4,
                                child: TextFormField(
                                  initialValue:
                                      productData["price"].toStringAsFixed(2),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Pleas enter product price";
                                    } else if (value.isValidPrice() != true) {
                                      return "invalid price";
                                    } else {
                                      return null;
                                    }
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: textFormDecoration.copyWith(
                                    labelText: "Price",
                                    hintText: "Price ..\$",
                                  ),
                                  onSaved: (value) =>
                                      price = double.parse(value!),
                                ),
                              ),
                              SizedBox(
                                width: size.width * .4,
                                child: TextFormField(
                                  // maxLength: 2,
                                  initialValue:
                                      productData["discount"].toString(),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return null;
                                    } else if (value.isValidDiscount() !=
                                        true) {
                                      return "invalid discount";
                                    } else if (value.length > 2) {
                                      return "invalid discount. max 2 numbers ";
                                    }
                                    return null;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: textFormDecoration.copyWith(
                                    labelText: "Discount",
                                    hintText: "Discount ..%",
                                  ),
                                  onSaved: (value) => discount =
                                      value == "" || value == null
                                          ? 0
                                          : int.parse(value),
                                ),
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: TextFormField(
                          initialValue: productData["inStock"].toString(),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Pleas enter the quentity";
                            } else if (value.isValidQuentity() != true) {
                              return "invalid quentity";
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: textFormDecoration.copyWith(
                            labelText: "Quetity",
                            hintText: "Add quantity",
                          ),
                          onSaved: (value) => quantity = int.parse(value!),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: TextFormField(
                          initialValue: productData["productName"],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Pleas enter product name";
                            } else {
                              return null;
                            }
                          },
                          maxLength: 100,
                          maxLines: 3,
                          decoration: textFormDecoration.copyWith(
                            labelText: "Product name",
                            hintText: "Enter product name",
                          ),
                          onSaved: (newValue) => productName = newValue!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: TextFormField(
                          initialValue: productData["productDescription"],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Pleas enter product description";
                            } else {
                              return null;
                            }
                          },
                          maxLength: 800,
                          maxLines: 5,
                          decoration: textFormDecoration.copyWith(
                            labelText: "product description",
                            hintText: "Enter product description",
                          ),
                          onSaved: (newValue) => productDescription = newValue!,
                        ),
                      ),
                      processing
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: BlueButton(
                                  lable: "Save changes",
                                  onPressed: () {
                                    saveChanges(productData);
                                  },
                                  width: .90,
                                  color: Colors.lightBlueAccent),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          BlueButton(
                              lable: "Delete",
                              onPressed: () async {
                                setState(() {
                                  deletProccesing = true;
                                });
                                await FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  DocumentReference documentReference =
                                      FirebaseFirestore.instance
                                          .collection("products")
                                          .doc(productData["productId"]);
                                  transaction.delete(documentReference);
                                }).then((value) {
                                  setState(() {
                                    deletProccesing = false;
                                  });
                                  Navigator.pop(context);
                                });
                              },
                              width: .4,
                              color: Colors.pink.shade200),
                          BlueButton(
                              lable: "Cancel",
                              onPressed: () => Navigator.pop(context),
                              width: .4,
                              color: Colors.lightBlueAccent),
                        ],
                      )
                    ]),
                  ),
                ),
              ),
      ),
    );
  }

  Widget changeIamges(Size size) {
    return Column(
      children: [
        Row(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    pickProductImages();
                  },
                  child: Container(
                      color: Colors.blueGrey.shade100,
                      width: size.width * 0.45,
                      height: size.width * 0.45,
                      child: _imagesFileList != []
                          ? previewImages()
                          : const Center(
                              child: Text(
                                "You didn't \n pick images",
                                textAlign: TextAlign.center,
                              ),
                            )),
                ),
                _imagesFileList == []
                    ? const SizedBox()
                    : Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _imagesFileList = [];
                            });
                          },
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: size.width * 0.45,
              height: size.width * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Select main category",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton(
                    iconSize: 30,
                    menuMaxHeight: 300,
                    isExpanded: true,
                    alignment: Alignment.center,
                    value: mainCategoryValue,
                    items: mainCategory.map((mainCategoryName) {
                      return DropdownMenuItem(
                        value: mainCategoryName,
                        child: Text(mainCategoryName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        mainCategoryValue = value;
                        subcategorySelector();
                      });
                    },
                  ),
                  const Text(
                    "Select subcategory",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton(
                    iconSize: 30,
                    alignment: Alignment.center,
                    isExpanded: true,
                    menuMaxHeight: 300,
                    value: subCategoryValue,
                    items: subCategoryList.map((subCategoryName) {
                      return DropdownMenuItem(
                        value: subCategoryName,
                        child: Text(subCategoryName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        subCategoryValue = value;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _imagesFileList != []
              ? BlueButton(
                  lable: "Chnge Images",
                  onPressed: () {
                    pickProductImages();
                  },
                  width: .4,
                  color: Colors.lightBlueAccent)
              : BlueButton(
                  lable: "Reset Images",
                  onPressed: () {
                    setState(() {
                      _imagesFileList = [];
                    });
                  },
                  width: .4,
                  color: Colors.lightBlueAccent),
        )
      ],
    );
  }
}

var textFormDecoration = InputDecoration(
  labelText: "Price",
  hintText: "Price ..\$",
  //labelStyle: TextStyle(color: Colors.blue),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.lightBlueAccent)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.blue, width: 2)),
);

extension QuantityValidator on String {
  bool isValidQuentity() {
    return RegExp(r'^[1-9][0-9]*$').hasMatch(this);
  }
}

extension PriceValidator on String {
  bool isValidPrice() {
    return RegExp(r'^((([1-9][0-9]*[\.]*)||([0][\.]))([0-9]{1,2}))$')
        .hasMatch(this);
  }
}

extension DiscountValidator on String {
  bool isValidDiscount() {
    return RegExp(r'^([0-9]{1,2})$').hasMatch(this);
  }
}
