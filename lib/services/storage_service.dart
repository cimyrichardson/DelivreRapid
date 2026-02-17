import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/delivery.dart';

class StorageService {
  static const String _currentUserKey = 'currentUser';
  static const String _deliveriesKey = 'deliveries';
  static const String _tokenKey = 'token';

  // --- Utilisateur Connecté ---
  
  // Sauvegarder l'utilisateur connecté
  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));
  }

  // Récupérer l'utilisateur connecté
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) return null;
    
    try {
      return User.fromJson(json.decode(userJson));
    } catch (e) {
      print('Erreur getCurrent User: $e');
      return null;
    }
  }

  // Vérifier si un utilisateur est connecté
  static Future<bool> isUserLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Déconnecter (supprimer l'utilisateur)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_tokenKey);
  }

  // --- Token ---

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // --- Livraisons ---

  // Sauvegarder les livraisons
  static Future<void> saveDeliveries(List<Delivery> deliveries) async {
    final prefs = await SharedPreferences.getInstance();
    final json = deliveries.map((d) => d.toJson()).toList();
    await prefs.setString(_deliveriesKey, jsonEncode(json));
  }

  // Récupérer les livraisons
  static Future<List<Delivery>> getDeliveries() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_deliveriesKey);
    
    if (json == null) return [];
    
    try {
      final list = jsonDecode(json) as List;
      return list.map((item) => Delivery.fromJson(item)).toList();
    } catch (e) {
      print('Erreur getDeliveries: $e');
      return [];
    }
  }

  // Ajouter une livraison
  static Future<void> addDelivery(Delivery delivery) async {
    final deliveries = await getDeliveries();
    deliveries.add(delivery);
    await saveDeliveries(deliveries);
  }

  // Mettre à jour une livraison
  static Future<void> updateDelivery(Delivery delivery) async {
    final deliveries = await getDeliveries();
    final index = deliveries.indexWhere((d) => d.id == delivery.id);
    
    if (index != -1) {
      deliveries[index] = delivery;
      await saveDeliveries(deliveries);
    }
  }

  // Supprimer une livraison
  static Future<void> deleteDelivery(String id) async {
    final deliveries = await getDeliveries();
    deliveries.removeWhere((d) => d.id == id);
    await saveDeliveries(deliveries);
  }

  // Effacer tout (logout complet)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
