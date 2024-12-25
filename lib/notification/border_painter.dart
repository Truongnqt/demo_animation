import 'package:flutter/material.dart';

class BorderPainter extends CustomPainter {
  final double width;
  final double height;
  final double strokeWidth;
  final Gradient? gradient;
  final _paint = Paint()..style = PaintingStyle.stroke;
  BorderPainter(
      {required this.width,
      required this.height,
      required this.strokeWidth,
      this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Rect.fromLTWH(0, (size.height - height) / 2, size.width, height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(36));
    _paint
      ..strokeWidth = strokeWidth
      ..shader = gradient?.createShader(rect);
    canvas.drawRRect(rrect, _paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) {
    return false;
  }
}
