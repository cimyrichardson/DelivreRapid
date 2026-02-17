import 'package:flutter/material.dart';
import '../models/notif.dart';

class liv extends StatefulWidget {
  const liv({super.key});

  @override
  State<liv> createState() => _livState();
}

class _livState extends State<liv> {
  // Cette variable gère maintenant le passage de "Valider" à "Livrer"
  bool estValide = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/ava_liv.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
        ],
        title: const Text(
          "DelivreRapid",
          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFFF6B35),
                Colors.white,
              ],
            ),
          ),
        ),
        elevation: 4.0,
      ),
      body: Stack(
        children: [
          // 1. Fond : Logo centré
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 300,
              color: Colors.white.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.modulate,
            ),
          ),

          // 2. Contenu principal
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Enregistré le : 15/02/2026",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                fom_st("an wout"),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Enregistré par : Jean Dupont",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text("Description : Colis de 5kg composants fragiles."),
                            const SizedBox(height: 8),
                            const Text("Adres livrezon : 4, rue malmart, Tabarre Haiti."),

                            const Divider(height: 30),

                            // --- LES DEUX BOUTONS ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // BOUTON GAUCHE : VALIDER
                                ElevatedButton(
                                  onPressed: !estValide ? () {
                                    setState(() {
                                      estValide = true;
                                    });
                                    NotificationManager.addNotification("Livraison acceptée par le livreur ✅");
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(estValide ? "ACCEPTÉ" : "VALIDER"),
                                ),

                                // BOUTON DROITE : LIVRER
                                ElevatedButton(
                                  onPressed: estValide ? () {
                                    NotificationManager.addNotification("Colis en cours de livraison 🚚");
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                  ),
                                  child: const Text("LIVRER"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<List<String>>(
        valueListenable: NotificationManager.notifications,
        builder: (context, listeNotifs, child) {
          return Badge(
            label: Text(listeNotifs.length.toString()),
            isLabelVisible: listeNotifs.isNotEmpty,
            backgroundColor: Colors.red,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFF6B35),
              onPressed: () => _afficherLesNotifications(context, listeNotifs),
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

// --- Fonctions d'aide (Hors de la classe State) ---

Widget fom_st(String status) {
  Color color;
  switch (status) {
    case 'an tretman': color = Colors.orange; break;
    case 'an wout': color = Colors.blue; break;
    case 'livre': color = Colors.green; break;
    default: color = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color),
    ),
    child: Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );
}

void _afficherLesNotifications(BuildContext context, List<String> notifs) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Historique", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (notifs.isEmpty) const Text("Aucune notification"),
            // On utilise Flexible pour éviter les débordements si la liste est longue
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: notifs.map((msg) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(msg),
                )).toList(),
              ),
            ),
            TextButton(
              onPressed: () {
                NotificationManager.clearNotifications();
                Navigator.pop(context);
              },
              child: const Text("Tout effacer", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    },
  );
}