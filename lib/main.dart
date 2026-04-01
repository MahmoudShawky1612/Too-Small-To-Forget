import 'package:flutter/material.dart';
import 'package:toosmalltoforget/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Too Small To Forget',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home:  HomeScreen(),
    );
  }
}