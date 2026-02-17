import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/delivery.dart';
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
  String _driverId = 'driver1'; // À remplacer par l'ID réel du livreur connecté

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    setState(() => _isLoading = true);

    // Charger toutes les livraisons
    final allDeliveries = await _storageService.getDeliveries();
    
    // Filtrer les livraisons assignées à ce livreur
    _myDeliveries = allDeliveries
        .where((d) => d.assignedTo == _driverId)
        .toList();
    
    // Trouver la livraison active (en cours)
    _activeDelivery = _myDeliveries.firstWhere(
      (d) => d.status == 'an_wout',
      orElse: () => null as Delivery,
    );
    
    // Livraisons disponibles (non assignées)
    _availableDeliveries = allDeliveries
        .where((d) => d.assignedTo == null && d.status == 'an_trete')
        .toList();

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
              
              // Mettre à jour la livraison
              final updated = delivery.copyWith(
                assignedTo: _driverId,
                status: 'an_trete',
              );
              
              await _storageService.updateDelivery(updated);
              await _apiService.updateDeliveryStatus(updated.id, 'an_trete');
              
              _loadDriverData();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Livraison ${delivery.trackingNumber} acceptée'),
                  backgroundColor: Colors.green,
                ),
              );
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
    
    _loadDriverData();
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
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
                                      );
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

                    // Statistiques du jour
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Aujourd\'hui',
                                  _myDeliveries
                                      .where((d) => 
                                        d.createdAt.day == DateTime.now().day &&
                                        d.status == 'livre'
                                      ).length
                                      .toString(),
                                  Icons.today,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                _buildStatItem(
                                  'Cette semaine',
                                  _myDeliveries
                                      .where((d) => d.status == 'livre')
                                      .length
                                      .toString(),
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
                    const Text(
                      'Mes livraisons',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (_myDeliveries.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Aucune livraison assignée'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myDeliveries.length,
                        itemBuilder: (context, index) {
                          final delivery = _myDeliveries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: delivery.statusColor,
                                child: Text(
                                  delivery.trackingNumber.substring(0, 3),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              title: Text(delivery.customerName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(delivery.deliveryAddress),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

                    const SizedBox(height: 24),

                    // Livraisons disponibles
                    if (_availableDeliveries.isNotEmpty) ...[
                      const Text(
                        'Livraisons disponibles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: const Icon(
                                  Icons.inventory,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(delivery.customerName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(delivery.deliveryAddress),
                                  Text(
                                    'Prix: ${delivery.price ?? 'À discuter'} HTG',
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B35),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _acceptDelivery(delivery),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
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
        Icon(icon, color: const Color(0xFFFF6B35)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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