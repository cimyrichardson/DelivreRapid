import 'package:flutter/material.dart';
import '../models/delivery.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final Delivery delivery;
  const DeliveryDetailScreen({super.key, required this.delivery});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  final _storageService = StorageService();
  final _apiService = ApiService();
  late Delivery _delivery;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _delivery = widget.delivery;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);

    // Appeler API
    await _apiService.updateDeliveryStatus(_delivery.id, newStatus);
    
    // Mettre à jour localement
    setState(() {
      _delivery = _delivery.copyWith(status: newStatus);
    });
    
    // Sauvegarder dans storage
    await _storageService.updateDelivery(_delivery);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livraison ${_delivery.trackingNumber}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _delivery.statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _delivery.statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Client
                  const Text(
                    'Client',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.person,
                            'Nom',
                            _delivery.customerName,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.phone,
                            'Téléphone',
                            _delivery.customerPhone,
                          ),
                          if (_delivery.customerEmail != null) ...[
                            const Divider(),
                            _buildInfoRow(
                              Icons.email,
                              'Email',
                              _delivery.customerEmail!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Livraison
                  const Text(
                    'Détails de la livraison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.location_on,
                            'Adresse de prise',
                            _delivery.pickupAddress,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.location_on,
                            'Adresse de livraison',
                            _delivery.deliveryAddress,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.inventory,
                            'Poids',
                            '${_delivery.packageWeight} kg',
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.description,
                            'Description',
                            _delivery.packageDescription,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Dates
                  const Text(
                    'Dates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Créée le',
                            _formatDate(_delivery.createdAt),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.access_time,
                            'Estimée pour',
                            _formatDate(_delivery.estimatedTime),
                          ),
                          if (_delivery.actualDeliveryTime != null) ...[
                            const Divider(),
                            _buildInfoRow(
                              Icons.check_circle,
                              'Livrée le',
                              _formatDate(_delivery.actualDeliveryTime!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  if (_delivery.price != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Prix',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_delivery.price} HTG',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Boutons d'action (pour admin/livreur)
                  if (_delivery.status != 'livre' && _delivery.status != 'annile')
                    Row(
                      children: [
                        if (_delivery.status == 'an_trete')
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus('an_wout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('DÉMARRER'),
                            ),
                          ),
                        if (_delivery.status == 'an_wout')
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus('livre'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('LIVRER'),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateStatus('annile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('ANNULER'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}