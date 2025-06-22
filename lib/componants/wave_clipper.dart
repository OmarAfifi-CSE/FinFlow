import 'package:flutter/cupertino.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from the top left corner
    path.lineTo(0, 150);

    // First wave (controls the height and width of the first wave)
    path.quadraticBezierTo(
      size.width / 4,
      size.height * 0.7, // Control point and end point
      size.width / 2,
      size.height * 0.5,
    ); // Peak of the wave

    // Second wave (more dynamic curve)
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height * 0.4, // Control point and end point
      size.width,
      size.height * 0.6,
    ); // Ending point of the second wave

    // Continue to the bottom right corner
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
