import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/delivery.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'delivery_detail.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final _storageService = StorageService();
  final _apiService = ApiService();
  
  List<Delivery> _myDeliveries = [];
  List<Delivery> _availableDeliveries = [];
  Delivery? _activeDelivery;
  
  bool _isLoading = true;
  User? _currentUser;
  String _driverId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _storageService.getUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        _driverId = user.id;
      });
      _loadDriverData();
    } else {
      // Si pas d'utilisateur, rediriger vers login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _loadDriverData() async {
    if (_driverId.isEmpty) return;
    
    setState(() => _isLoading = true);

    try {
      // Charger toutes les livraisons
      final allDeliveries = await _storageService.getDeliveries();
      
      // Filtrer les livraisons assignées à ce livreur
      _myDeliveries = allDeliveries
          .where((d) => d.assignedTo == _driverId)
          .toList();
      
      // Trier par date (les plus récentes d'abord)
      _myDeliveries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Trouver la livraison active (en cours)
      try {
        _activeDelivery = _myDeliveries.firstWhere(
          (d) => d.status == 'an_wout',
        );
      } catch (e) {
        _activeDelivery = null;
      }
      
      // Livraisons disponibles (non assignées)
      _availableDeliveries = allDeliveries
          .where((d) => d.assignedTo == null && d.status == 'an_trete')
          .toList();
    } catch (e) {
      print('Erreur chargement données livreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _acceptDelivery(Delivery delivery) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accepter la livraison'),
        content: Text('Voulez-vous accepter la livraison ${delivery.trackingNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Mettre à jour la livraison
                final updated = delivery.copyWith(
                  assignedTo: _driverId,
                  status: 'an_trete',
                );
                
                await _storageService.updateDelivery(updated);
                await _apiService.updateDeliveryStatus(updated.id, 'an_trete');
                
                await _loadDriverData();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Livraison ${delivery.trackingNumber} acceptée'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('ACCEPTER'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDeliveryStatus(Delivery delivery, String newStatus) async {
    try {
      // Mettre à jour localement
      final updated = delivery.copyWith(status: newStatus);
      
      if (newStatus == 'an_wout') {
        setState(() {
          _activeDelivery = updated;
        });
      } else if (newStatus == 'livre') {
        setState(() {
          _activeDelivery = null;
        });
      }
      
      await _storageService.updateDelivery(updated);
      await _apiService.updateDeliveryStatus(updated.id, newStatus);
      
      await _loadDriverData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour: ${updated.statusText}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('HH:mm').format(time);
  }

  int _getTodayDeliveries() {
    final now = DateTime.now();
    return _myDeliveries.where((d) => 
      d.createdAt.year == now.year &&
      d.createdAt.month == now.month &&
      d.createdAt.day == now.day &&
      d.status == 'livre'
    ).length;
  }

  int _getWeekDeliveries() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _myDeliveries.where((d) => 
      d.createdAt.isAfter(weekAgo) &&
      d.status == 'livre'
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Livreur'),
        backgroundColor: const Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDriverData,
          ),
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _currentUser!.initials,
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDriverData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message de bienvenue
                    if (_currentUser != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Bonjour ${_currentUser!.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    
                    // Livraison en cours (si active)
                    if (_activeDelivery != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.local_shipping, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'LIVRAISON EN COURS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _activeDelivery!.trackingNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _activeDelivery!.customerName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeDelivery!.deliveryAddress,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _updateDeliveryStatus(
                                        _activeDelivery!,
                                        'livre',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('MARQUER LIVRÉ'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DeliveryDetailScreen(
                                            delivery: _activeDelivery!,
                                          ),
                                        ),
                                      ).then((_) => _loadDriverData());
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white),
                                    ),
                                    child: const Text('DÉTAILS'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Statistiques du livreur
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Aujourd\'hui',
                                  _getTodayDeliveries().toString(),
                                  Icons.today,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                _buildStatItem(
                                  'Cette semaine',
                                  _getWeekDeliveries().toString(),
                                  Icons.weekend,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                _buildStatItem(
                                  'Total',
                                  _myDeliveries.length.toString(),
                                  Icons.inventory,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mes livraisons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mes livraisons',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_myDeliveries.length} total',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_myDeliveries.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune livraison assignée',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myDeliveries.length > 5 ? 5 : _myDeliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = _myDeliveries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
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
                                  delivery.status == 'livre' 
                                      ? Icons.check_circle 
                                      : delivery.status == 'an_wout'
                                          ? Icons.local_shipping
                                          : Icons.inventory,
                                  color: delivery.statusColor,
                                  size: 25,
                                ),
                              ),
                              title: Text(
                                delivery.customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
                                      fontSize: 12,
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
                                ).then((_) => _loadDriverData());
                              },
                            ),
                          );
                        },
                      ),

                    if (_myDeliveries.length > 5)
                      TextButton(
                        onPressed: () {
                          // Voir toutes les livraisons
                        },
                        child: const Text('Voir toutes mes livraisons'),
                      ),

                    const SizedBox(height: 24),

                    // Livraisons disponibles
                    if (_availableDeliveries.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Livraisons disponibles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_availableDeliveries.length} nouvelle(s)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _availableDeliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = _availableDeliveries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.inventory,
                                  color: Colors.grey,
                                  size: 25,
                                ),
                              ),
                              title: Text(
                                delivery.customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Prix: ${delivery.price?.toStringAsFixed(0) ?? 'À discuter'} HTG',
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _acceptDelivery(delivery),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('ACCEPTER'),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}