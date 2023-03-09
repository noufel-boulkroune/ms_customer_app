import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:ms_customer_app/widgets/auth_widgets.dart';
import 'package:ms_customer_app/widgets/blue_button.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:ms_customer_app/widgets/snackbar.dart';

class UpdatePassword extends StatefulWidget {
  static const routeName = "update-password";
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool checkPassword = true;
  bool proccesing = false;
  String? email = FirebaseAuth.instance.currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: AppBarBackButton(color: Colors.black),
          title: const AppBarTitle(title: "Change Password?"),
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 30),
            child: SingleChildScrollView(
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "To change your passeord \n\n pleas fill the form below and click Save Changes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: oldPasswordController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Pleas enter your old password";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: textFormDecoration.copyWith(
                            labelText: "Old password",
                            hintText: "Enter your old password",
                            errorText: checkPassword != true
                                ? "Not valide password"
                                : null),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: newPasswordController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Pleas enter your password";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: textFormDecoration.copyWith(
                          labelText: "New password",
                          hintText: "Enter your new password",
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        //controller: newPasswordController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Pleas enter your password";
                          } else if (value != newPasswordController.text) {
                            return "Password not matching";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: textFormDecoration.copyWith(
                          labelText: "Confirm password",
                          hintText: "Enter your new password",
                        ),
                      ),
                    ),

                    //

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlutterPwValidator(
                          controller: newPasswordController,
                          minLength: 8,
                          uppercaseCharCount: 1,
                          numericCharCount: 2,
                          specialCharCount: 1,
                          width: 400,
                          height: 150,
                          onSuccess: () {},
                          onFail: () {}),
                    ),

                    //
                    const SizedBox(
                      height: 20,
                    ),
                    proccesing == true
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : BlueButton(
                            lable: "Save Changes",
                            onPressed: () async {
                              setState(() {
                                proccesing = true;
                              });

                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                try {
                                  //check if the new password match the old one

                                  checkPassword = (await FirebaseAuth
                                              .instance.currentUser!
                                              .reauthenticateWithCredential(
                                                  EmailAuthProvider.credential(
                                                      email: email!,
                                                      password:
                                                          oldPasswordController
                                                              .text)))
                                          .user !=
                                      null;
                                  setState(() {});

                                  await FirebaseAuth.instance.currentUser!
                                      .updatePassword(
                                          newPasswordController.text)
                                      .then((value) async {
                                    formKey.currentState!.reset();
                                    newPasswordController.clear();
                                    oldPasswordController.clear();
                                    SnackBarHundler.showSnackBar(scaffoldKey,
                                        "You password has been updated");
                                    Future.delayed(const Duration(seconds: 3))
                                        .then((value) {
                                      setState(() {
                                        proccesing = false;
                                      });
                                      Navigator.pop(context);
                                    });
                                  });
                                } catch (error) {
                                  checkPassword = false;
                                  print(error);
                                  setState(() {
                                    proccesing = false;
                                  });
                                }
                              } else {
                                print("form not valid");
                                setState(() {
                                  proccesing = false;
                                });
                              }
                            },
                            width: .8,
                            color: Colors.lightBlueAccent)
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
