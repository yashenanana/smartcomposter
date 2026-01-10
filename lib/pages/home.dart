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
  return FirebaseFirestore.instance.collection('compostSensorData').snapshots();
}



class _HomePageState extends State<HomePage> {
  double progressValue = 0.65; // Example progress value (65%)

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QueryDocumentSnapshot<Map<String,dynamic>>?> getLatestData() {
    return _firestore
        .collection('compostSensorData')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null)
        .where((doc) => doc != null);
  }

    List<MeasurementItem> _documentToMeasurementItems(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      return [];
    }
    
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp? ?? Timestamp.now();
    
    final List<MeasurementItem> items = [];
    
    // 1. Soil Moisture Level
    if (data.containsKey('SoilMoistureLevel')) {
      final value = data['SoilMoistureLevel'] as num? ?? 0;
      items.add(MeasurementItem(
        icon: Icons.water,
        title: 'Soil Moisture',
        value: '${value.toStringAsFixed(1)}%',
        time: timestamp,
      ));
    }
    
    // 2. Ambient Temperature
    if (data.containsKey('Ambient Temperature')) {
      final value = data['Ambient Temperature'] as num? ?? 0;
      items.add(MeasurementItem(
        icon: Icons.thermostat,
        title: 'Ambient Temp',
        value: '${value.toStringAsFixed(1)}°C',
        time:timestamp,
      ));
    }
  return items;
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
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
      .collection('compostSensorData')
      .orderBy('timestamp', descending:true)
      .limit(5)
      .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Convert data when available

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        // Build error state
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        
        // Build empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final latestDoc = snapshot.data!.docs.first;
        final latestData = latestDoc.data() as Map<String, dynamic>;

        final List<MeasurementItem> latestMeasurements = [];

        if (latestData.containsKey('soilMoisture')) {
          latestMeasurements.add(MeasurementItem(
            icon: Icons.water_drop_outlined,
            title: 'Soil Moisture',
            value: '${(latestData['soilMoisture'] as num).toStringAsFixed(1)}%',
            time: latestData['timestamp'] as Timestamp,
          ));
        }
        
        if (latestData.containsKey('airTemperature')) {
          latestMeasurements.add(MeasurementItem(
            icon: Icons.thermostat_auto_outlined,
            title: 'Ambient Temperature',
            value: '${(latestData['airTemperature'] as num).toStringAsFixed(1)}°C',
            time: latestData['timestamp'] as Timestamp,
          ));
        }
        
        if (latestData.containsKey('soilTemperature')) {
          latestMeasurements.add(MeasurementItem(
            icon: Icons.thermostat,
            title: 'Soil Temp',
            value: '${(latestData['soilTemperature'] as num).toStringAsFixed(1)}°C',
            time: latestData['timestamp'] as Timestamp,
          ));
        }

        if (latestData.containsKey('IRDistanceRaw')) {
          String compostLimitText = "";
          if(latestData['IRDistanceRaw']==true){
            compostLimitText = "Good to Go!";
          }else{
            compostLimitText = "At Capacity";
          }
          latestMeasurements.add(MeasurementItem(
            icon: Icons.yard_rounded,
            title: 'Compost Limit',
            value: compostLimitText,
            time: latestData['timestamp'] as Timestamp,
          ));
        }
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // First Item: Progress Bar
                _buildProgressBar(),
                
                const SizedBox(height: 24),
                
                // Second Item: Measurement Containers - show loading/empty states
                if (latestMeasurements.isNotEmpty)
                  _buildMeasurementGrid(latestMeasurements)
                  else
                  Text("Error Error"),
                
                const SizedBox(height: 24),

                _buildNotificationBar(),

                const SizedBox(height: 24),
                
                _buildNotificationBar(),
              ],
            ),
          ),
        );
      },
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

    Widget _buildMeasurementGrid(List<MeasurementItem> measurementItems) {
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

  Widget _buildLoadingState() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Measurements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Loading grid placeholder
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: 5, // Show 5 loading containers
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNotificationBar(),
        ],
      ),
    ),
  );
}

Widget _buildErrorState(String error) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Optionally add retry logic
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNotificationBar(),
        ],
      ),
    ),
  );
}

Widget _buildEmptyState() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'No Data Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add some measurements to see them here',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
             ),
          const SizedBox(height: 24),
          _buildNotificationBar(),
        ],
      ),
    ),
  );
}
}