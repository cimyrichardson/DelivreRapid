import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/delivery.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  
  bool _isInitialized = false;

  // Initialiser le service (à appeler dans main.dart)
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = const FlutterSecureStorage();
      _isInitialized = true;
    }
  }

  // Vérifier que le service est initialisé
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // USER
  Future<void> saveUser(User user) async {
    await _ensureInitialized();
    final json = jsonEncode(user.toJson());
    await _prefs.setString('currentUser', json);
    if (user.token != null) {
      await _secureStorage.write(key: 'auth_token', value: user.token);
    }
  }

  Future<User?> getUser() async {
    await _ensureInitialized();
    final json = _prefs.getString('currentUser');
    if (json != null) {
      return User.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<void> clearUser() async {
    await _ensureInitialized();
    await _prefs.remove('currentUser');
    await _secureStorage.delete(key: 'auth_token');
  }

  // DELIVERIES
  Future<void> saveDeliveries(List<Delivery> deliveries) async {
    await _ensureInitialized();
    final jsonList = deliveries.map((d) => d.toJson()).toList();
    await _prefs.setString('deliveries', jsonEncode(jsonList));
  }

  Future<List<Delivery>> getDeliveries() async {
    await _ensureInitialized();
    final json = _prefs.getString('deliveries');
    if (json != null) {
      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => Delivery.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> addDelivery(Delivery delivery) async {
    await _ensureInitialized();
    final deliveries = await getDeliveries();
    deliveries.add(delivery);
    await saveDeliveries(deliveries);
  }

  Future<void> updateDelivery(Delivery updatedDelivery) async {
    await _ensureInitialized();
    final deliveries = await getDeliveries();
    final index = deliveries.indexWhere((d) => d.id == updatedDelivery.id);
    if (index != -1) {
      deliveries[index] = updatedDelivery;
      await saveDeliveries(deliveries);
    }
  }

  Future<void> deleteDelivery(String id) async {
    await _ensureInitialized();
    final deliveries = await getDeliveries();
    deliveries.removeWhere((d) => d.id == id);
    await saveDeliveries(deliveries);
  }

  // SETTINGS
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    await _prefs.setString('settings', jsonEncode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    await _ensureInitialized();
    final json = _prefs.getString('settings');
    if (json != null) {
      return jsonDecode(json);
    }
    return {
      'theme': 'clair',
      'language': 'fr',
      'notifications': true,
      'weightUnit': 'kg',
    };
  }

  // LAST SYNC
  Future<void> updateLastSync(String key) async {
    await _ensureInitialized();
    final syncData = await getLastSync();
    syncData[key] = DateTime.now().toIso8601String();
    await _prefs.setString('lastSync', jsonEncode(syncData));
  }

  Future<Map<String, dynamic>> getLastSync() async {
    await _ensureInitialized();
    final json = _prefs.getString('lastSync');
    if (json != null) {
      return jsonDecode(json);
    }
    return {};
  }

  // TOKEN SECURE
  Future<String?> getToken() async {
    await _ensureInitialized();
    return await _secureStorage.read(key: 'auth_token');
  }

  // CLEAR ALL
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}