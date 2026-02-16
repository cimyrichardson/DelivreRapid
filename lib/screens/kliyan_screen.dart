import 'package:flutter/material.dart';
import '../models/colors.dart';

class kliyan extends StatefulWidget {
  const kliyan({super.key});

  @override
  State<kliyan> createState() => _kliyanState();
}

void touch(){
  print("ou touchem");
}

class _kliyanState extends State<kliyan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: Image.asset('../assets/images/avatar.png',
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
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFF6B35)),
              child: Text(
                "Meni Navige",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Akèy"),
              onTap: () {
                Navigator.pop(context);

              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Istorik"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const istorik()),
                );
              },
            ),
          ],
        ),
      ),

        body:

        Stack(
          children: [
            // --- COUCHE 1 : Ton Logo en fond ---
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                // On garde tes réglages d'opacité
                color: Colors.white.withValues(alpha: 0.5),
                colorBlendMode: BlendMode.modulate,
              ),
            ),

            // --- COUCHE 2 : Ta liste de Cards ---
            // On utilise ListView pour que les cartes puissent défiler par-dessus le logo
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  elevation: 3,
                  // L'ombre sous la fiche
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // Espace autour de la fiche
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  // Coins arrondis
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Espace interne
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Aligne le texte à gauche
                      children: [
                        // Ligne du haut : Date et Statut
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Enregistré le : 15/02/2026",
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            fom_st("an wout"), // Fonction pour le badge de couleur
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Nom de la personne
                        Text(
                          "Enregistré par : Jean Dupont",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),

                        // Description du colis
                        const Text(
                          "Description :",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.blueGrey),
                        ),
                        Text(
                          "Colis de 5kg contenant des composants électroniques fragiles.",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ajou()),
            );
          },
          tooltip: 'ajouter',
          backgroundColor: const Color(0xFFFF6B35),
          child: const Icon(Icons.add),
        ),
    );
  }
}
//-----------------------------istorik--------------------------------
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

class istorik extends StatelessWidget {
  const istorik({super.key});





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: Image.asset('../assets/images/avatar.png',
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
      body: Column(
        mainAxisSize: MainAxisSize.min, // <--- TRÈS IMPORTANT
        children: [
      Card(
        elevation: 3,
        // L'ombre sous la fiche
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Espace autour de la fiche
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Coins arrondis
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Espace interne
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Aligne le texte à gauche
            children: [
              // Ligne du haut : Date et Statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enregistré le : 15/02/2026",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  fom_st("an wout"), // Fonction pour le badge de couleur
                ],
              ),
              const SizedBox(height: 12),

              // Nom de la personne
              Text(
                "Enregistré par : Jean Dupont",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Description du colis
              const Text(
                "Description :",
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.blueGrey),
              ),
              Text(
                "Colis de 5kg contenant des composants électroniques fragiles.",
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    ],
    ),
      );
  }

}
//-----------------------------nouveau livraison--------------------------
class ajou extends StatefulWidget {
  const ajou({super.key});

  @override
  State<ajou> createState() => _ajouState();
}

class _ajouState extends State<ajou> {

  TextEditingController date = TextEditingController();
  TextEditingController nom = TextEditingController();
  TextEditingController adres_liv = TextEditingController();
  TextEditingController adres_re = TextEditingController();


 void kreye() {
    print("ou kreye");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),

            child: Image.asset('../assets/images/avatar.png',
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


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 50),

            TextField(
              controller: nom,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Non moun kap resevwa livrezon an',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(), // Bordure autour du champ


              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: adres_liv,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'adresse pou rekipere koli an',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(), // Bordure autour du champ


              ),
            ),
            const SizedBox(height: 20),

            // --- adresse---
            TextField(
              controller: adres_re,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'adresse moun kap resevwa livrezon',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(), // Bordure autour du champ


              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: date,
              readOnly: true, // Empêche l'utilisateur d'écrire manuellement
              decoration: const InputDecoration(
                labelText: "Date de livraison",
                suffixIcon: Icon(Icons.calendar_today), // Petite icône de calendrier
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                // On appelle notre fonction calendrier
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  // On formate la date pour l'afficher dans le champ
                  String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  date.text = formattedDate;
                }
              },
            ),



            const SizedBox(height: 30),

            // --- BOUTON DE CONNEXION ---
            SizedBox(
              width: double.infinity, // Le bouton prend toute la largeur
              height: 55,
              child: ElevatedButton(
                onPressed: kreye, // Appelle la fonction de vérification
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Kreye yon livrezon',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





