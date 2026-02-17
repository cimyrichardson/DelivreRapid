import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storageService = StorageService();
  Map<String, dynamic> _user = {};
  Map<String, dynamic> _settings = {};
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _storageService.getUser();
    final settings = await _storageService.getSettings();
    
    setState(() {
      _user = user?.toJson() ?? {};
      _settings = settings;
      _notificationsEnabled = settings['notifications'] ?? true;
      _selectedLanguage = settings['language'] ?? 'fr';
    });
  }

  Future<void> _logout() async {
    await _storageService.clearUser();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _saveSettings() async {
    final updatedSettings = {
      'notifications': _notificationsEnabled,
      'language': _selectedLanguage,
      ..._settings,
    };
    await _storageService.saveSettings(updatedSettings);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres sauvegardés'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Photo de profil
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6B35), width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nom
            Text(
              _user['name'] ?? 'Utilisateur',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Rôle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _user['role'] == 'admin' ? 'Administrateur' :
                _user['role'] == 'livre' ? 'Livreur' : 'Client',
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.email, 'Email', _user['email'] ?? ''),
                    const Divider(),
                    _buildInfoTile(Icons.phone, 'Téléphone', _user['phone'] ?? ''),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Paramètres
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Recevoir des alertes'),
                      value: _notificationsEnabled,
                      activeColor: const Color(0xFFFF6B35),
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Langue'),
                      subtitle: Text(
                        _selectedLanguage == 'fr' ? 'Français' :
                        _selectedLanguage == 'ht' ? 'Créole' : 'English',
                      ),
                      trailing: DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'fr', child: Text('Français')),
                          DropdownMenuItem(value: 'ht', child: Text('Créole')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton sauvegarder
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('SAUVEGARDER'),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Bouton déconnexion
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('DÉCONNEXION'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}