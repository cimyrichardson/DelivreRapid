import 'package:flutter/material.dart';
import '../models/delivery.dart';

class DeliveryDetail extends StatefulWidget {
  final Delivery delivery;

  const DeliveryDetail({required this.delivery, super.key});

  @override
  State<DeliveryDetail> createState() => _DeliveryDetailState();
}

class _DeliveryDetailState extends State<DeliveryDetail> {
  late Delivery delivery;

  @override
  void initState() {
    super.initState();
    delivery = widget.delivery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(delivery.trackingNumber),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de statut
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Informations client
            _buildSection(
              'Informations Client',
              [
                _buildInfoRow('Nom', delivery.customerName),
                _buildInfoRow('Téléphone', delivery.customerPhone),
                if (delivery.customerEmail != null)
                  _buildInfoRow('Email', delivery.customerEmail!),
              ],
            ),
            const SizedBox(height: 20),

            // Adresses
            _buildSection(
              'Adresses',
              [
                _buildAddressWidget('🔽 Départ', delivery.pickupAddress),
                const SizedBox(height: 12),
                _buildAddressWidget('📍 Destination', delivery.deliveryAddress),
              ],
            ),
            const SizedBox(height: 20),

            // Détails du colis
            _buildSection(
              'Détails du Colis',
              [
                _buildInfoRow('Poids', '${delivery.packageWeight} kg'),
                _buildInfoRow('Description', delivery.packageDescription),
                if (delivery.distance != null)
                  _buildInfoRow('Distance', '${delivery.distance} km'),
                if (delivery.estimatedDuration != null)
                  _buildInfoRow('Durée estimée', '${delivery.estimatedDuration} min'),
              ],
            ),
            const SizedBox(height: 20),

            // Informations de livraison
            _buildSection(
              'Informations de Livraison',
              [
                _buildInfoRow('Statut', delivery.statusText),
                _buildInfoRow(
                  'Créée le',
                  delivery.createdAt.toLocal().toString().split('.')[0],
                ),
                if (delivery.actualDeliveryTime != null)
                  _buildInfoRow(
                    'Livrée le',
                    delivery.actualDeliveryTime!.toLocal().toString().split('.')[0],
                  ),
                if (delivery.assignedDriverName != null) ...[
                  _buildInfoRow('Livreur', delivery.assignedDriverName!),
                  if (delivery.assignedDriverPhone != null)
                    _buildInfoRow('Téléphone livreur', delivery.assignedDriverPhone!),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Historique des statuts
            if (delivery.statusHistory != null &&
                delivery.statusHistory!.isNotEmpty) ...[
              const Text(
                'Historique des Statuts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildStatusTimeline(),
              const SizedBox(height: 20),
            ],

            // Prix (si disponible)
            if (delivery.price != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Montant Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$ ${delivery.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Payé: ${delivery.isPaid ? '✅ Oui' : '❌ Non'}',
                style: TextStyle(
                  color: delivery.isPaid ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Notes
            if (delivery.notes != null && delivery.notes!.isNotEmpty) ...[
              _buildSection(
                'Notes',
                [
                  Text(delivery.notes!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              delivery.statusColor,
              delivery.statusColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              delivery.statusText.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Statut actuel de la livraison',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressWidget(String label, String address) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(address),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: delivery.statusHistory!.length,
      itemBuilder: (context, index) {
        final history = delivery.statusHistory![index];
        final status = history['status'] ?? 'Inconnu';
        final timestamp = history['timestamp'] ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index < delivery.statusHistory!.length - 1)
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.orange.withOpacity(0.3),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timestamp,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
