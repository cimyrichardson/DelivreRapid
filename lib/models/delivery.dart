import 'package:flutter/material.dart';

class Delivery {
  final String id;
  final String trackingNumber;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String pickupAddress;
  final String deliveryAddress;
  final double packageWeight;
  final String packageDescription;
  final String status;
  final String? assignedTo;
  final DateTime estimatedTime;
  final DateTime? actualDeliveryTime;
  final DateTime createdAt;
  final String? notes;
  final double? price;
  final bool isPaid;

  Delivery({
    required this.id,
    required this.trackingNumber,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.packageWeight,
    required this.packageDescription,
    required this.status,
    this.assignedTo,
    required this.estimatedTime,
    this.actualDeliveryTime,
    required this.createdAt,
    this.notes,
    this.price,
    this.isPaid = false,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      trackingNumber: json['trackingNumber'] ?? 'TRK${json['id']}',
      customerName: json['customerName'] ?? 'Client',
      customerPhone: json['customerPhone'] ?? 'Non disponible',
      customerEmail: json['customerEmail'],
      pickupAddress: json['pickupAddress'] ?? 'Adresse de prise en charge',
      deliveryAddress: json['deliveryAddress'] ?? 'Adresse de livraison',
      packageWeight: (json['packageWeight'] ?? 1.0).toDouble(),
      packageDescription: json['packageDescription'] ?? 'Colis standard',
      status: json['status'] ?? 'an_trete',
      assignedTo: json['assignedTo']?.toString(),
      estimatedTime: json['estimatedTime'] != null
          ? DateTime.parse(json['estimatedTime'])
          : DateTime.now().add(const Duration(hours: 2)),
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.tryParse(json['actualDeliveryTime'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'],
      price: json['price']?.toDouble(),
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'packageWeight': packageWeight,
      'packageDescription': packageDescription,
      'status': status,
      'assignedTo': assignedTo,
      'estimatedTime': estimatedTime.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'price': price,
      'isPaid': isPaid,
    };
  }

  Delivery copyWith({
    String? status,
    String? assignedTo,
    DateTime? actualDeliveryTime,
    bool? isPaid,
  }) {
    return Delivery(
      id: id,
      trackingNumber: trackingNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      packageWeight: packageWeight,
      packageDescription: packageDescription,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      estimatedTime: estimatedTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      createdAt: createdAt,
      notes: notes,
      price: price,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  bool get isPending => status == 'an_trete';
  bool get isInTransit => status == 'an_wout';
  bool get isDelivered => status == 'livre';
  bool get isCancelled => status == 'annile';

  Color get statusColor {
    switch (status) {
      case 'an_trete':
        return Colors.orange;
      case 'an_wout':
        return Colors.blue;
      case 'livre':
        return Colors.green;
      case 'annile':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'an_trete':
        return 'En traitement';
      case 'an_wout':
        return 'En route';
      case 'livre':
        return 'Livré';
      case 'annile':
        return 'Annulé';
      default:
        return status;
    }
  }
}