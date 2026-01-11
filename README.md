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
Install Android Studio  

### Flutter
Following dependencies must be configured in pubspec.yaml file:
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
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:percent_indicator/percent_indicator.dart';
```
Install Android Studio plugin by following these instructions:
https://docs.flutter.dev/tools/android-studio

Install Firebase plugin by following these instructions:
https://firebase.google.com/docs/flutter/setup?platform=ios



### Microcontroller (MCU)




Install packages 
