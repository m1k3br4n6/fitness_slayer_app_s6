import 'package:fitness_slayer_01/screens/wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); //when app starts, runs MyApp()
}

//MyApp that runs when app starts
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(), //will load Wrapper.dart first, which will display either Home or Authenticate
    );
  }
}
