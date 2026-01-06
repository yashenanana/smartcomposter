import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/MeasurementItemModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_application_1/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Stream<QuerySnapshot> getData(){
  return FirebaseFirestore.instance.collection('sensorData').snapshots();
}



class _HomePageState extends State<HomePage> {
  double progressValue = 0.65; // Example progress value (65%)

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getData(){
    return _firestore.collection('sensorData').snapshots();
  }

  MeasurementItem _documentToMeasurementItem(DocumentSnapshot doc){
    final sensorID = doc['sensorID'] as String? ?? '';
    final value = doc['value'] as num? ?? 0;
    final timestamp = doc['timestamp'] as Timestamp? ?? Timestamp.now();

    IconData icon;
    String title;
    String suffix;

    switch(sensorID){
      case 'ambientTemperature':
        icon= Icons.thermostat_auto_outlined;
        title= 'Ambient Temperature';
        suffix= '°C';
        break;
      
      case 'soilTemperature':
        icon = Icons.thermostat;
        title = "In-Soil Temperature";
        suffix = '°C';
        break;

      case 'reservoirLevel':
        icon = Icons.water_sharp;
        title = 'Reservoir Level';
        suffix = '';
        break;
      
      case 'soilMoistureLevel':
        icon = Icons.water_drop_outlined;
        title = 'Soil Moisture Level';
        suffix = '%';
        break;

      default:
        icon = Icons.sensors;
        title = sensorID;
        suffix = '';
    }

    return MeasurementItem(icon: icon, title: title, value: '${value.toStringAsFixed(2)}', suffix: suffix);
  }
  
  // Example data for the measurement containers
  final List<MeasurementItem> measurementItems = [];

  String notificationText = 'System operating normally. Last updated: 2 minutes ago';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Item: Progress Bar
              _buildProgressBar(),
              
              const SizedBox(height: 24),
              
              // Second Item: 5 Measurement Containers
              _buildMeasurementGrid(),
              
              const SizedBox(height: 24),
              
              // Third Item: Notification Bar
              _buildNotificationBar(),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildProgressBar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text(
            'Compost Progress',
            textAlign: TextAlign.center,
            style: TextStyle(
            fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 30,
            percent: 0.4,
            progressColor: Colors.lightGreen,
            backgroundColor: Colors.lightGreen.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            ),

        ],)
      )
    );

  }

  Color _getProgressColor(double value) {
    if (value < 0.3) return Colors.red;
    if (value < 0.7) return Colors.amber;
    return Colors.green;
  }

    Widget _buildMeasurementGrid() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Measurements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: measurementItems.length,
              itemBuilder: (context, index) {
                return _buildMeasurementContainer(measurementItems[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementContainer(MeasurementItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              item.value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildNotificationBar() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              color: Colors.blue[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notificationText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[900],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}