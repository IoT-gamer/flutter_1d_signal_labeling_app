import 'package:flutter/material.dart';

/// A simple data model for your label classes
class LabelClass {
  final String name;
  final int id;
  final Color color;

  const LabelClass(this.name, this.id, this.color);
}

/// The master list of classes for your 1D CNN segmentation model.
/// ID 0 is typically reserved for the "Background" or "Unlabeled" class in your export.
const List<LabelClass> availableClasses = [
  LabelClass("Class Name 1", 1, Colors.redAccent),
  LabelClass("Class Name 2", 2, Colors.blueAccent),
  LabelClass("Class Name 3", 3, Colors.green),
  LabelClass("Class Name 4", 4, Colors.orange),
];

/// A helper function to easily grab the color by ID for the CustomPainter
Color getColorForClassId(int id) {
  try {
    return availableClasses.firstWhere((label) => label.id == id).color;
  } catch (e) {
    // Fallback color if an unknown ID is somehow passed
    return Colors.grey.withValues(alpha: 0.5);
  }
}
