import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'driver_dashboard.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _storageService = StorageService();
  final _apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Base de données locale simulée pour les utilisateurs enregistrés
  final Map<String, Map<String, String>> _registeredUsers = {
    // Utilisateurs par défaut pour les tests
    'test@test.com': {
      'password': 'password',
      'name': 'Client Test',
      'phone': '509 1234 5678',
      'role': 'kilyan',
    },
    'admin@test.com': {
      'password': 'password',
      'name': 'Admin',
      'phone': '509 8765 4321',
      'role': 'admin',
    },
    'livreur@test.com': {
      'password': 'password',
      'name': 'Livreur Test',
      'phone': '509 5555 5555',
      'role': 'livre',
    },
  };

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Vérifier s'il y a des identifiants sauvegardés
  Future<void> _checkSavedCredentials() async {
    final savedEmail = await _secureStorage.read(key: 'saved_email');
    final savedPassword = await _secureStorage.read(key: 'saved_password');
    
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  // Charger les utilisateurs depuis le storage
  Future<Map<String, Map<String, String>>> _loadRegisteredUsers() async {
    final saved = await _secureStorage.read(key: 'registered_users');
    if (saved != null) {
      return Map<String, Map<String, String>>.from(
        (jsonDecode(saved) as Map).map(
          (key, value) => MapEntry(key, Map<String, String>.from(value))
        )
      );
    }
    return _registeredUsers;
  }

  // Sauvegarder un nouvel utilisateur
  Future<void> _saveRegisteredUser(String email, String password, String name, String phone, String role) async {
    final users = await _loadRegisteredUsers();
    users[email] = {
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
    };
    await _secureStorage.write(
      key: 'registered_users',
      value: jsonEncode(users),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulation délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // Charger les utilisateurs enregistrés
    final users = await _loadRegisteredUsers();
    
    // Vérifier si l'email existe
    if (users.containsKey(_emailController.text)) {
      final userData = users[_emailController.text]!;
      
      // Vérifier le mot de passe
      if (userData['password'] == _passwordController.text) {
        
        // Créer l'objet utilisateur
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: userData['name']!,
          email: _emailController.text,
          phone: userData['phone']!,
          role: userData['role']!,
          token: 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
          isLoggedIn: true,
        );
        
        // Sauvegarder l'utilisateur connecté
        await _storageService.saveUser(user);
        
        // Sauvegarder les identifiants si "Se souvenir de moi" est coché
        if (_rememberMe) {
          await _secureStorage.write(key: 'saved_email', value: _emailController.text);
          await _secureStorage.write(key: 'saved_password', value: _passwordController.text);
        } else {
          await _secureStorage.delete(key: 'saved_email');
          await _secureStorage.delete(key: 'saved_password');
        }

        if (mounted) {
          // Rediriger selon le rôle
          Widget destination;
          switch (user.role) {
            case 'admin':
              destination = const AdminDashboard();
              break;
            case 'livre':
              destination = const DriverDashboard();
              break;
            default:
              destination = const HomeScreen();
          }
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => destination),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bienvenue ${user.name}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Mot de passe incorrect
        _showErrorSnackBar('Mot de passe incorrect');
      }
    } else {
      // Email non trouvé
      _showErrorSnackBar('Aucun compte trouvé avec cet email');
    }

    setState(() => _isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delivery_dining,
                    size: 60,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Titre
              const Text(
                'Bienvenue !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Sous-titre
              const Text(
                'Connectez-vous pour continuer',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 40),
              
              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Champ email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Entrez votre email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Champ mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        hintText: 'Entrez votre mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Minimum 6 caractères';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: const Color(0xFFFF6B35),
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Se souvenir de moi',
                              style: TextStyle(color: Color(0xFF2C3E50)),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité à venir'),
                              ),
                            );
                          },
                          child: const Text(
                            'Mot de passe oublié?',
                            style: TextStyle(color: Color(0xFFFF6B35)),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Bouton connexion
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SE CONNECTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Lien vers inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Attendre le résultat de l'inscription
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                      
                      // Si un utilisateur a été créé, remplir automatiquement l'email
                      if (result != null && result is Map) {
                        setState(() {
                          _emailController.text = result['email'] ?? '';
                        });
                        
                        // Afficher un message de succès
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Compte créé avec succès! Connectez-vous ${result['email']}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Comptes de démonstration
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comptes de démonstration:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDemoAccount('Client', 'test@test.com', 'password'),
                    _buildDemoAccount('Admin', 'admin@test.com', 'password'),
                    _buildDemoAccount('Livreur', 'livreur@test.com', 'password'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccount(String role, String email, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: role == 'Admin' ? Colors.purple :
                     role == 'Livreur' ? Colors.blue : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$role: $email / $password',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}