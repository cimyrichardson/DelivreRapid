import 'package:flutter/material.dart';
import 'sign_screen.dart';
import 'kliyan_screen.dart';
import 'adm_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class log extends StatefulWidget {
  const log({super.key});

  @override
  State<log> createState() => _logState();
}

class _logState extends State<log> {
  final ApiService apiService = ApiService();
  
  // Contrôleurs pour récupérer le texte saisi par l'utilisateur
  final TextEditingController imel = TextEditingController();
  final TextEditingController pasword = TextEditingController();
  
  bool isLoading = false;
  bool _obscurePassword = true;

  // Fonction pour gérer la logique de connexion
  Future<void> _login() async {
    String email = imel.text.trim();
    String password = pasword.text;

    // Validation simple
    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage('Veuillez remplir tous les champs');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Appel à l'API pour se connecter
      final result = await apiService.login(email, password);

      if (result['success']) {
        // Créer un utilisateur depuis la réponse
        final userData = result['data'];
        final user = User.fromJson(userData);

        // Sauvegarder l'utilisateur et le token
        await StorageService.saveCurrentUser(user);
        if (userData['token'] != null) {
          await StorageService.saveToken(userData['token']);
        }

        // Afficher message de succès
        _showSuccessMessage('Connexion réussie!');

        // Naviguer vers l'écran approprié selon le rôle
        if (mounted) {
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
        }
      } else {
        _showErrorMessage(result['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      _showErrorMessage('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    imel.dispose();
    pasword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              'Connexion',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Champ Email
            TextField(
              controller: imel,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'admin@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Champ Mot de passe
            TextField(
              controller: pasword,
              enabled: !isLoading,
              obscureText: _obscurePassword,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bouton de connexion
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Se Connecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Lien vers l'inscription
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pas encore de compte? '),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const sign()),
                    );
                  },
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Info de test
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text(
                    '📝 Identifiants de test:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Email: admin@example.com'),
                  Text('Mot de passe: admin123'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}