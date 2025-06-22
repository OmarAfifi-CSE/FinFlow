import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String button_msg;
  final Icon? button_icon;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color fgColor;
  final double padding;
  final double borderRadius;

  const MyButton({
    super.key,
    required this.button_msg,
    this.button_icon,
    required this.bgColor,
    required this.fgColor,
    this.onPressed,
    required this.padding,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          label: Text(button_msg, style: const TextStyle(fontSize: 20)),
          icon: button_icon,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            padding: EdgeInsets.all(padding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0, // Shadow elevation
          ),
        ),
      ),
    );
  }
}
