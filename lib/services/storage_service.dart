import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/delivery.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();

  // Initialisation au démarrage (Appelée dans main.dart)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- GESTION UTILISATEUR (Sécurisé) ---
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // --- GESTION DES LIVRAISONS (CRUD Local) ---
  
  // Sauvegarder toute la liste
  Future<void> saveDeliveries(List<Delivery> deliveries) async {
    List<String> listJson = deliveries.map((d) => jsonEncode(d.toMap())).toList();
    await _prefs.setStringList('deliveries', listJson);
  }

  // Récupérer la liste
  List<Delivery> getDeliveries() {
    List<String>? listJson = _prefs.getStringList('deliveries');
    if (listJson == null) return [];
    return listJson.map((item) => Delivery.fromMap(jsonDecode(item))).toList();
  }

  // Ajouter une livraison (Create)
  Future<void> addDelivery(Delivery delivery) async {
    List<Delivery> current = getDeliveries();
    current.add(delivery);
    await saveDeliveries(current);
  }

  // Mettre à jour un statut (Update)
  Future<void> updateDeliveryStatus(String id, String newStatus) async {
    List<Delivery> current = getDeliveries();
    int index = current.indexWhere((d) => d.id == id);
    if (index != -1) {
      // On recrée l'objet avec le nouveau statut
      current[index] = Delivery(
        id: current[index].id,
        title: current[index].title,
        status: newStatus,
      );
      await saveDeliveries(current);
    }
  }

  // --- GESTION SYNC (Offline mode) ---
  Future<void> addToPendingSync(Delivery delivery) async {
    List<String> pending = _prefs.getStringList('pendingSync') ?? [];
    pending.add(jsonEncode(delivery.toMap()));
    await _prefs.setStringList('pendingSync', pending);
  }

  // Nettoyer après déconnexion
  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}