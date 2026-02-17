import 'package:flutter/material.dart';
import '../models/delivery.dart';
import 'status_badge.dart';

class DeliveryCardWidget extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DeliveryCardWidget({
    required this.delivery,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // En-tête avec numéro de suivi et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          delivery.trackingNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          delivery.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.fromDelivery(delivery),
                ],
              ),
              const SizedBox(height: 12),

              // Adresses
              _buildAddressRow(
                '🔽',
                delivery.pickupAddress,
              ),
              const SizedBox(height: 8),
              _buildAddressRow(
                '📍',
                delivery.deliveryAddress,
              ),
              const SizedBox(height: 12),

              // Pied de page avec infos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${delivery.packageWeight} kg',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      if (delivery.distance != null)
                        Text(
                          '${delivery.distance} km',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(String icon, String address) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
