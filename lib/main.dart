import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Couleurs personnalisées pour l'application
class AppColors {
  static const Color orange = Color(0xFFFF6B35);
  static const Color blue = Color(0xFF2C3E50);
  static const Color grey = Color(0xFFF5F5F5);
  static const Color white = Colors.white;
  static const Color black = Colors.black54;
}