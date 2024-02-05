import 'dart:math';
import 'package:flutter/material.dart';

class CircleClipper extends CustomClipper<Rect> {
  final double radius;

  CircleClipper(this.radius);

  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius * sqrt(size.width * size.width + size.height * size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) {
    return radius != oldClipper.radius;
  }
}