import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/MeasurementItemModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_application_1/firebase_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  double progressValue = 0.0;

  List<MeasurementItem> measurementItems =  [];

  String notificationText = "Waiting for data...";
  bool isLoading = true;
  bool hasError = false;

  final FiresbaseService _firebaseService = FiresbaseService();
  StreamSubscription? _dataSubscription;

  final List<String> sensorFields = [
    'DHT11',
    'soilTemp',
    'soilMoistureSensor',
    'reservoirLevel',
  ];

  @override
  void initState() {
    super.initState();
    _setupFirebaseListener();
  }

    void _setupFirebaseListener() {
    _dataSubscription = _firebaseService.getLatestSensorData().listen(
      (data) {
        if (data.isNotEmpty) {
          _updateUIWithData(data);
        } else {
          setState(() {
            notificationText = "No data available. Please check your connection.";
            isLoading = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          notificationText = "Error: $error";
          isLoading = false;
          hasError = true;
        });
      },
    );
  }
  
  void _updateUIWithData(Map<String, dynamic> data) {
    setState(() {
      // Update measurement items
      measurementItems = sensorFields.map((field) {
        return MeasurementItem.fromFirestore(data, field);
      }).toList();

      // Update progress value
      progressValue = (data['progress'] ?? 0.0).toDouble() / 100.0;

      // Update notification
      notificationText = data['notification'] ?? 
                        data['status'] ?? 
                        "Last updated: ${DateTime.now().toLocal().toString().substring(0, 16)}";

      isLoading = false;
      hasError = false;
     });
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Composter',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold
          ),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Progress Circle
            _buildProgressBar(),

            const SizedBox(height: 24),

            _buildMeasurementGrid(),

            const SizedBox(height: 24),

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
  
  Widget _buildMeasurementGrid() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text(
              'Parameters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        
          const SizedBox(height:16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5
             ),
             itemCount: measurementItems.length,
             itemBuilder: (context, index){
              return _buildMeasurementContainer(measurementItems[index]);
             },
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMeasurementContainer(MeasurementItem item){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightGreen.shade100)
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
            Text(
              item.title,
              style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,

            ),
            const SizedBox(height:8),

            Text(
              item.value,
              style: TextStyle(
                fontSize: 16,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12)
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
  