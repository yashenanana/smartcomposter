import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/MeasurementItemModel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_application_1/firebase_service.dart';
import 'package:intl/intl.dart';




class HomePage extends StatefulWidget {
  
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

Stream<QuerySnapshot> getData(){
  return FirebaseFirestore.instance.collection('compostSensorData').snapshots();
}




class _HomePageState extends State<HomePage> {


int optimalDays = 0;
  DateTime? lastResetDate;
  StreamSubscription<QuerySnapshot>? _dataSubscription;
  
  Map<String, dynamic> latestData = HashMap();

  DateTime present = DateTime(2005,5,25); //default value
  
  List<String> notifications = [];


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example data for the measurement containers
  final List<MeasurementItem> measurementItems = [];

  String notificationText = '';

  @override
void initState() {
  super.initState();
  _setupDataListener();
  _loadProgressData();
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
        latestData = latestDoc.data() as Map<String, dynamic>;

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

          if (latestData.containsKey('timestamp')) {
            final timestamp = latestData['timestamp'] as Timestamp;
            present = timestamp.toDate();
          }
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

                _buildNotificationBar(''),

                const SizedBox(height: 24),
                
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
            center: Text(
              (calculateProgress() * 100).toString() + '%',
              style:
                TextStyle(fontSize: 30.0),
              ),
            percent: calculateProgress(),
            progressColor: _getProgressColor(calculateProgress()),
            backgroundColor: const Color.fromARGB(255, 237, 240, 234),
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

    Widget _buildNotificationBar(String specifiedNotif) {
    if(specifiedNotif.compareTo('') ==0){
      final formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(present);
      notificationText = 'Last updated at $formattedTime';
    }else{
      notificationText = specifiedNotif;
    }
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[50]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            children: [
              Icon(
                Icons.notifications,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child:Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                children: [ 
                Text(
                  notificationText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[900],
                  ),
                ),
                ],
              ),
            ),
          ],
        ),

 if (notifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Display notifications
            ...notifications.map((notification) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification,
                        
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey[800],
                        
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          ],
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
          _buildNotificationBar(''),
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
          _buildNotificationBar('An error has occured. Try restarting the app'),
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
          _buildNotificationBar('Nothing to see here'),
        ],
      ),
    ),
  );
}

void _setupDataListener() {
  _dataSubscription = FirebaseFirestore.instance
      .collection('compostSensorData')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      final newData = snapshot.docs.first.data() as Map<String, dynamic>;
      _updateProgress(newData);
      setState(() {
        latestData = newData;
        if (newData.containsKey('timestamp')) {
          present = (newData['timestamp'] as Timestamp).toDate();
        }
      });
    }
  });
}

void _loadProgressData() async {
  // Load saved progress from Firestore or SharedPreferences
  final doc = await FirebaseFirestore.instance
      .collection('compostProgress')
      .doc('current')
      .get();
  
  if (doc.exists) {
    final data = doc.data()!;
    setState(() {
      optimalDays = data['optimalDays'] ?? 0;
      lastResetDate = (data['lastResetDate'] as Timestamp?)?.toDate();
    });
  }
}

void _updateProgress(Map<String, dynamic> data) {
  // Check if conditions are optimal
  final isOptimal = _checkOptimalConditions(data);
  
  if (isOptimal) {
    // Check if this is a new day
    final today = DateTime.now();
    if (lastResetDate == null || 
        !_isSameDay(lastResetDate!, today)) {
      
      // It's a new day of optimal conditions
      setState(() {
        optimalDays++;
        lastResetDate = today;
      });
      
      // Save progress to Firestore
      FirebaseFirestore.instance
          .collection('compostProgress')
          .doc('current')
          .set({
        'optimalDays': optimalDays,
        'lastResetDate': Timestamp.fromDate(today),
        'lastUpdated': Timestamp.now(),
      });
    }
  } else {
     setState(() {
      optimalDays = 0;
      lastResetDate = null;
    });
  }
}

bool _checkOptimalConditions(Map<String, dynamic> data) {
  // Define optimal ranges
  const optimalSoilMoistureMin = 60.0;
  const optimalSoilMoistureMax = 100.0;
  const optimalSoilTempMin = 0.0;  // °C
  const optimalSoilTempMax = 60.0;  // °C
  
  // Check if we have the required data
  if (!data.containsKey('soilMoisture') || 
      !data.containsKey('soilTemperature')) {
    return false;
  }
  
  final soilMoisture = (data['soilMoisture'] as num).toDouble();
  final soilTemp = (data['soilTemperature'] as num).toDouble();

  //if conditions aren't optimal send notification
  setState(() {
    notifications.clear();
  });
  
  if (soilMoisture<optimalSoilMoistureMin){
    setState((){
    final message1 = "Compost moisture too low, auto irrigation system activated.";
    notifications.add(message1);
    });
  }

  if (soilTemp>optimalSoilTempMax){
    setState((){
    final message2 = "Compost temperature too high. Please aerate the system.";
    notifications.add(message2);
    });
  }

  final compostLimit = data['IRDistanceRaw'] as bool;
  if(compostLimit == false){
    setState((){
    final message3 = "Composter is at capacity. Please do not add any more.";
    notifications.add(message3);
    });
  }
  
  // Check if values are within optimal ranges
  final moistureOptimal = soilMoisture >= optimalSoilMoistureMin && 
                         soilMoisture <= optimalSoilMoistureMax;
  final tempOptimal = soilTemp >= optimalSoilTempMin && 
                     soilTemp <= optimalSoilTempMax;
  
  return moistureOptimal && tempOptimal;
}
bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}

double calculateProgress() {
  const totalDaysRequired = 30;
  final progress = optimalDays / totalDaysRequired;
  //return progress.clamp(0.0, 1.0);
  return 0.4;
}
}