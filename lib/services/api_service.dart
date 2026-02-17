import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/delivery.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const Duration timeout = Duration(seconds: 10);

  // USERS
  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['users'] as List)
            .map((item) => User.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur fetchAllUsers: $e');
      return [];
    }
  }

  Future<User?> fetchUserById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Erreur fetchUserById: $e');
      return null;
    }
  }

  // DELIVERIES (adapté de /carts)
  Future<List<Delivery>> fetchAllDeliveries() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/carts'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['carts'] as List)
            .map((item) => _adaptCartToDelivery(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Erreur fetchAllDeliveries: $e');
      return [];
    }
  }

  Future<Delivery?> fetchDeliveryById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/carts/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return _adaptCartToDelivery(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Erreur fetchDeliveryById: $e');
      return null;
    }
  }

  // AUTH
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
        data['isLoggedIn'] = true;
        data['role'] = _determineRole(username);
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': 'Nom d\'utilisateur ou mot de passe incorrect'
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  // SIMULATION
  Future<Map<String, dynamic>> createDelivery(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Livraison créée avec succès',
      'data': {
        'id': DateTime.now().millisecondsSinceEpoch,
        ...data,
        'trackingNumber': 'TRK${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'an_trete',
      },
    };
  }

  Future<Map<String, dynamic>> updateDeliveryStatus(String id, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'success': true,
      'message': 'Statut mis à jour',
      'data': {'id': id, 'status': status, 'updatedAt': DateTime.now().toIso8601String()},
    };
  }

  // PRIVATE
  Delivery _adaptCartToDelivery(Map<String, dynamic> cart) {
    return Delivery(
      id: cart['id'].toString(),
      trackingNumber: 'DLV${cart['id']}',
      customerName: 'Client ${cart['userId']}',
      customerPhone: 'Non disponible',
      pickupAddress: 'Entrepôt principal',
      deliveryAddress: 'Adresse de livraison #${cart['id']}',
      packageWeight: 2.5,
      packageDescription: 'Colis avec ${cart['totalProducts']} articles',
      status: _getStatus(cart['id']),
      estimatedTime: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now(),
      price: cart['total']?.toDouble(),
      isPaid: true,
    );
  }

  String _getStatus(int id) {
    List<String> statuses = ['an_trete', 'an_wout', 'livre', 'annile'];
    return statuses[id % 4];
  }

  String _determineRole(String username) {
    String u = username.toLowerCase();
    if (u.contains('admin')) return 'admin';
    if (u.contains('driver') || u.contains('livreur')) return 'livre';
    return 'kilyan';
  }
}