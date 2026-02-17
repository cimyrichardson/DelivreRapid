import 'package:flutter/material.dart';

// Ce "ValueNotifier" va stocker la liste des messages de notification
class NotificationManager {
  static final ValueNotifier<List<String>> notifications = ValueNotifier([]);

  static void addNotification(String message) {
    // On ajoute le message à la liste
    notifications.value = [...notifications.value, message];
  }

  static void clearNotifications() {
    notifications.value = [];
  }
}

