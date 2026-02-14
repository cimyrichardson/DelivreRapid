import 'package:flutter_test/flutter_test.dart';
import 'package:delivrerapid/models/user.dart';
import 'package:delivrerapid/models/delivery.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson devrait créer un utilisateur correctement', () {
      final json = {
        'id': '1',
        'name': 'Jean Dupont',
        'email': 'jean@example.com',
        'phone': '+509 1234 5678',
        'role': 'kilyan',
        'token': 'abc123',
        'isLoggedIn': true,
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.name, 'Jean Dupont');
      expect(user.email, 'jean@example.com');
      expect(user.role, 'kilyan');
      expect(user.isLoggedIn, true);
    });

    test('User.toJson devrait sérialiser correctement', () {
      final user = User(
        id: '1',
        name: 'Marie Paul',
        email: 'marie@example.com',
        phone: '+509 9876 5432',
        role: 'livre',
        token: 'xyz789',
        isLoggedIn: true,
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Marie Paul');
      expect(json['role'], 'livre');
    });

    test('User constructeurs nommés - Driver', () {
      final driver = User.driver(
        id: '2',
        name: 'Pierre Livreur',
        email: 'pierre@example.com',
        phone: '+509 5555 5555',
      );

      expect(driver.role, 'livre');
      expect(driver.isDriver, true);
      expect(driver.isClient, false);
    });

    test('User.copyWith devrait créer une copie modifiée', () {
      final user = User(
        id: '1',
        name: 'Jean',
        email: 'jean@example.com',
        phone: '1234567',
        role: 'kilyan',
      );

      final updatedUser = user.copyWith(
        isLoggedIn: true,
        token: 'newToken123',
      );

      expect(updatedUser.name, 'Jean'); // Inchangé
      expect(updatedUser.isLoggedIn, true); // Modifié
      expect(updatedUser.token, 'newToken123'); // Modifié
    });

    test('User.initials devrait retourner les bonnes initiales', () {
      final user = User(
        id: '1',
        name: 'Jean Dupont',
        email: 'jean@example.com',
        phone: '1234567',
        role: 'kilyan',
      );

      expect(user.initials, 'JD');
    });
  });

  group('Delivery Model Tests', () {
    test('Delivery.fromJson devrait créer une livraison correctement', () {
      final json = {
        'id': '100',
        'trackingNumber': 'TRK123456',
        'customerName': 'Client Test',
        'customerPhone': '+509 1111 1111',
        'pickupAddress': 'Entrepôt Port-au-Prince',
        'deliveryAddress': 'Rue Normale, PAP',
        'packageWeight': 5.5,
        'packageDescription': 'Colis test',
        'status': 'an_wout',
        'estimatedTime': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final delivery = Delivery.fromJson(json);

      expect(delivery.id, '100');
      expect(delivery.trackingNumber, 'TRK123456');
      expect(delivery.customerName, 'Client Test');
      expect(delivery.status, 'an_wout');
      expect(delivery.isInTransit, true);
    });

    test('Delivery status getters devrait fonctionner', () {
      final delivery = Delivery(
        id: '1',
        trackingNumber: 'TRK001',
        customerName: 'Test',
        customerPhone: '1234567',
        pickupAddress: 'A',
        deliveryAddress: 'B',
        packageWeight: 1.0,
        packageDescription: 'Test',
        status: 'livre',
        estimatedTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(delivery.isDelivered, true);
      expect(delivery.isPending, false);
      expect(delivery.isInTransit, false);
      expect(delivery.isCancelled, false);
    });

    test('Delivery.copyWith devrait mettre à jour le statut', () {
      final delivery = Delivery(
        id: '1',
        trackingNumber: 'TRK001',
        customerName: 'Test',
        customerPhone: '1234567',
        pickupAddress: 'A',
        deliveryAddress: 'B',
        packageWeight: 1.0,
        packageDescription: 'Test',
        status: 'an_trete',
        estimatedTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final updated = delivery.copyWith(status: 'an_wout');

      expect(updated.status, 'an_wout');
      expect(updated.isInTransit, true);
      expect(delivery.status, 'an_trete'); // Original inchangé
    });

    test('Delivery.addStatusToHistory devrait ajouter au historique', () {
      final delivery = Delivery(
        id: '1',
        trackingNumber: 'TRK001',
        customerName: 'Test',
        customerPhone: '1234567',
        pickupAddress: 'A',
        deliveryAddress: 'B',
        packageWeight: 1.0,
        packageDescription: 'Test',
        status: 'an_trete',
        estimatedTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final updated = delivery.addStatusToHistory('an_wout');

      expect(updated.status, 'an_wout');
      expect(updated.statusHistory, isNotEmpty);
      expect(updated.statusHistory?[0]['status'], 'an_wout');
    });

    test('Delivery.toJson devrait sérialiser correctement', () {
      final delivery = Delivery(
        id: '1',
        trackingNumber: 'TRK001',
        customerName: 'Test',
        customerPhone: '1234567',
        pickupAddress: 'A',
        deliveryAddress: 'B',
        packageWeight: 1.0,
        packageDescription: 'Test',
        status: 'an_wout',
        estimatedTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final json = delivery.toJson();

      expect(json['id'], '1');
      expect(json['trackingNumber'], 'TRK001');
      expect(json['status'], 'an_wout');
      expect(json['packageWeight'], 1.0);
    });
  });
}
