import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RevityApp());
}

class RevityApp extends StatelessWidget {
  const RevityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revity',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
