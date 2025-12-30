import 'package:flutter/material.dart';

class MeasurementItem {
  final IconData icon;
  final String title;
  final String value;
  final String unit; // Add unit field
  final String firestoreField; // Add Firestore field name

  MeasurementItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.firestoreField,
  });

  // Factory method to create from Firestore data
  factory MeasurementItem.fromFirestore(Map<String, dynamic> data, String field) {
    return MeasurementItem(
      icon: _getIconForField(field),
      title: _getTitleForField(field),
      value: data[field]?.toString() ?? 'N/A',
      unit: _getUnitForField(field),
      firestoreField: field,
    );
  }

  static IconData _getIconForField(String field) {
    switch (field) {
      case 'ambientTemp':
        return Icons.thermostat_auto_outlined;
      case 'soilTemp':
        return Icons.thermostat;
      case 'moistureLevel':
        return Icons.water_drop_outlined;
      case 'reservoirLevel':
        return Icons.water_sharp;
      default:
        return Icons.device_thermostat;
    }
  }

  static String _getTitleForField(String field) {
    switch (field) {
      case 'ambientTemp':
        return 'Ambient Temperature';
      case 'soilTemp':
        return 'In-Soil Temperature';
      case 'moistureLevel':
        return 'Moisture Level';
      case 'reservoirLevel':
        return 'Reservoir Level';
      default:
        return field;
    }
  }

  static String _getUnitForField(String field) {
    switch (field) {
      case 'ambientTemp':
      case 'soilTemp':
        return '°C';
      case 'moistureLevel':
      case 'reservoirLevel':
        return '%';
      default:
        return '';
    }
  }
}