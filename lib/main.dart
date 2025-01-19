import 'package:flutter/material.dart';
import 'just_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Optional: Hide debug banner
      title: 'Map Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMapScreen(),
    );
  }
}
