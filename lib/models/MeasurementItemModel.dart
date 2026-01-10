import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MeasurementItem {
  final IconData icon;
  final String title;
  final String value;
  final Timestamp time;

  MeasurementItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.time,
  });
}