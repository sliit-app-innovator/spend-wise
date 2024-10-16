import 'package:flutter/material.dart';
import 'dart:math';

class PieChartPainter extends CustomPainter {
  final Map<String, double> dataMap;
  final List<Color> colors;

  PieChartPainter(this.dataMap, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;
    dataMap.forEach((key, value) {
      total += value;
    });

    double startAngle = -pi / 2;
    final radius = min(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    int colorIndex = 0;

    dataMap.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * pi;
      paint.color = colors[colorIndex % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
      colorIndex++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
