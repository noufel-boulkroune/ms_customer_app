import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ms_customer_app/auth/customer_login_screen.dart';
import 'package:ms_customer_app/galleries/shoes_gallery_screen.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:ms_customer_app/screens/customer_home_screen.dart';
import 'package:ms_customer_app/screens/hot_deals_screen.dart';
import 'package:ms_customer_app/screens/minor_screen/sub_category_products.dart';
import 'package:provider/provider.dart';

enum Offer { watches, shoes, sale }

class OnboardingScreen extends StatefulWidget {
  static const routeName = "onboarding-screen";
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  Timer? countDownTimer;
  int seconds = 5;
  int maxDiscount = 0;
  List<int> discountList = [];
  late int selectedIndex;
  late String offerName;
  late String assetName;
  late Offer offer;
  late AnimationController _animationController;
  late Animation<Color?> _colorTweenAnimation;

  @override
  void initState() {
    selectRandomOffer();
    startTimer();
    // getDiscount();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _colorTweenAnimation = ColorTween(begin: Colors.black, end: Colors.red)
        .animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.repeat();
    context.read<IdProvider>().getDocId();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void selectRandomOffer() {
    for (var i = 0; i < Offer.values.length; i++) {
      var random = Random();
      setState(() {
        selectedIndex = random.nextInt(3);
        offerName = Offer.values[selectedIndex].toString();
        assetName = offerName.replaceAll("Offer.", "");
        offer = Offer.values[selectedIndex];
      });
    }
  }

  void startTimer() {
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else if (seconds == 0) {
          stopTimer();
          FirebaseAuth.instance.currentUser != null
              ? Navigator.pushReplacementNamed(
                  context, CustomerHomeScreen.routeName)
              : Navigator.pushReplacementNamed(
                  context, CustomerLoginScreen.routeName);
        }
      });
    });
  }

  void stopTimer() {
    countDownTimer!.cancel();
  }

  void navigateToOffer() {
    switch (offer) {
      case Offer.watches:
        FirebaseAuth.instance.currentUser != null
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const SubCategoryProducts(
                          subCategoryName: "jeans",
                          mainCategoryName: "men",
                          fromOnboardingScreen:
                              true, //in SubCategoryProducts we can add check if fromOnboardingScreen == true navigate to CustomerHomeScreen
                        )),
                (Route route) => false)
            : Navigator.pushReplacementNamed(
                context, CustomerLoginScreen.routeName);
        break;
      case Offer.shoes:
        FirebaseAuth.instance.currentUser != null
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const ShoesGalleryScreen(
                          fromOnboarding: true,
                        )),
                (Route route) => false)
            : Navigator.pushReplacementNamed(
                context, CustomerLoginScreen.routeName);
        break;
      case Offer.sale:
        FirebaseAuth.instance.currentUser != null
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HotDealsScreen(
                          fromOnboarding: true,
                          maxDiscount: maxDiscount.toString(),
                        )),
                (Route route) => false)
            : Navigator.pushReplacementNamed(
                context, CustomerLoginScreen.routeName);
        break;
    }
  }

  void getDiscount() {
    FirebaseFirestore.instance
        .collection("products")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        discountList.add(doc["discount"]);
      }
    }).whenComplete(() {
      setState(() {
        maxDiscount = discountList.reduce(max);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                stopTimer();

                navigateToOffer();
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/images/onboard/$assetName.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 60,
              child: Container(
                height: 35,
                width: 100,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(185, 113, 182, 214),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25))),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, CustomerHomeScreen.routeName);
                  },
                  child: seconds == 0
                      ? const Text(
                          "Skip",
                          style: TextStyle(fontSize: 18),
                        )
                      : Text(
                          "Skip $seconds",
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ),
            offer == Offer.sale
                ? Positioned(
                    top: 195,
                    right: 60,
                    child: AnimatedOpacity(
                      duration: const Duration(microseconds: 100),
                      opacity: _animationController.value,
                      child: Text(
                        maxDiscount.toString() + ('%'),
                        style: const TextStyle(
                          fontSize: 85,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ))
                : const SizedBox(),
            Positioned(
                bottom: 70,
                child: AnimatedBuilder(
                    animation: _animationController.view,
                    builder: (context, child) {
                      return Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        color: _colorTweenAnimation.value,
                        child: child,
                      );
                    },
                    child: const Center(
                      child: Text(
                        'SHOP NOW',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
