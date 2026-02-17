import 'package:flutter/material.dart';
import '../models/notif.dart';

class adm extends StatefulWidget {
  const adm({super.key});

  @override
  State<adm> createState() => _admState();
}

class _admState extends State<adm> {

  String mocheche = ""; // Texte saisi dans la barre
  DateTime? datchwazi;  // Date choisie via le calendrier
  bool peye = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: Image.asset('../assets/images/ava_adm.png',
              width:50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
        ],

        title: const Text("DelivreRapid",
          style: TextStyle(
              fontSize: 42, color: Colors.white
          ),

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
            // 1. Fond : Ton logo centré
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                color: Colors.white.withValues(alpha: 0.5),
                colorBlendMode: BlendMode.modulate,
              ),
            ),

            // 2. Contenu : Barre de recherche + Liste de cartes
            Column(
              children: [
                // --- LA BARRE DE RECHERCHE ---
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                mocheche = value.toLowerCase();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: "Rechercher (Nom ou Code...)",
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Bouton Calendrier
                      Container(
                        decoration: BoxDecoration(
                          color: datchwazi == null ? Colors.blue : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.calendar_month, color: Colors.white),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                datchwazi = picked;
                              });
                            }
                          },
                        ),
                      ),

                      if (datchwazi != null)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => datchwazi = null),
                        ),
                    ],
                  ),
                ),

                // --- LA LISTE DES CARTES ---
                Expanded( // Expanded est crucial ici pour que la liste prenne le reste de la place
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
                              const Text(
                                "Description : Colis de 5kg composants fragiles.",
                                style: TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Adres livrezon : 4, rue malmart, Tabarre Haiti.",
                                style: TextStyle(color: Colors.black87),
                              ),
                              const Divider(),
                              CheckboxListTile(
                                title: const Text("Livraison payée", style: TextStyle(fontSize: 14)),
                                value: peye,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: Colors.green,
                                onChanged: (bool? value) {
                                  setState(() {
                                    peye = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => print("Refusé"),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text("REFUSER"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: peye ? () {print("Validé");
                                    NotificationManager.addNotification("Nouvo livrezon pou Jean Dupont ✅");} : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[300],
                                    ),
                                    child: const Text("VALIDER"),
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

// --- BOUTON FLOTTANT (Placé après le body dans le Scaffold) ---
        floatingActionButton: ValueListenableBuilder<List<String>>(
          valueListenable: NotificationManager.notifications,
          builder: (context, maListe, child) {
            return Badge(
              label: Text(maListe.length.toString()),
              isLabelVisible: maListe.isNotEmpty,
              backgroundColor: Colors.red,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFFF6B35),
                onPressed: () {
                  _afficherLesNotifications(context, maListe);
                },
                child: const Icon(Icons.notifications),
              ),
            );
          },
        ),
    );
        }
}



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
      color: color.withValues(alpha: 0.2), // Fond léger
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color), // Bordure colorée
    ),
    child: Text(
      status,
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );
}

//----------------------recherche--------------------------------------
class chache extends StatefulWidget {
  const chache({super.key});

  @override
  State<chache> createState() => _chacheState();
}

class _chacheState extends State<chache> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
void _afficherLesNotifications(BuildContext context, List<String> notifs) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Notifications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            if (notifs.isEmpty) const Text("Aucune nouvelle notification"),
            ...notifs.map((n) =>
                ListTile(title: Text(n), leading: const Icon(Icons.info))),
            TextButton(
              onPressed: () {
                NotificationManager.clearNotifications();
                Navigator.pop(context);
              },
              child: const Text("Tout effacer"),
            )
          ],
        ),
      );
    },
  );
}