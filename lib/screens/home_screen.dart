import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import 'delivery_detail.dart';
import 'log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  
  User? currentUser;
  List<Delivery> deliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Récupérer l'utilisateur connecté
      final user = await StorageService.getCurrentUser();
      setState(() => currentUser = user);

      // Récupérer les livraisons depuis l'API
      final deliveriesData = await apiService.fetchAllDeliveries();
      
      // Sauvegarder les livraisons
      await StorageService.saveDeliveries(deliveriesData);
      
      setState(() {
        deliveries = deliveriesData;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur loadData: $e');
      setState(() => isLoading = false);
    }
  }

  void _logout() async {
    await StorageService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const log()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DelivreRapid'),
        elevation: 0,
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentUser!.name,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      currentUser!.role,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(currentUser?.initials ?? '?'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.name ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Carte de bienvenue
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.orangeAccent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue, ${currentUser?.name}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vous êtes ${currentUser?.role == 'kilyan' ? 'client' : currentUser?.role == 'livre' ? 'livreur' : 'administrateur'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistiques
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          deliveries.length.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'En route',
                          deliveries
                              .where((d) => d.isInTransit)
                              .length
                              .toString(),
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Livrée',
                          deliveries
                              .where((d) => d.isDelivered)
                              .length
                              .toString(),
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Liste des livraisons
                  const Text(
                    'Livraisons Récentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (deliveries.isEmpty)
                    const Center(
                      child: Text('Aucune livraison trouvée'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = deliveries[index];
                        return DeliveryCard(
                          delivery: delivery,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DeliveryDetail(delivery: delivery),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Composant Carte Livraison
class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onTap;

  const DeliveryCard({
    required this.delivery,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: delivery.statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_shipping, color: delivery.statusColor),
        ),
        title: Text(
          delivery.trackingNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          delivery.customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: delivery.statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            delivery.statusText,
            style: TextStyle(
              color: delivery.statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
