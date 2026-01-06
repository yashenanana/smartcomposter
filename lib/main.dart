import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:percent_indicator/percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Smart Composter App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Moglan',
      ),
      home: const HomePage(),
    );
  }
}