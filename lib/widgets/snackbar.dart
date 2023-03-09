import 'package:flutter/material.dart';

class SnackBarHundler {
  // SnackBarHundler(GlobalKey<ScaffoldState> scafoldKey, String message);

  static void showSnackBar(var scaffoldKey, String message) {
    scaffoldKey.currentState!.hideCurrentSnackBar();
    scaffoldKey.currentState!.showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.lightBlueAccent,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
              letterSpacing: 1.3,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        )));
  }
}
