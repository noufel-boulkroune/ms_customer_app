import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storege;

import '/widgets/appbar_widget.dart';
import '/widgets/blue_button.dart';
import '/widgets/snackbar.dart';

class EditStore extends StatefulWidget {
  static const routeName = "edit-store";

  final dynamic data;
  const EditStore({super.key, this.data});

  @override
  State<EditStore> createState() => _EditStoreState();
}

class _EditStoreState extends State<EditStore> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scafoldKey =
      GlobalKey<ScaffoldMessengerState>();
  XFile? logoImageFile;
  XFile? coverImageFile;
  dynamic pickedImageError;
  late String storeName;
  late String phoneNumber;
  late String storeLogo;
  late String coverImage;
  bool processing = false;

  pickStoreLogo() async {
    try {
      final pickedStoreLogo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      );
      setState(() {
        logoImageFile = pickedStoreLogo;
      });
    } catch (error) {
      setState(() {
        pickedImageError = error;
      });
      // print(pickedImageError);
    }
  }

  pickCoverImage() async {
    try {
      final pickedCoverImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        maxWidth: 300,
        imageQuality: 95,
      );
      setState(() {
        coverImageFile = pickedCoverImage;
      });
    } catch (error) {
      setState(() {
        pickedImageError = error;
      });
      // print(pickedImageError);
    }
  }

  Future uploadStoreLogo(supplierData) async {
    if (logoImageFile != null) {
      try {
        firebase_storege.Reference reference =
            firebase_storege.FirebaseStorage.instance.ref(
          "supplier-image/${supplierData["email"]}.jpg",
        );

        await reference.putFile(File(logoImageFile!.path));

        storeLogo = await reference.getDownloadURL();
      } catch (error) {
        print(error);
      }
    } else {
      storeLogo = supplierData["storeLogo"]; // Default value
    }
  }

  Future uploadCoverImage(supplierData) async {
    if (coverImageFile != null) {
      try {
        firebase_storege.Reference reference2 =
            firebase_storege.FirebaseStorage.instance.ref(
          "supplier-image/${supplierData["email"]}.jpg-cover",
        );

        await reference2.putFile(File(coverImageFile!.path));

        coverImage = await reference2.getDownloadURL();
      } catch (error) {
        print(error);
      }
    } else {
      coverImage = supplierData["coverImage"]; // Default value
    }
  }

  editStoreData() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("suppliers")
          .doc(FirebaseAuth.instance.currentUser!.uid);
      transaction.update(documentReference, {
        "storeName": storeName,
        "storeLogo": storeLogo,
        "phone": phoneNumber,
        "coverImage": coverImage
      });
    }).whenComplete(() {
      setState(() {
        processing = false;
      });
      Navigator.pop(context);
    });
  }

  saveChanges(supplierData) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        processing = true;
      });
      // continue
      formKey.currentState!.save();
      await uploadStoreLogo(supplierData).then(
          (value) async => await uploadCoverImage(supplierData).then((value) =>
              /*RunTransaction to update the store name and phone number */
              editStoreData()));
    } else {
      SnackBarHundler.showSnackBar(scafoldKey, "please fill all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplierData = ModalRoute.of(context)?.settings.arguments as dynamic;
    return ScaffoldMessenger(
      key: scafoldKey,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const AppBarTitle(title: "Edit store"),
          leading: AppBarBackButton(color: Colors.black),
        ),
        body: supplierData == null || processing == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            const Text("Store Logo",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(supplierData["storeLogo"]),
                                ),
                                logoImageFile == null
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey.shade200,
                                        child: const Center(
                                          child: Text(
                                            "Pick new image",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: FileImage(
                                            File(logoImageFile!.path)),
                                      ),
                                logoImageFile == null
                                    ? BlueButton(
                                        lable: "Change",
                                        onPressed: () {
                                          pickStoreLogo();
                                        },
                                        width: .3,
                                        color: Colors.lightBlueAccent)
                                    : BlueButton(
                                        lable: "Reset",
                                        onPressed: () {
                                          setState(() {
                                            logoImageFile = null;
                                          });

                                          pickStoreLogo();
                                        },
                                        width: .3,
                                        color: Colors.lightBlueAccent,
                                      ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              child: Divider(
                                color: Colors.lightBlueAccent,
                                thickness: 2.5,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Cover Image",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                supplierData["coverImage"] == ""
                                    ? const CircleAvatar(
                                        radius: 60,
                                        backgroundImage: AssetImage(
                                            "assets/images/inapp/coverimage.jpg"),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(
                                            supplierData["coverImage"]),
                                      ),
                                coverImageFile == null
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey.shade200,
                                        child: const Center(
                                          child: Text(
                                            "Pick new image",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundImage: FileImage(
                                            File(coverImageFile!.path)),
                                      ),
                                coverImageFile == null
                                    ? BlueButton(
                                        lable: "Change",
                                        onPressed: () {
                                          pickCoverImage();
                                        },
                                        width: .3,
                                        color: Colors.lightBlueAccent)
                                    : BlueButton(
                                        lable: "Reset",
                                        onPressed: () {
                                          setState(() {
                                            coverImageFile = null;
                                          });

                                          pickStoreLogo();
                                        },
                                        width: .3,
                                        color: Colors.lightBlueAccent,
                                      ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              child: Divider(
                                color: Colors.lightBlueAccent,
                                thickness: 2.5,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "please enter your store name";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              storeName = newValue!;
                            },
                            initialValue: supplierData["storeName"],
                            maxLength: 100,
                            decoration: textFormDecoration.copyWith(
                                labelText: "Store Name",
                                hintText: "Enter Store Name"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "please enter your phone number";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              phoneNumber = newValue!;
                            },
                            initialValue: supplierData["phone"],
                            decoration: textFormDecoration.copyWith(
                                labelText: "Phone",
                                hintText: "Enter your phone number"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BlueButton(
                                  lable: "Cancel",
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  width: .4,
                                  color: Colors.lightBlueAccent),
                              BlueButton(
                                  lable: "Save Changes",
                                  onPressed: () {
                                    saveChanges(supplierData);
                                  },
                                  width: .4,
                                  color: Colors.lightBlueAccent),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
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
