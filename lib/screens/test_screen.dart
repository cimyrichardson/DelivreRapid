import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/delivery.dart';
import '../services/api_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final ApiService apiService = ApiService();
  
  List<User> users = [];
  List<Delivery> deliveries = [];
  
  bool isLoadingUsers = false;
  bool isLoadingDeliveries = false;
  
  String debugLog = 'Tests prêts...\n';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API & Models'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Boutons de test
            _buildTestButton(
              'Tester fetchAllUsers',
              _testFetchUsers,
              isLoading: isLoadingUsers,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Tester fetchAllDeliveries',
              _testFetchDeliveries,
              isLoading: isLoadingDeliveries,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Tester User.fromJson / toJson',
              _testUserSerialization,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Tester Delivery.fromJson / toJson',
              _testDeliverySerialization,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              'Vérifier Connexion Internet',
              _testInternetConnection,
            ),
            const SizedBox(height: 16),
            
            // Affichage des résultats
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résultats:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    debugLog,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            
            // Affichage des utilisateurs
            if (users.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Utilisateurs trouvés:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.take(5).length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.initials),
                      ),
                      title: Text(user.name),
                      subtitle: Text('${user.email}\n${user.role}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ],
            
            // Affichage des livraisons
            if (deliveries.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Livraisons trouvées:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deliveries.take(5).length,
                itemBuilder: (context, index) {
                  final delivery = deliveries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(delivery.trackingNumber),
                      subtitle: Text(delivery.customerName),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: delivery.statusColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          delivery.statusText,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed, {bool isLoading = false}) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ) : const Icon(Icons.play_arrow),
      label: Text(label),
    );
  }

  Future<void> _testFetchUsers() async {
    setState(() => isLoadingUsers = true);
    try {
      debugLog += '🔄 Récupération des utilisateurs...\n';
      final usersList = await apiService.fetchAllUsers();
      
      setState(() {
        users = usersList;
        debugLog += '✅ ${usersList.length} utilisateurs trouvés\n';
        if (usersList.isNotEmpty) {
          final first = usersList.first;
          debugLog += 'Premier: ${first.name} (${first.role})\n';
        }
      });
    } catch (e) {
      setState(() => debugLog += '❌ Erreur: $e\n');
    } finally {
      setState(() => isLoadingUsers = false);
    }
  }

  Future<void> _testFetchDeliveries() async {
    setState(() => isLoadingDeliveries = true);
    try {
      debugLog += '🔄 Récupération des livraisons...\n';
      final deliveriesList = await apiService.fetchAllDeliveries();
      
      setState(() {
        deliveries = deliveriesList;
        debugLog += '✅ ${deliveriesList.length} livraisons trouvées\n';
        if (deliveriesList.isNotEmpty) {
          final first = deliveriesList.first;
          debugLog += 'Première: ${first.trackingNumber} (${first.statusText})\n';
        }
      });
    } catch (e) {
      setState(() => debugLog += '❌ Erreur: $e\n');
    } finally {
      setState(() => isLoadingDeliveries = false);
    }
  }

  void _testUserSerialization() {
    try {
      debugLog += '🔄 Test sérialisation User...\n';
      
      // Créer un utilisateur
      final user = User(
        id: 'TEST001',
        name: 'Jean Dupont',
        email: 'jean@example.com',
        phone: '+509 1234 5678',
        role: 'kilyan',
        token: 'token123',
        isLoggedIn: true,
      );
      
      // Convertir en JSON
      final json = user.toJson();
      debugLog += '✅ Conversion en JSON réussie\n';
      
      // Reconvertir en User
      final userFromJson = User.fromJson(json);
      debugLog += '✅ Conversion depuis JSON réussie\n';
      
      // Vérifier l'égalité
      if (userFromJson.name == user.name && 
          userFromJson.email == user.email &&
          userFromJson.role == user.role) {
        debugLog += '✅ Données cohérentes après sérialisation\n';
      }
      
      setState(() {});
    } catch (e) {
      setState(() => debugLog += '❌ Erreur: $e\n');
    }
  }

  void _testDeliverySerialization() {
    try {
      debugLog += '🔄 Test sérialisation Delivery...\n';
      
      // Créer une livraison
      final delivery = Delivery(
        id: 'DEL001',
        trackingNumber: 'TRK123456',
        customerName: 'Client Test',
        customerPhone: '+509 1111 1111',
        pickupAddress: 'Entrepôt Port-au-Prince',
        deliveryAddress: 'Rue Normale, PAP',
        packageWeight: 5.5,
        packageDescription: 'Colis test',
        status: 'an_wout',
        estimatedTime: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      // Convertir en JSON
      final json = delivery.toJson();
      debugLog += '✅ Conversion en JSON réussie\n';
      
      // Reconvertir en Delivery
      final deliveryFromJson = Delivery.fromJson(json);
      debugLog += '✅ Conversion depuis JSON réussie\n';
      
      // Vérifier l'égalité
      if (deliveryFromJson.trackingNumber == delivery.trackingNumber &&
          deliveryFromJson.status == delivery.status) {
        debugLog += '✅ Données cohérentes après sérialisation\n';
      }
      
      setState(() {});
    } catch (e) {
      setState(() => debugLog += '❌ Erreur: $e\n');
    }
  }

  Future<void> _testInternetConnection() async {
    try {
      debugLog += '🔄 Vérification connexion internet...\n';
      final hasConnection = await apiService.hasInternetConnection();
      
      if (hasConnection) {
        debugLog += '✅ Connexion internet OK\n';
      } else {
        debugLog += '⚠️ Pas de connexion internet\n';
      }
      
      setState(() {});
    } catch (e) {
      setState(() => debugLog += '❌ Erreur: $e\n');
    }
  }
}
