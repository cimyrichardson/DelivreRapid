import 'package:flutter/material.dart';
import 'log_screen.dart';
import 'kliyan_screen.dart';
import '../services/storage_service.dart';
import '../models/user.dart';

class sign extends StatefulWidget {
  const sign({super.key});

  @override
  State<sign> createState() => _signState();
}

class _signState extends State<sign> {
  // Contrôleurs pour récupérer le texte saisi par l'utilisateur
  final TextEditingController nom = TextEditingController();
  final TextEditingController imel = TextEditingController();
  final TextEditingController pasword = TextEditingController();
  final TextEditingController konf = TextEditingController();
  final TextEditingController phone = TextEditingController();
  
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Validation d'email
  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
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

  // Créer un compte
  Future<void> _register() async {
    String nomVal = nom.text.trim();
    String emailVal = imel.text.trim();
    String passwordVal = pasword.text;
    String confirmVal = konf.text;
    String phoneVal = phone.text.trim();

    // Validations
    if (nomVal.isEmpty || emailVal.isEmpty || passwordVal.isEmpty ||
        phoneVal.isEmpty) {
      _showErrorMessage('Veuillez remplir tous les champs');
      return;
    }

    if (!isValidEmail(emailVal)) {
      _showErrorMessage('Email invalide');
      return;
    }

    if (passwordVal.length < 6) {
      _showErrorMessage('Le mot de passe doit avoir au moins 6 caractères');
      return;
    }

    if (passwordVal != confirmVal) {
      _showErrorMessage('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Créer un nouvel utilisateur
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nomVal,
        email: emailVal,
        phone: phoneVal,
        role: 'kilyan', // Par défaut, nouvel utilisateur = client
        isLoggedIn: true,
        isActive: true,
      );

      // Sauvegarder l'utilisateur
      await StorageService.saveCurrentUser(newUser);

      _showSuccessMessage('Compte créé avec succès!');

      // Naviguer vers kliyan_screen (client par défaut)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const kliyan()),
        );
      }
    } catch (e) {
      _showErrorMessage('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nom.dispose();
    imel.dispose();
    pasword.dispose();
    konf.dispose();
    phone.dispose();
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
            const SizedBox(height: 60),

            // Logo
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Créer un Compte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Champ Nom
            TextField(
              controller: nom,
              enabled: !isLoading,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Jean Dupont',
                prefixIcon: const Icon(Icons.person_outline),
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

            // Champ Téléphone
            TextField(
              controller: phone,
              enabled: !isLoading,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Téléphone',
                hintText: '+509 1234 5678',
                prefixIcon: const Icon(Icons.phone_outlined),
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

            // Champ Email
            TextField(
              controller: imel,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'jean@example.com',
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

            const SizedBox(height: 20),

            // Champ Confirmation Mot de passe
            TextField(
              controller: konf,
              enabled: !isLoading,
              obscureText: _obscureConfirm,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.check_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
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

            // Bouton Créer un compte
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
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
                        'Créer un Compte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Lien vers la connexion
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Vous avez déjà un compte? '),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const log()),
                    );
                  },
                  child: const Text(
                    'Se Connecter',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}