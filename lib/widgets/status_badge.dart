import 'package:flutter/material.dart';
import '../models/delivery.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String statusText;
  final Color color;

  const StatusBadge({
    required this.status,
    required this.statusText,
    required this.color,
    super.key,
  });

  factory StatusBadge.fromDelivery(Delivery delivery) {
    return StatusBadge(
      status: delivery.status,
      statusText: delivery.statusText,
      color: delivery.statusColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
