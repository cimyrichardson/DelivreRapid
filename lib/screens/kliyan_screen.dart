import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'log_screen.dart';
import 'delivery_detail.dart';

class kliyan extends StatefulWidget {
  const kliyan({super.key});
  @override
  State<kliyan> createState() => _kliyanState();
}

class _kliyanState extends State<kliyan> {
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
    final user = await StorageService.getCurrentUser();
    final deliveriesData = await apiService.fetchAllDeliveries();
    setState(() {
      currentUser = user;
      deliveries = deliveriesData;
      isLoading = false;
    });
  }

  void _logout() async {
    await StorageService.logout();
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const log()));
    }
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final pickupController = TextEditingController();
    final deliveryController = TextEditingController();
    final descController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer Livraison'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 12),
              TextField(controller: pickupController, decoration: const InputDecoration(labelText: 'Départ')),
              const SizedBox(height: 12),
              TextField(controller: deliveryController, decoration: const InputDecoration(labelText: 'Destination')),
              const SizedBox(height: 12),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Poids')),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final newDel = Delivery(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
                customerName: nameController.text,
                customerPhone: currentUser?.phone ?? '...',
                pickupAddress: pickupController.text,
                deliveryAddress: deliveryController.text,
                packageWeight: double.tryParse(weightController.text) ?? 1.0,
                packageDescription: descController.text,
                status: 'an_trete',
                estimatedTime: DateTime.now().add(const Duration(hours: 2)),
                createdAt: DateTime.now(),
              );
              setState(() => deliveries.add(newDel));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Créé!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DelivreRapid - Client')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Center(
                child: Text(currentUser?.name ?? 'Client',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('Accueil'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Déconnexion', style: TextStyle(color: Colors.red)), onTap: _logout),
          ],
        ),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        Card(margin: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bienvenue ${currentUser?.name ?? "!"}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 8),
          const Text('Gestion de vos livraisons'),
        ])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _card('Total', deliveries.length.toString(), Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _card('En route', deliveries.where((d) => d.isInTransit).length.toString(), Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _card('Livrée', deliveries.where((d) => d.isDelivered).length.toString(), Colors.green)),
        ]),
        const SizedBox(height: 20),
        const Text('Livraisons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (deliveries.isEmpty) const Center(child: Text('Aucune')) else ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: deliveries.length,
          itemBuilder: (context, index) {
            final d = deliveries[index];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryDetail(delivery: d))),
              leading: Icon(Icons.local_shipping, color: d.statusColor),
              title: Text(d.trackingNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(d.customerName),
              trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: d.statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(d.statusText, style: TextStyle(color: d.statusColor, fontSize: 11))),
            ));
          },
        ),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: _showCreateDialog, backgroundColor: Colors.orange, child: const Icon(Icons.add)),
    );
  }

  Widget _card(String label, String value, Color color) => Card(child: Container(padding: const EdgeInsets.all(12), color: color.withOpacity(0.1), child: Column(children: [
    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 12, color: color)),
  ])));
}