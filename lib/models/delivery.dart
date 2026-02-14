import 'package:flutter/material.dart';

class Delivery {
  // Pwopriyete prensipal yo
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
  
  // Detay kolye a
  final double packageWeight;
  final Map<String, double>? packageDimensions; // length, width, height
  final String packageDescription;
  final String? packageImage;
  
  // Estati ak asiyasyon
  final String status; // "an_trete", "an_wout", "livre", "annile"
  final String? assignedTo; // ID livrè a
  final String? assignedDriverName;
  final String? assignedDriverPhone;
  
  // Dat enpòtan
  final DateTime estimatedTime;
  final DateTime? actualDeliveryTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Lòt enfòmasyon
  final String? createdBy;
  final String? notes;
  final double? price;
  final bool isPaid;
  final double? distance; // an km
  final int? estimatedDuration; // an minit
  final List<Map<String, dynamic>>? statusHistory;
  final Map<String, dynamic>? additionalInfo;

  // Konstriktè prensipal
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

  // Konvèti JSON an objè Delivery (pou DummyJSON)
  factory Delivery.fromJson(Map<String, dynamic> json) {
    // Adapte selon estrikti DummyJSON
    // Sipoze n ap itilize /carts endpoint
    
    // Jwenn non kilyan an (si genyen)
    String customerName = 'Client';
    if (json['userId'] != null) {
      customerName = 'Client ${json['userId']}';
    }
    
    // Jwenn dat yo
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

  // Konvèti objè Delivery an JSON
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

  // Kreye yon kopi Delivery ak kèk modifikasyon
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

  // Metòd pou verifye estati
  bool get isPending => status == 'an_trete';
  bool get isInTransit => status == 'an_wout';
  bool get isDelivered => status == 'livre';
  bool get isCancelled => status == 'annile';
  
  // Jwenn koulè selon estati
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

  // Jwenn tèks estati an françai
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

  // Ajoute yon nouvo estati nan istorik
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