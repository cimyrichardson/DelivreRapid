import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/adm_screen.dart';
void main() {
  runApp(const DelivreRapidApp());
}

class DelivreRapidApp extends StatelessWidget {
  const DelivreRapidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DelivreRapid',
      debugShowCheckedModeBanner: false,
      home:const adm(),
    );
  }
}

