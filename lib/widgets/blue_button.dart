import 'package:flutter/material.dart';

class BlueButton extends StatelessWidget {
  final String lable;
  final Function onPressed;
  final double width;
  final Color color;

  const BlueButton({
    Key? key,
    required this.lable,
    required this.onPressed,
    required this.width,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width * width,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      child: MaterialButton(
        onPressed: () {
          onPressed();
        },
        child: Text(
          lable,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
