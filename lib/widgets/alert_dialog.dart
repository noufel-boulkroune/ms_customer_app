import 'package:flutter/material.dart';

class GeneralAlertDialog {
  static void showMyDialog(
      {required BuildContext context,
      required String title,
      required String contet,
      required Function tabNo,
      required Function tabYes}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(contet),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                tabNo();
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                tabYes();
              },
            ),
          ],
        );
      },
    );
  }
}
