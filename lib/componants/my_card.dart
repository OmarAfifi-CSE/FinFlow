import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Icon icon;
  final String title;

  const MyCard({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Card(
        color: backgroundColor ?? Colors.teal[50],
        child: ListTile(
          leading: icon,
          title: Text(title),
          titleTextStyle: const TextStyle(fontSize: 20),
          textColor: textColor ?? Colors.black,
          iconColor: iconColor ?? Colors.teal,
        ),
      ),
    );
  }
}
