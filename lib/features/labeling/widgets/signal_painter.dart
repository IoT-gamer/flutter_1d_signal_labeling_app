import 'package:flutter/material.dart';
import 'dart:math';
import '../../../models/signal_data.dart';

class SignalPainter extends CustomPainter {
  final SignalData data;
  final int? currentDragStart;
  final int? currentDragEnd;

  SignalPainter({
    required this.data,
    this.currentDragStart,
    this.currentDragEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.values.isEmpty) return;

    final int length = data.values.length;

    // Find the min and max values to dynamically scale the Y-axis
    double minValue = data.values.reduce(min);
    double maxValue = data.values.reduce(max);
    double range = maxValue - minValue;
    if (range == 0)
      range = 1; // Prevent division by zero if signal is perfectly flat

    // Helper functions to map array data to canvas pixels
    double getX(int index) => (index / (length - 1)) * size.width;

    // Y is inverted because canvas 0,0 is top-left, but charts have 0 at the bottom
    double getY(double value) =>
        size.height - (((value - minValue) / range) * size.height);

    // Draw previously committed regions (Masks)
    final Paint regionPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (var region in data.regions) {
      double startX = getX(region.startIndex);
      double endX = getX(region.endIndex);

      // Draw a rectangle from the top of the canvas to the bottom
      Rect rect = Rect.fromLTRB(startX, 0, endX, size.height);
      canvas.drawRect(rect, regionPaint);
    }

    // Draw the current active drag (while user's finger is on the screen)
    if (currentDragStart != null &&
        currentDragEnd != null &&
        currentDragStart != -1 &&
        currentDragEnd != -1) {
      double startX = getX(currentDragStart!);
      double endX = getX(currentDragEnd!);

      // The user might drag right-to-left, so we find the absolute left and right bounds
      double left = min(startX, endX);
      double right = max(startX, endX);

      final Paint dragPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.4);
      canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), dragPaint);
    }

    // Draw the 1D Signal Path
    final Paint linePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    Path path = Path();
    path.moveTo(getX(0), getY(data.values[0]));

    for (int i = 1; i < length; i++) {
      path.lineTo(getX(i), getY(data.values[i]));
    }

    canvas.drawPath(path, linePaint);
  }

  // Ensures Flutter only redraws the canvas when the data or touch coordinates change
  @override
  bool shouldRepaint(covariant SignalPainter oldDelegate) {
    return oldDelegate.currentDragStart != currentDragStart ||
        oldDelegate.currentDragEnd != currentDragEnd ||
        oldDelegate.data != data;
  }
}
