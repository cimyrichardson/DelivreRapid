import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'log_screen.dart';
import 'delivery_detail.dart';

class adm extends StatefulWidget {
  const adm({super.key});
  @override
  State<adm> createState() => _admState();
}

class _admState extends State<adm> {
  final ApiService apiService = ApiService();
  User? currentUser;
  List<Delivery> allDeliveries = [];
  List<Delivery> filteredDeliveries = [];
  bool isLoading = true;
  String searchText = '';
  String filterStatus = 'tous';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await StorageService.getCurrentUser();
    final deliveriesData = await apiService.fetchAllDeliveries();
    setState(() {
      currentUser = user;
      allDeliveries = deliveriesData;
      filteredDeliveries = deliveriesData;
      isLoading = false;
    });
  }

  void _filterDeliveries() {
    List<Delivery> filtered = allDeliveries;
    if (searchText.isNotEmpty) {
      filtered = filtered.where((d) => 
        d.trackingNumber.contains(searchText) || 
        d.customerName.toLowerCase().contains(searchText.toLowerCase())
      ).toList();
    }
    if (filterStatus != 'tous') {
      filtered = filtered.where((d) => d.status == filterStatus).toList();
    }
    setState(() => filteredDeliveries = filtered);
  }

  void _logout() async {
    await StorageService.logout();
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const log()));
    }
  }

  void _updateDeliveryStatus(Delivery delivery, String newStatus) async {
    final updated = delivery.copyWith(status: newStatus);
    await StorageService.updateDelivery(updated);
    setState(() {
      final index = allDeliveries.indexWhere((d) => d.id == delivery.id);
      if (index != -1) allDeliveries[index] = updated;
      _filterDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DelivreRapid - Admin')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Center(
                child: Text(currentUser?.name ?? 'Admin',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('Accueil'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Déconnexion', style: TextStyle(color: Colors.red)), onTap: _logout),
          ],
        ),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Container(padding: const EdgeInsets.all(16), child: Column(
            children: [
              TextField(
                onChanged: (val) {
                  searchText = val;
                  _filterDeliveries();
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _statusFilter('Tous', 'tous')),
                  const SizedBox(width: 8),
                  Expanded(child: _statusFilter('En cours', 'an_trete')),
                  const SizedBox(width: 8),
                  Expanded(child: _statusFilter('Livrée', 'livre')),
                ],
              ),
            ],
          )),
          Expanded(child: filteredDeliveries.isEmpty
            ? const Center(child: Text('Aucune livraison'))
            : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredDeliveries.length,
              itemBuilder: (context, index) {
                final d = filteredDeliveries[index];
                return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryDetail(delivery: d))),
                  leading: Icon(Icons.local_shipping, color: d.statusColor),
                  title: Text(d.trackingNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.customerName),
                    const SizedBox(height: 4),
                    Text(d.statusText, style: TextStyle(color: d.statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(child: const Text('En cours'), onTap: () => _updateDeliveryStatus(d, 'an_trete')),
                      PopupMenuItem(child: const Text('Livrée'), onTap: () => _updateDeliveryStatus(d, 'livre')),
                      PopupMenuItem(child: const Text('Annulée'), onTap: () => _updateDeliveryStatus(d, 'anile')),
                    ],
                  ),
                ));
              },
            ))
        ],
      ),
    );
  }

  Widget _statusFilter(String label, String value) => ElevatedButton(
    onPressed: () {
      setState(() => filterStatus = value);
      _filterDeliveries();
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: filterStatus == value ? Colors.orange : Colors.grey[300],
      foregroundColor: filterStatus == value ? Colors.white : Colors.black,
    ),
    child: Text(label),
  );
}