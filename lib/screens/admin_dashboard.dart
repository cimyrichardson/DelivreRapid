import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'delivery_detail.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _storageService = StorageService();
  final _apiService = ApiService();
  
  List<Delivery> _allDeliveries = [];
  List<User> _allUsers = [];
  List<User> _drivers = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'Toutes';
  final List<String> _filters = ['Toutes', 'En traitement', 'En route', 'Livrées', 'Annulées'];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);

    // Charger livraisons
    _allDeliveries = await _storageService.getDeliveries();
    if (_allDeliveries.isEmpty) {
      _allDeliveries = await _apiService.fetchAllDeliveries();
      await _storageService.saveDeliveries(_allDeliveries);
    }

    // Charger utilisateurs (simulé)
    _allUsers = await _apiService.fetchAllUsers();
    _drivers = _allUsers.where((u) => u.role == 'livre').toList();

    setState(() => _isLoading = false);
  }

  List<Delivery> get _filteredDeliveries {
    switch (_selectedFilter) {
      case 'En traitement':
        return _allDeliveries.where((d) => d.status == 'an_trete').toList();
      case 'En route':
        return _allDeliveries.where((d) => d.status == 'an_wout').toList();
      case 'Livrées':
        return _allDeliveries.where((d) => d.status == 'livre').toList();
      case 'Annulées':
        return _allDeliveries.where((d) => d.status == 'annile').toList();
      default:
        return _allDeliveries;
    }
  }

  int _getStatusCount(String status) {
    switch (status) {
      case 'an_trete':
        return _allDeliveries.where((d) => d.status == 'an_trete').length;
      case 'an_wout':
        return _allDeliveries.where((d) => d.status == 'an_wout').length;
      case 'livre':
        return _allDeliveries.where((d) => d.status == 'livre').length;
      case 'annile':
        return _allDeliveries.where((d) => d.status == 'annile').length;
      default:
        return _allDeliveries.length;
    }
  }

  Future<void> _assignDriver(String deliveryId, String driverId) async {
    // Logique d'assignation
    final index = _allDeliveries.indexWhere((d) => d.id == deliveryId);
    if (index != -1) {
      final updated = _allDeliveries[index].copyWith(assignedTo: driverId);
      _allDeliveries[index] = updated;
      await _storageService.updateDelivery(updated);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: const Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAdminData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAdminData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cartes statistiques
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildStatCard(
                          'Total',
                          _allDeliveries.length.toString(),
                          Colors.blue,
                          Icons.inventory,
                        ),
                        _buildStatCard(
                          'En cours',
                          _getStatusCount('an_wout').toString(),
                          Colors.orange,
                          Icons.local_shipping,
                        ),
                        _buildStatCard(
                          'Livreurs',
                          _drivers.length.toString(),
                          Colors.green,
                          Icons.person,
                        ),
                        _buildStatCard(
                          'Revenus',
                          '${_allDeliveries.fold(0.0, (sum, d) => sum + (d.price ?? 0)).toStringAsFixed(0)} HTG',
                          Colors.purple,
                          Icons.attach_money,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Graphique simple
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aperçu des livraisons',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildLegendItem('En traitement', Colors.orange),
                                _buildLegendItem('En route', Colors.blue),
                                _buildLegendItem('Livrées', Colors.green),
                                _buildLegendItem('Annulées', Colors.red),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _allDeliveries.isEmpty
                                  ? 0
                                  : _getStatusCount('livre') / _allDeliveries.length,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              minHeight: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Liste des livreurs
                    const Text(
                      'Livreurs actifs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: _drivers.isEmpty
                          ? const Center(child: Text('Aucun livreur'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _drivers.length,
                              itemBuilder: (context, index) {
                                final driver = _drivers[index];
                                return Container(
                                  width: 150,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.orange.shade100,
                                            child: Text(
                                              driver.initials,
                                              style: const TextStyle(
                                                color: Color(0xFFFF6B35),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            driver.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${_allDeliveries.where((d) => d.assignedTo == driver.id && d.status == 'an_wout').length} en cours',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Filtres et liste des livraisons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toutes les livraisons',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedFilter,
                          items: _filters.map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Liste des livraisons
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredDeliveries.length,
                      itemBuilder: (context, index) {
                        final delivery = _filteredDeliveries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
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
                                Text('ID: ${delivery.trackingNumber}'),
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
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildInfoRow('Client', delivery.customerName),
                                    _buildInfoRow('Téléphone', delivery.customerPhone),
                                    _buildInfoRow('Adresse', delivery.deliveryAddress),
                                    if (delivery.price != null)
                                      _buildInfoRow('Prix', '${delivery.price} HTG'),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Assignation livreur
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              labelText: 'Assigner à',
                                              border: OutlineInputBorder(),
                                            ),
                                            value: delivery.assignedTo,
                                            items: [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text('Non assigné'),
                                              ),
                                              ..._drivers.map((driver) {
                                                return DropdownMenuItem(
                                                  value: driver.id,
                                                  child: Text(driver.name),
                                                );
                                              }),
                                            ],
                                            onChanged: (value) {
                                              _assignDriver(delivery.id, value!);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => DeliveryDetailScreen(
                                                    delivery: delivery,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('Détails'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}