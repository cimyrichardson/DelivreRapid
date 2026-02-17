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
  final _secureStorage = const FlutterSecureStorage();

  static const String KEY_USER = 'currentUser';
  static const String KEY_DELIVERIES = 'deliveries';
  static const String KEY_DRIVERS = 'drivers';
  static const String KEY_SETTINGS = 'settings';
  static const String KEY_LAST_SYNC = 'lastSync';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // USER
  Future<void> saveUser(User user) async {
    final json = jsonEncode(user.toJson());
    await _prefs.setString(KEY_USER, json);
    if (user.token != null) {
      await _secureStorage.write(key: 'auth_token', value: user.token);
    }
  }

  Future<User?> getUser() async {
    final json = _prefs.getString(KEY_USER);
    if (json != null) {
      return User.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs.remove(KEY_USER);
    await _secureStorage.delete(key: 'auth_token');
  }

  // DELIVERIES
  Future<void> saveDeliveries(List<Delivery> deliveries) async {
    final jsonList = deliveries.map((d) => d.toJson()).toList();
    await _prefs.setString(KEY_DELIVERIES, jsonEncode(jsonList));
  }

  Future<List<Delivery>> getDeliveries() async {
    final json = _prefs.getString(KEY_DELIVERIES);
    if (json != null) {
      final List<dynamic> list = jsonDecode(json);
      return list.map((item) => Delivery.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> addDelivery(Delivery delivery) async {
    final deliveries = await getDeliveries();
    deliveries.add(delivery);
    await saveDeliveries(deliveries);
  }

  Future<void> updateDelivery(Delivery updatedDelivery) async {
    final deliveries = await getDeliveries();
    final index = deliveries.indexWhere((d) => d.id == updatedDelivery.id);
    if (index != -1) {
      deliveries[index] = updatedDelivery;
      await saveDeliveries(deliveries);
    }
  }

  Future<void> deleteDelivery(String id) async {
    final deliveries = await getDeliveries();
    deliveries.removeWhere((d) => d.id == id);
    await saveDeliveries(deliveries);
  }

  // SETTINGS
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(KEY_SETTINGS, jsonEncode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final json = _prefs.getString(KEY_SETTINGS);
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
    final syncData = await getLastSync();
    syncData[key] = DateTime.now().toIso8601String();
    await _prefs.setString(KEY_LAST_SYNC, jsonEncode(syncData));
  }

  Future<Map<String, dynamic>> getLastSync() async {
    final json = _prefs.getString(KEY_LAST_SYNC);
    if (json != null) {
      return jsonDecode(json);
    }
    return {};
  }

  // TOKEN SECURE
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // CLEAR ALL
  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}