import 'package:flutter/material.dart';
import 'dart:async';
import 'log_screen.dart';
import 'kliyan_screen.dart';
import 'adm_screen.dart';
import '../services/storage_service.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  void initState() {
    super.initState();
    // Après 3 secondes, vérifier si l'utilisateur est connecté
    Timer(const Duration(seconds: 3), () async {
      final isLoggedIn = await StorageService.isUserLoggedIn();
      final user = await StorageService.getCurrentUser();

      if (mounted) {
        if (isLoggedIn && user != null) {
          // L'utilisateur est déjà connecté, rediriger selon le rôle
          Widget destination;
          if (user.isAdmin) {
            destination = const adm(); // Admin
          } else {
            destination = const kliyan(); // Client (par défaut)
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          // L'utilisateur n'est pas connecté, aller à la connexion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const log()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 250,
            ),
            const SizedBox(height: 30),
            
            // Texte et loader
            const Text(
              'DelivreRapid',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 30),
            const Text(
              'Chargement...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

