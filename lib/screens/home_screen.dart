import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'delivery_detail.dart';
import 'create_delivery.dart';
import 'profile_screen.dart';
import 'admin_dashboard.dart';
import 'driver_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  final _apiService = ApiService();
  
  List<Delivery> _deliveries = [];
  bool _isLoading = true;
  String _userRole = 'kilyan'; // kilyan, livre, admin
  Map<String, dynamic> _user = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
  }

  Future<void> _loadUserData() async {
    final user = await _storageService.getUser();
    if (user != null) {
      setState(() {
        _user = user.toJson();
        _userRole = user.role;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Charger depuis storage d'abord
    _deliveries = await _storageService.getDeliveries();
    
    // Puis charger depuis API
    try {
      final apiDeliveries = await _apiService.fetchAllDeliveries();
      if (apiDeliveries.isNotEmpty) {
        setState(() {
          _deliveries = apiDeliveries;
        });
        await _storageService.saveDeliveries(apiDeliveries);
      }
    } catch (e) {
      print('Erreur chargement API: $e');
    }
    
    setState(() => _isLoading = false);
  }

  // Rediriger vers le bon dashboard selon le rôle
  void _navigateToRoleBasedDashboard() {
    Widget destination;
    
    switch (_userRole) {
      case 'admin':
        destination = const AdminDashboard();
        break;
      case 'livre':
        destination = const DriverDashboard();
        break;
      default:
        destination = const HomeScreen(); // Déjà sur l'écran client
    }
    
    if (destination != const HomeScreen()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  int _getStats() {
    switch (_userRole) {
      case 'livre':
        return _deliveries.where((d) => 
          d.assignedTo == _user['id'] && d.status == 'an_wout'
        ).length;
      case 'admin':
        return _deliveries.length;
      default: // client
        return _deliveries.where((d) => d.status == 'an_trete').length;
    }
  }

  String _getStatsLabel() {
    switch (_userRole) {
      case 'livre':
        return 'Mes livraisons en cours';
      case 'admin':
        return 'Total livraisons';
      default:
        return 'En attente';
    }
  }

  List<Delivery> _getFilteredDeliveries() {
    switch (_userRole) {
      case 'livre':
        return _deliveries.where((d) => d.assignedTo == _user['id']).toList();
      case 'admin':
        return _deliveries;
      default: // client - montre ses propres livraisons
        // Pour la démo, on montre quelques livraisons
        return _deliveries.take(5).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Bloquer le retour en arrière après connexion
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DeliveRapid'),
          backgroundColor: const Color(0xFFFF6B35),
          actions: [
            // Bouton pour basculer vers le dashboard selon le rôle (visible seulement pour admin/livreur)
            if (_userRole != 'kilyan')
              IconButton(
                icon: Icon(
                  _userRole == 'admin' ? Icons.dashboard : Icons.delivery_dining,
                  color: Colors.white,
                ),
                onPressed: _navigateToRoleBasedDashboard,
                tooltip: _userRole == 'admin' ? 'Dashboard Admin' : 'Espace Livreur',
              ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
              tooltip: 'Actualiser',
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ).then((_) => _loadUserData());
              },
              tooltip: 'Profil',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: Column(
                  children: [
                    // Carte de bienvenue
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour, ${_user['name'] ?? 'Utilisateur'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userRole == 'admin' ? 'Administrateur' :
                            _userRole == 'livre' ? 'Livreur' : 'Client',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Stats Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStats().toString(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _getStatsLabel(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          if (_userRole != 'livre')
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CreateDeliveryScreen(),
                                  ),
                                ).then((_) => _loadData());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF6B35),
                              ),
                              child: const Text('Nouvelle livraison'),
                            ),
                        ],
                      ),
                    ),
                    
                    // Liste des livraisons
                    Expanded(
                      child: _getFilteredDeliveries().isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Aucune livraison pour le moment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _getFilteredDeliveries().length,
                              itemBuilder: (context, index) {
                                final delivery = _getFilteredDeliveries()[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: delivery.statusColor.withOpacity(0.1),
                                      child: Icon(
                                        Icons.inventory,
                                        color: delivery.statusColor,
                                        size: 25,
                                      ),
                                    ),
                                    title: Text(
                                      delivery.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          delivery.deliveryAddress,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: delivery.statusColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                delivery.statusText,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'ID: ${delivery.trackingNumber}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Color(0xFFFF6B35),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DeliveryDetailScreen(
                                            delivery: delivery,
                                          ),
                                        ),
                                      ).then((_) => _loadData());
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}