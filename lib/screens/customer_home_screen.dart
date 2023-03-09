import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badge;
import 'package:ms_customer_app/screens/minor_screen/visit_store_screen.dart';
import 'package:ms_customer_app/services/notification_services.dart';
import 'package:provider/provider.dart';

import '/screens/cart_screen.dart';
import '/screens/home_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/stores_screen.dart';
import '../providers/cart_provider.dart';
import 'category_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  static const routeName = "customer_screen";
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _tabs = [
    const HomeScreen(),
    const CategoryScreen(),
    StoresScreen(),
    const CartScreen(),
    const ProfileScreen(
        // documentId: FirebaseAuth.instance.currentUser!.uid,
        ),
    // ProfileScreen(documentId: "v1Wb04NL2mSXqwt2Xi6WOdNgyBi2")
  ];

  displayForgroundNotification() {
    FirebaseMessaging.instance.getToken().then((value) => print(value));
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        NotificationServices.displayNotification(message);
      }
    });
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'followers') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VisitStoreScreen(supplierId: message.data['supplierId']),
        ),
      );
    }
  }

  @override
  void initState() {
    context.read<CartProvider>().loadCartItems();
    displayForgroundNotification();
    setupInteractedMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: _selectedIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Category",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: "Stores",
          ),
          BottomNavigationBarItem(
            icon: badge.Badge(
                animationType: badge.BadgeAnimationType.slide,
                badgeColor: Colors.lightBlueAccent,
                badgeContent: Text(context
                    .watch<CartProvider>()
                    .productsList
                    .length
                    .toString()),
                child: const Icon(Icons.shopping_cart)),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
