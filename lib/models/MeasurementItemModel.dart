import 'package:flutter/material.dart';

class MeasurementItem {
  final IconData icon;
  final String title;
  final String value;
  final String suffix;

  MeasurementItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.suffix
  });
}