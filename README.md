# Smart Composter

A smart composter system that uses IoT technology to automate parts of the composting process while allowing the user to monitor relevant information about their compost via a mobile application. 

## Features
- Real-time data visualisation in Android application built in Flutter
- Constantly measure soil moisture level, ambient temperature, in-soil temperature and if compost bin is at capacity.
- Suggests actions based on compost condition.
  Eg. If in-soil temperature is too high, user is advised to aerate the system.
- Calculates readiness of compost before curation period.  
- Smart Feature: Automated irrigation system with submersible water pump when soil moisture is too low.
- Uses Wi-Fi connection and MQTT Protocol to send sensor data to Google Cloud Platform
- Sensor data is stored in Firestore database collection
- Data is read in real-time through Firebase packages on Flutter


## Installation

### Android Studio
Install Android Studio by following these instructions: https://developer.android.com/studio/install

### Flutter
Following dependencies must be added in pubspec.yaml file:
```
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.2.3
  percent_indicator: ^4.2.5
  firebase_core: ^4.3.0
  firebase_storage: ^13.0.5
  cloud_firestore: ^6.1.1
  intl: ^0.20.2
```

Following packages must be imported:
```
home.dart
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:percent_indicator/percent_indicator.dart';
```

```
main.dart
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
```
```
MeasurementItemModel.dart
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';
```

Install Android Studio plugin by following these instructions:
https://docs.flutter.dev/tools/android-studio

Install Firebase plugin by following these instructions:
https://firebase.google.com/docs/flutter/setup?platform=ios


## To Run
### Arduino
1. Setup MCU Hardware
2. Upload arduino Code file to MCU

### Python
1. run mqttToFirestore.py file

### Mobile Application
1. Configure your Android device to enable Developer Mode (can follow this guide: https://www.geeksforgeeks.org/installation-guide/how-to-install-flutter-app-on-android/)
2. Connect your Android device to the same device Flutter is on.
3. Ensure your device is recognized by Flutter.
4. Run main.dart


