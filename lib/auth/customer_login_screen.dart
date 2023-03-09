import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:ms_customer_app/auth/customer_signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:provider/provider.dart';

import '../screens/customer_home_screen.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/snackbar.dart';
import 'forgot_password.dart';

class CustomerLoginScreen extends StatefulWidget {
  static const routeName = "customer_login";
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

final TextEditingController _emailControler = TextEditingController();
final TextEditingController _passwordControler = TextEditingController();

CollectionReference customers =
    FirebaseFirestore.instance.collection("customers");

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String email, password, profileImage;
  bool processing = false;
  bool docExists = false;
  bool passwordVisibility = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scafoldKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<bool> checkIfDocExists(docId) async {
    try {
      var doc = await customers.doc(docId).get();
      return doc.exists;
    } catch (error) {
      return false;
    }
  }

  setId(user) {
    context.read<IdProvider>().setCustomerId(user);
  }

  Future<UserCredential> signInWithGoogle() async {
    // setState(() {
    //   processing = true;
    // });

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance
        .signInWithCredential(credential)
        .whenComplete(() async {
      User user = FirebaseAuth.instance.currentUser!;
      docExists = await checkIfDocExists(user.uid);
      docExists == false
          ? await customers.doc(user.uid).set({
              "name": user.displayName,
              "email": user.email,
              "profileImage": user.photoURL,
              "phone": "",
              "address": "",
              "customerId": user.uid
            }).whenComplete(() async {
              setId(user);
              // final SharedPreferences pref = await _prefs;
              // pref.setString("customerId", user.uid);
              setState(() {
                processing = false;
              });
              Future.delayed(const Duration(microseconds: 10)).then((value) =>
                  Navigator.pushNamed(context, CustomerHomeScreen.routeName));
            })
          : () {
              setState(() {
                processing = false;
              });
              Navigator.pushNamed(context, CustomerHomeScreen.routeName);
            };
    });
  }

  @override
  void dispose() {
    _emailControler.dispose();
    _passwordControler.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _emailControler;
    _passwordControler;
    super.initState();
  }

  void login() async {
    setState(() {
      processing = true;
    });
    //
    if (_formKey.currentState!.validate()) {
      setState(() {
        email = _emailControler.text;
        password = _passwordControler.text;
      });
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((value) async {
          setState(() {
            processing = false;
          });
          User user = FirebaseAuth.instance.currentUser!;
          setId(user);
          // User user = FirebaseAuth.instance.currentUser!;
          // final SharedPreferences pref = await _prefs;
          // pref.setString("customerId", user.uid);
          await FirebaseAuth.instance.currentUser!.reload();

          if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
            setState(() {
              _formKey.currentState!.reset();
              processing = false;
            });
            await Future.delayed(const Duration(microseconds: 10)).whenComplete(
                () => Navigator.pushReplacementNamed(
                    context, CustomerHomeScreen.routeName));
          } else {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Email verification"),
                content: const Text("Please verify your email before Login"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        processing = false;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Ok"),
                  ),
                  TextButton(
                    onPressed: () {
                      try {
                        FirebaseAuth.instance.currentUser!
                            .sendEmailVerification();
                      } catch (error) {
                        print(error);
                      }
                      setState(() {
                        processing = false;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Resend"),
                  ),
                ],
              ),
            );
          }
        });
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {
          SnackBarHundler.showSnackBar(
            _scafoldKey,
            "No user found for that email.",
          );
          setState(() {
            processing = false;
          });
        } else if (error.code == 'wrong-password') {
          SnackBarHundler.showSnackBar(
            _scafoldKey,
            "Wrong password provided for that user.",
          );
          setState(() {
            processing = false;
          });
        }
      }
    } else {
      SnackBarHundler.showSnackBar(_scafoldKey, "Pleas fill all fields");
      setState(() {
        processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scafoldKey,
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * .94,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const AuthHeaderLable(
                      headerLable: 'Log In',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFormField(
                            controller: _emailControler,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Pleas enter your Email";
                              } else if (value.isValidEmail() == false) {
                                return "invalide email";
                              } else if (value.isValidEmail() == true) {
                                null;
                              }

                              return null;
                            },
                            decoration: textFormDecoration.copyWith(
                                labelText: "Email Adress",
                                hintText: "Enter your email")),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                            controller: _passwordControler,
                            obscureText: !passwordVisibility,
                            validator: (value) => value!.isEmpty
                                ? "Pleas enter your Password"
                                : null,
                            decoration: textFormDecoration.copyWith(
                                labelText: "Password",
                                hintText: "Enter your password",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        passwordVisibility =
                                            !passwordVisibility;
                                      });
                                    },
                                    icon: !passwordVisibility
                                        ? const Icon(
                                            Icons.visibility,
                                            color: Colors.lightBlueAccent,
                                          )
                                        : const Icon(
                                            Icons.visibility_off,
                                            color: Colors.lightBlueAccent,
                                          )))),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                ForgotPassword.routeName,
                              );
                            },
                            child: const Text(
                              "Forget Password?",
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.lightBlueAccent,
                              ),
                            )),
                      ],
                    ),
                    Column(
                      children: [
                        HaveAccount(
                          actionLabel: "Sign Up",
                          haveAccont: "Don't have an account? ",
                          onPressed: () {
                            Navigator.pushNamed(
                                context, CustomerSignupScreen.routeName);
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        processing
                            ? const Center(child: CircularProgressIndicator())
                            : AuthMainButton(
                                mainButtonLable: "Log In",
                                onPressed: () {
                                  login();
                                },
                              ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 2,
                              width: 100,
                              child: Divider(
                                thickness: 1,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2,
                              width: 100,
                              child: Divider(
                                thickness: 1,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        processing == true
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Material(
                                elevation: 3,
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(15),
                                child: MaterialButton(
                                  onPressed: () {
                                    signInWithGoogle();
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: const [
                                        Icon(
                                          Icons.g_mobiledata,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                        Text(
                                          "Sign In With Google",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      ]),
                                ),
                              )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    )
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
