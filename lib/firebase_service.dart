/*
import 'package:cloud_firestore/cloud_firestore.dart';

class FiresbaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get latest sensor data
  Stream<Map<String, dynamic>> getLatestSensorData() {
    return _firestore
        .collection('sensorData')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>
            };
          }
          return {};
        });
  }

  // Get notifications
  Stream<List<Map<String, dynamic>>> getNotifications() {
    return _firestore
        .collection('notifications')
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>
            })
            .toList());
  }
}
*/