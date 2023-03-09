import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/auth/customer_login_screen.dart';
import 'package:ms_customer_app/auth/update_password.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/screens/cart_screen.dart';
import 'package:ms_customer_app/screens/customer_screens/address_list.dart';
import 'package:ms_customer_app/screens/customer_screens/customer_orders.dart';
import 'package:ms_customer_app/screens/customer_screens/wishlist_screen.dart';
import 'package:ms_customer_app/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/alert_dialog.dart';

class ProfileScreen extends StatefulWidget {
//  final String docId;
  const ProfileScreen({super.key /*, required this.docId*/});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? docId = null;
  late Future<String> documentId;
  CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');
  CollectionReference anonymous =
      FirebaseFirestore.instance.collection('anonymous');

  @override
  void initState() {
    documentId = context.read<IdProvider>().getDocumentId();
    docId = context.read<IdProvider>().getData;

    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   if (user != null) {
    //     setState(() {
    //       docId = user.uid;
    //     });
    //   }
    // });
    super.initState();
  }

  clearUserId() {
    context.read<IdProvider>().clearCustomerId();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseAuth.instance.currentUser!.isAnonymous
          ? anonymous.doc(docId).get()
          : customers.doc(docId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            backgroundColor: Colors.grey.shade300,
            body: Stack(children: [
              Container(
                height: 230,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.lightBlueAccent.shade100, Colors.blue]),
                ),
              ),
              CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  floating: true,
                  expandedHeight: 140,
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    return FlexibleSpaceBar(
                      title: AnimatedOpacity(
                        opacity: constraints.biggest.height <= 120 ? 1 : 0,
                        duration: const Duration(microseconds: 300),
                        child: const Text(
                          "Account",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.lightBlueAccent.shade100,
                            Colors.blue
                          ]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, top: 25),
                          child: Row(children: [
                            data["name"] == ""
                                ? const CircleAvatar(
                                    radius: 50,
                                    backgroundImage: AssetImage(
                                        "assets/images/inapp/guest.jpg"),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        NetworkImage(data["profileImage"]),
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                data["name"] == ""
                                    ? "geust".toUpperCase()
                                    : data["name"].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
                SliverToBoxAdapter(
                  child: Column(children: [
                    Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width * .8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(50),
                                    topLeft: Radius.circular(50))),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CartScreen(
                                            back: AppBarBackButton(
                                          color: Colors.black,
                                        )),
                                      ));
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .21,
                                  child: const Center(
                                    child: Text(
                                      "Cart",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerOrdersScreen(),
                                      ));
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .21,
                                  child: const Center(
                                    child: Text(
                                      "Orders",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(50),
                                    topRight: Radius.circular(50))),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WishlistScreen(),
                                      ));
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .21,
                                  child: const Center(
                                    child: Text(
                                      "Wishlist",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 150,
                            child: Image(
                                image:
                                    AssetImage("assets/images/inapp/logo.jpg")),
                          ),
                          const SizedBox(height: 10),
                          const ProfileHeaderLable(
                              headerLabel: '  Account Info  '),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 260,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(children: [
                                RepeatedListTaile(
                                  title: "Email Address",
                                  subTitle: data["email"] == ""
                                      ? "example@gmail.com"
                                      : data["email"],
                                  icon: Icons.email,
                                ),
                                const BlueDivider(),
                                RepeatedListTaile(
                                  title: "Phone Number",
                                  subTitle: data["phone"] == ""
                                      ? "example: +11111"
                                      : data["phone"],
                                  icon: Icons.phone,
                                ),
                                const BlueDivider(),
                                RepeatedListTaile(
                                  title: "Address",
                                  subTitle: userAddress(data),
                                  onListTap: FirebaseAuth
                                          .instance.currentUser!.isAnonymous
                                      ? null
                                      : () {
                                          Navigator.pushNamed(
                                              context, AddressList.routeName);
                                        },
                                  /*data["address"] == ""
                                      ? "Example: 140 - st - New Gersy"
                                      : data["address"],*/
                                  icon: Icons.location_pin,
                                ),
                              ]),
                            ),
                          ),
                          const ProfileHeaderLable(
                              headerLabel: "  Account Settings  "),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 260,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(children: [
                                RepeatedListTaile(
                                  title: 'Edit Profile',
                                  icon: Icons.edit,
                                  onListTap: () {},
                                ),
                                const BlueDivider(),
                                RepeatedListTaile(
                                  title: 'Change Password',
                                  icon: Icons.lock,
                                  onListTap: () {
                                    Navigator.pushNamed(
                                        context, UpdatePassword.routeName);
                                  },
                                ),
                                const BlueDivider(),
                                RepeatedListTaile(
                                  title: 'LogOut',
                                  icon: Icons.logout,
                                  onListTap: () async {
                                    GeneralAlertDialog.showMyDialog(
                                      context: context,
                                      title: 'Log Out',
                                      contet:
                                          'Are you sure you want to logout?',
                                      tabNo: () {
                                        Navigator.of(context).pop();
                                      },
                                      tabYes: () async {
                                        await FirebaseAuth.instance.signOut();
                                        clearUserId();
                                        // final SharedPreferences pref =
                                        //     await _prefs;
                                        // pref.setString("documenId", "");
                                        await Future.delayed(const Duration(
                                                microseconds: 10))
                                            .whenComplete(() =>
                                                Navigator.of(context).pop());
                                        await Future.delayed(const Duration(
                                                microseconds: 10))
                                            .whenComplete(() =>
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    CustomerLoginScreen
                                                        .routeName));
                                      },
                                    );
                                  },
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                )
              ]),
            ]),
          );
        }

        return const Center(
          child: CircularProgressIndicator(
            color: Colors.lightBlueAccent,
          ),
        );
      },
    );
  }

  String userAddress(Map<String, dynamic> data) {
    if (/*FirebaseAuth.instance.currentUser!.isAnonymous*/ docId == "") {
      return "Example: New Jercey - USA";
    } else if (/*FirebaseAuth.instance.currentUser!.isAnonymous == false*/ docId !=
            "" &&
        data["address"] == "") {
      return "Set your Address";
    }
    return data["address"];
  }
}

class BlueDivider extends StatelessWidget {
  const BlueDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Divider(
        color: Colors.lightBlueAccent,
        thickness: 1,
      ),
    );
  }
}

class RepeatedListTaile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final Function? onListTap;
  const RepeatedListTaile({
    Key? key,
    required this.title,
    this.subTitle = "",
    required this.icon,
    this.onListTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onListTap!();
        },
        child: ListTile(
          title: Text(title),
          subtitle: Text(subTitle),
          leading: Icon(icon),
        ));
  }
}

class ProfileHeaderLable extends StatelessWidget {
  final String headerLabel;
  const ProfileHeaderLable({Key? key, required this.headerLabel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 40,
            child: Divider(
              thickness: 3,
              height: 2,
              color: Colors.grey,
            ),
          ),
          Text(
            headerLabel,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
              width: 50,
              height: 40,
              child: Divider(
                thickness: 3,
                height: 2,
                color: Colors.grey,
              )),
        ],
      ),
    );
  }
}
