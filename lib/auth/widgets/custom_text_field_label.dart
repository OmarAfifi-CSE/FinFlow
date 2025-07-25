import 'package:flutter/material.dart';

class CustomTextFieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const CustomTextFieldLabel({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 5),
        Icon(icon, size: 12),
        Text(
          textAlign: TextAlign.start,
          " $label",
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
