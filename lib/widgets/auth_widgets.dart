import 'package:flutter/material.dart';

class AuthMainButton extends StatelessWidget {
  final String mainButtonLable;
  final Function onPressed;
  const AuthMainButton({
    Key? key,
    required this.mainButtonLable,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.lightBlueAccent,
      borderRadius: BorderRadius.circular(25),
      child: MaterialButton(
        onPressed: () {
          onPressed();
        },
        minWidth: double.infinity,
        child: Text(
          mainButtonLable,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class HaveAccount extends StatelessWidget {
  final String haveAccont;
  final String actionLabel;
  final Function onPressed;
  const HaveAccount({
    Key? key,
    required this.haveAccont,
    required this.actionLabel,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(haveAccont,
            style: const TextStyle(
              fontSize: 16,
            )),
        TextButton(
            onPressed: () {
              onPressed();
            },
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ))
      ],
    );
  }
}

class AuthHeaderLable extends StatelessWidget {
  final String headerLable;
  const AuthHeaderLable({
    Key? key,
    required this.headerLable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          headerLable,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.home_work,
              size: 40,
            ))
      ],
    );
  }
}

var textFormDecoration = InputDecoration(
  labelText: "Full name",
  hintText: "Enter your full name",
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

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}
