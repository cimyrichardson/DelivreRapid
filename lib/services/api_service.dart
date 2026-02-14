import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/delivery.dart';

class ApiService {
  // API DummyJSON base URL
  static const String baseUrl = 'https://dummyjson.com';
  
  // Timeout pou rekèt yo (10 segond)
  static const Duration timeout = Duration(seconds: 10);

  // --- FONKSYON ITILIZATÈ (USERS) ---

  // 1. Jwenn tout itilizatè yo
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

  // 2. Jwenn yon itilizatè pa ID
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

  // 3. Chèche itilizatè
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

  // --- FONKSYON LIVREZON (DELIVERIES) ---
  // Note: DummyJSON pa gen /deliveries, nou ap adapte /carts

  // 4. Jwenn tout livrezon yo
  Future<List<Delivery>> fetchAllDeliveries() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/carts'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Delivery> deliveries = [];
        
        for (var item in data['carts']) {
          // Adapte done yo pou koresponn ak modèl Delivery
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

  // 5. Jwenn yon livrezon pa ID
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

  // 6. Jwenn livrezon pou yon itilizatè
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

  // --- FONKSYON OTANTIFIKASYON (AUTH) ---

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
        
        // Ajoute enfòmasyon siplemantè
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

  // 8. Jwenn itilizatè aktyèl la (apre connexion)
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

  // --- FONKSYON KREYATIF (POU DEMO) ---

  // 9. Kreye yon nouvo livrezon (simile)
  Future<Map<String, dynamic>> createDelivery(Map<String, dynamic> deliveryData) async {
    // Paske DummyJSON pa pèmèt kreye livrezon, nou ap simulation
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

  // 10. Mete ajou estati livrezon
  Future<Map<String, dynamic>> updateDeliveryStatus(String id, String status) async {
    // Simulation
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

  // --- FONKSYON PRIVE ---

  // Adapte yon objè cart an livrezon
  Delivery _adaptCartToDelivery(Map<String, dynamic> cart) {
    // Jwenn total pwa a (simile)
    double totalWeight = 0;
    if (cart['products'] != null) {
      for (var product in cart['products']) {
        totalWeight += (product['weight'] ?? 1.0).toDouble();
      }
    }
    
    // Si pa gen pwa, bay yon valè default
    if (totalWeight == 0) totalWeight = 2.5;

    // Non kilyan an
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

  // Detèmine estati livrezon selon done cart la
  String _determineStatusFromCart(Map<String, dynamic> cart) {
    List<String> statuses = ['an_trete', 'an_wout', 'livre', 'annile'];
    // Sèvi ak id a pou detèmine yon estati konsistan
    int index = (cart['id'] ?? 1) % 4;
    return statuses[index];
  }

  // Detèmine wòl selon non itilizatè (pou demo)
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

  // Metòd pou verifye si gen entènèt
  Future<bool> hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}