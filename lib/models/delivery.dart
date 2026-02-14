import 'package:flutter/material.dart';

class Delivery {
  // Attributs de base pour une livraison
  final String id;
  final String trackingNumber;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String pickupAddress;
  final String deliveryAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  
  // Details du colis
  final double packageWeight;
  final Map<String, double>? packageDimensions; // ex: {'longueur': 10, 'largeur': 5, 'hauteur': 3}
  final String packageDescription;
  final String? packageImage;
  
  // Statut et assignation
  final String status; // "an_trete", "an_wout", "livre", "annile"
  final String? assignedTo; // ID du livreur assigné
  final String? assignedDriverName;
  final String? assignedDriverPhone;
  
  // Dat enpòtan
  final DateTime estimatedTime;
  final DateTime? actualDeliveryTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Informations Suplementaires
  final String? createdBy;
  final String? notes;
  final double? price;
  final bool isPaid;
  final double? distance; // en kilomètres
  final int? estimatedDuration; // en minutes
  final List<Map<String, dynamic>>? statusHistory;
  final Map<String, dynamic>? additionalInfo;

  // Constructeur Principal pour Delivery
  Delivery({
    required this.id,
    required this.trackingNumber,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.packageWeight,
    this.packageDimensions,
    required this.packageDescription,
    this.packageImage,
    required this.status,
    this.assignedTo,
    this.assignedDriverName,
    this.assignedDriverPhone,
    required this.estimatedTime,
    this.actualDeliveryTime,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.notes,
    this.price,
    this.isPaid = false,
    this.distance,
    this.estimatedDuration,
    this.statusHistory,
    this.additionalInfo,
  });

  // Factory constructor pour créer une Delivery à partir d'un JSON
  factory Delivery.fromJson(Map<String, dynamic> json) {
    String customerName = 'Client';
    if (json['userId'] != null) {
      customerName = 'Client ${json['userId']}';
    }
    
    // Si l'ID n'est pas fourni, on génère un ID unique basé sur le timestamp actuel
    DateTime now = DateTime.now();
    
    return Delivery(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      trackingNumber: 'TRK${json['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      customerName: json['customerName'] ?? customerName,
      customerPhone: json['customerPhone'] ?? 'Non disponible',
      customerEmail: json['customerEmail'],
      pickupAddress: json['pickupAddress'] ?? 'Adresse de prise en charge',
      deliveryAddress: json['deliveryAddress'] ?? 'Adresse de livraison',
      pickupLatitude: json['pickupLatitude']?.toDouble(),
      pickupLongitude: json['pickupLongitude']?.toDouble(),
      deliveryLatitude: json['deliveryLatitude']?.toDouble(),
      deliveryLongitude: json['deliveryLongitude']?.toDouble(),
      packageWeight: (json['packageWeight'] ?? 1.0).toDouble(),
      packageDimensions: json['packageDimensions'] != null 
          ? Map<String, double>.from(json['packageDimensions'])
          : null,
      packageDescription: json['packageDescription'] ?? 'Colis standard',
      packageImage: json['packageImage'],
      status: json['status'] ?? 'an_trete',
      assignedTo: json['assignedTo']?.toString(),
      assignedDriverName: json['assignedDriverName'],
      assignedDriverPhone: json['assignedDriverPhone'],
      estimatedTime: json['estimatedTime'] != null
          ? DateTime.tryParse(json['estimatedTime']) ?? now.add(const Duration(hours: 2))
          : now.add(const Duration(hours: 2)),
      actualDeliveryTime: json['actualDeliveryTime'] != null
          ? DateTime.tryParse(json['actualDeliveryTime'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? now
          : now,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      createdBy: json['createdBy']?.toString(),
      notes: json['notes'],
      price: json['price']?.toDouble(),
      isPaid: json['isPaid'] ?? false,
      distance: json['distance']?.toDouble(),
      estimatedDuration: json['estimatedDuration'],
      statusHistory: json['statusHistory'] != null
          ? List<Map<String, dynamic>>.from(json['statusHistory'])
          : null,
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }

  // Convertir une Delivery en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'packageWeight': packageWeight,
      'packageDimensions': packageDimensions,
      'packageDescription': packageDescription,
      'packageImage': packageImage,
      'status': status,
      'assignedTo': assignedTo,
      'assignedDriverName': assignedDriverName,
      'assignedDriverPhone': assignedDriverPhone,
      'estimatedTime': estimatedTime.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'notes': notes,
      'price': price,
      'isPaid': isPaid,
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'statusHistory': statusHistory,
      'additionalInfo': additionalInfo,
    };
  }

  // Créer une copie de la Delivery avec des modifications optionnelles
  Delivery copyWith({
    String? status,
    String? assignedTo,
    String? assignedDriverName,
    String? assignedDriverPhone,
    DateTime? actualDeliveryTime,
    DateTime? updatedAt,
    String? notes,
    bool? isPaid,
    List<Map<String, dynamic>>? statusHistory,
  }) {
    return Delivery(
      id: id,
      trackingNumber: trackingNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      packageWeight: packageWeight,
      packageDimensions: packageDimensions,
      packageDescription: packageDescription,
      packageImage: packageImage,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      assignedDriverPhone: assignedDriverPhone ?? this.assignedDriverPhone,
      estimatedTime: estimatedTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy,
      notes: notes ?? this.notes,
      price: price,
      isPaid: isPaid ?? this.isPaid,
      distance: distance,
      estimatedDuration: estimatedDuration,
      statusHistory: statusHistory ?? this.statusHistory,
      additionalInfo: additionalInfo,
    );
  }

  // Methodes pour vérifier le statut de la livraison
  bool get isPending => status == 'an_trete';
  bool get isInTransit => status == 'an_wout';
  bool get isDelivered => status == 'livre';
  bool get isCancelled => status == 'annile';
  
  // Obtenir la couleur associée au statut
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

  // Obtenir le texte lisible du statut
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

  // Ajouter une entrée à l'historique des statuts
  Delivery addStatusToHistory(String newStatus) {
    List<Map<String, dynamic>> newHistory = statusHistory ?? [];
    newHistory.add({
      'status': newStatus,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    return copyWith(
      status: newStatus,
      statusHistory: newHistory,
    );
  }

  @override
  String toString() {
    return 'Delivery(id: $id, tracking: $trackingNumber, status: $status)';
  }
}