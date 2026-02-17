import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/delivery.dart';

class ApiService {
  // API DummyJSON base URL
  static const String baseUrl = 'https://dummyjson.com';
  
  // Timeout pou requêtes HTTP
  static const Duration timeout = Duration(seconds: 10);

  //--- Fonctions pour les utilisateurs (Users) ---

  // 1. Recuperation de tous les utilisateurs
  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<User> users = [];
        
        for (var item in data['users']) {
          users.add(User.fromJson(item));
        }
        
        return users;
      } else {
        throw Exception('Erreur ${response.statusCode}: Impossible de charger les utilisateurs');
      }
    } catch (e) {
      print('Erreur fetchAllUsers: $e');
      return [];
    }
  }

  // 2. Recuperation d'un utilisateur par ID
  Future<User?> fetchUserById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur fetchUserById: $e');
      return null;
    }
  }

  // 3. Recherche d'utilisateurs par nom ou email
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/search?q=$query'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<User> users = [];
        
        for (var item in data['users']) {
          users.add(User.fromJson(item));
        }
        
        return users;
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur searchUsers: $e');
      return [];
    }
  }

  // --- Fonctions pour les livraisons (Deliveries) ---
  // Note: DummyJSON ne dispose pas d'une API spécifique pour les livraisons, 
  //donc nous allons utiliser les endpoints de "carts" pour simuler les livraisons. 
  //Nous allons adapter les données des carts pour correspondre à notre modèle de Delivery.

  // 4. Recuperation de toutes les livraisons
  Future<List<Delivery>> fetchAllDeliveries() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/carts'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Delivery> deliveries = [];
        
        for (var item in data['carts']) {
          // Adapte les données du cart pour créer une Delivery
          Delivery delivery = _adaptCartToDelivery(item);
          deliveries.add(delivery);
        }
        
        return deliveries;
      } else {
        throw Exception('Erreur ${response.statusCode}: Impossible de charger les livraisons');
      }
    } catch (e) {
      print('Erreur fetchAllDeliveries: $e');
      return [];
    }
  }

  // 5. Recuperation d'une livraison par ID
  Future<Delivery?> fetchDeliveryById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/carts/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _adaptCartToDelivery(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur fetchDeliveryById: $e');
      return null;
    }
  }

  // 6. Recuperation des livraisons d'un utilisateur spécifique
  Future<List<Delivery>> fetchDeliveriesByUser(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/carts/user/$userId'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Delivery> deliveries = [];
        
        for (var item in data['carts']) {
          deliveries.add(_adaptCartToDelivery(item));
        }
        
        return deliveries;
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur fetchDeliveriesByUser: $e');
      return [];
    }
  }

  // --- Fonctions pour l'authentification (Authentication) ---

  // 7. Connexion
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Ajouter des informations supplémentaires pour la session
        data['isLoggedIn'] = true;
        data['role'] = _determineRoleFromUsername(username);
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Nom d\'utilisateur ou mot de passe incorrect',
        };
      }
    } catch (e) {
      print('Erreur login: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  // 8. Obtenir les informations de l'utilisateur connecté
  Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur getCurrentUser: $e');
      return null;
    }
  }

  // --- Fonctions pour la gestion des livraisons (Deliveries) ---

  // 9. Créer une nouvelle livraison
  Future<Map<String, dynamic>> createDelivery(Map<String, dynamic> deliveryData) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Livraison créée avec succès',
      'data': {
        'id': DateTime.now().millisecondsSinceEpoch,
        ...deliveryData,
        'trackingNumber': 'TRK${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'an_trete',
      },
    };
  }

  // 10. Mettre à jour le statut d'une livraison
  Future<Map<String, dynamic>> updateDeliveryStatus(String id, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Statut mis à jour avec succès',
      'data': {
        'id': id,
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  // --- Fonctions utilitaires ---

  // Adapter les données d'un cart pour créer une Delivery
  Delivery _adaptCartToDelivery(Map<String, dynamic> cart) {
    double totalWeight = 0;
    if (cart['products'] != null) {
      for (var product in cart['products']) {
        totalWeight += (product['weight'] ?? 1.0).toDouble();
      }
    }
    
    // Si le poids total est de 0 (ce qui peut arriver si les produits n'ont pas de poids défini), 
    //on attribue un poids par défaut de 2.5 kg
    if (totalWeight == 0) totalWeight = 2.5;

    // Déterminer le nom du client à partir de l'ID de l'utilisateur, 
    //ou utiliser un nom générique si l'ID n'est pas disponible
    String customerName = 'Client ${cart['userId'] ?? 'inconnu'}';

    return Delivery(
      id: cart['id']?.toString() ?? '',
      trackingNumber: 'DLV${cart['id'] ?? DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName,
      customerPhone: 'Non disponible',
      customerEmail: 'client@email.com',
      pickupAddress: 'Entrepôt principal, Port-au-Prince',
      deliveryAddress: 'Adresse de livraison #${cart['id'] ?? ''}',
      packageWeight: totalWeight,
      packageDescription: 'Colis contenant ${cart['totalProducts'] ?? 0} articles',
      status: _determineStatusFromCart(cart),
      estimatedTime: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now(),
      price: cart['total']?.toDouble(),
      isPaid: true,
      additionalInfo: {
        'totalProducts': cart['totalProducts'],
        'totalQuantity': cart['totalQuantity'],
        'discountedTotal': cart['discountedTotal'],
      },
    );
  }

  // Déterminer le statut de la livraison à partir des données du cart (pour simulation)
  String _determineStatusFromCart(Map<String, dynamic> cart) {
    List<String> statuses = ['an_trete', 'an_wout', 'livre', 'annile'];
    // Utiliser l'ID du cart pour déterminer un statut de manière pseudo-aléatoire
    int index = (cart['id'] ?? 1) % 4;
    return statuses[index];
  }

  // Déterminer le rôle de l'utilisateur à partir de son nom d'utilisateur (pour simulation)
  String _determineRoleFromUsername(String username) {
    String lowerUsername = username.toLowerCase();
    if (lowerUsername.contains('admin')) {
      return 'admin';
    } else if (lowerUsername.contains('driver') || lowerUsername.contains('livreur')) {
      return 'livre';
    } else {
      return 'kilyan';
    }
  }

  // Vérifier la connexion Internet
  Future<bool> hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}