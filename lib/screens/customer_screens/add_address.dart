import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '/widgets/blue_button.dart';
import '/widgets/appbar_widget.dart';

class AddAddress extends StatefulWidget {
  static const routeName = "add-address";
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String firstName, lastName, phoneNumber;
  String countryValue = "Choose Country";
  String stateValue = "Choose State";
  String cityValue = "Choose City";
  bool prossecing = false;
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const AppBarTitle(title: "Add Address"),
          leading: AppBarBackButton(color: Colors.black),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 40, 0, 40),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                decoration: textFormDecoration,
                                validator: (value) => value!.isEmpty
                                    ? "Pleas enter your first name"
                                    : null,
                                onSaved: (fName) {
                                  firstName = fName!;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                decoration: textFormDecoration.copyWith(
                                  labelText: "Last name",
                                  hintText: "Enter your last name",
                                ),
                                validator: (value) => value!.isEmpty
                                    ? "Pleas enter your lasst name"
                                    : null,
                                onSaved: (lName) {
                                  lastName = lName!;
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TextFormField(
                                decoration: textFormDecoration.copyWith(
                                  labelText: "Phone number",
                                  hintText: "Enter your phone number",
                                ),
                                validator: (value) => value!.isEmpty
                                    ? "Pleas enter your phone number"
                                    : null,
                                onSaved: (phone) {
                                  phoneNumber = phone!;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SelectState(
                        onCountryChanged: (value) {
                          setState(() {
                            countryValue = value;
                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            stateValue = value;
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            cityValue = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 240,
                    ),
                    Center(
                      child: prossecing == true
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : BlueButton(
                              lable: "Add New Address",
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  if (countryValue != "Choose Country" &&
                                      stateValue != "Choose State" &&
                                      cityValue != "Choose City") {
                                    prossecing = true;
                                    formKey.currentState!.save();
                                    CollectionReference customerAddress =
                                        FirebaseFirestore.instance
                                            .collection("customers")
                                            .doc(
                                                /*FirebaseAuth
                                                .instance.currentUser!.uid*/
                                                context
                                                    .read<IdProvider>()
                                                    .getData)
                                            .collection("address");
                                    var addressId = const Uuid().v4();
                                    await customerAddress.doc(addressId).set({
                                      "addressId": addressId,
                                      "firstName": firstName,
                                      "lastName": lastName,
                                      "phoneNumber": phoneNumber,
                                      "country": countryValue,
                                      "state": stateValue,
                                      "city": cityValue,
                                      "default": true
                                    }).whenComplete(() async {
                                      await FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        DocumentReference documentReference =
                                            FirebaseFirestore.instance
                                                .collection("customers")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid);
                                        DocumentSnapshot documentSnapshot =
                                            await transaction
                                                .get(documentReference);
                                        transaction.update(documentReference, {
                                          "phone": phoneNumber,
                                          "address":
                                              "$countryValue / $stateValue / $cityValue",
                                        });
                                      });
                                      setState(() {
                                        prossecing = false;
                                        Navigator.pop(context);
                                      });
                                    });
                                  } else {
                                    SnackBarHundler.showSnackBar(
                                        scaffoldKey, "pleas set your locatuin");
                                  }
                                } else {
                                  SnackBarHundler.showSnackBar(
                                      scaffoldKey, "pleas fill all fields");
                                }
                              },
                              width: .8,
                              color: Colors.lightBlueAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

var textFormDecoration = InputDecoration(
  labelText: "First name",
  hintText: "Enter your first name",
  hintMaxLines: 1,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: const BorderSide(color: Colors.blue, width: 2),
  ),
);
