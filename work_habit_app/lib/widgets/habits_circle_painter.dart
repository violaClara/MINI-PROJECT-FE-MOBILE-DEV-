import 'dart:math';
import 'package:flutter/material.dart';

// CustomPainter untuk menggambar lingkaran insight sesuai persentase tracked
class HabitsCirclePainter extends CustomPainter {
  final double trackedPercentage; // dalam persen (0-100)

  HabitsCirclePainter({required this.trackedPercentage});

  @override
  void paint(Canvas canvas, Size size) {
    double scale = size.width / 36.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = 15.9155 * scale;
    // Gambar lingkaran background (abu-abu)
    Paint bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    canvas.drawCircle(center, radius, bgPaint);

    // Hitung sudut untuk trackedPercentage (360° * persentase/100)
    double sweepAngle = 2 * pi * (trackedPercentage / 100);
    Paint bluePaint = Paint()
      ..color = Colors.blue[500]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    // Mulai dari atas (offset -pi/2) dan gambar sweepAngle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant HabitsCirclePainter oldDelegate) {
    return oldDelegate.trackedPercentage != trackedPercentage;
  }
}