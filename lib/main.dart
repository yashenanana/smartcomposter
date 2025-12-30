import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  } catch(e){
    print("Error initializing Firebase: $e");
  }
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Smart Composter App',
      theme: ThemeData(fontFamily: 'Moglan'),
      home: HomePage()
    );
  }
}


