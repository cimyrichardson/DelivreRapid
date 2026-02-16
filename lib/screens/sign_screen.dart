import 'package:flutter/material.dart';


class sign extends StatefulWidget {
  const sign({super.key});

  @override
  State<sign> createState() => _signState();
}
//-----------------------tout sa se pou test-----------------------
class _signState extends State<sign> {


  // 2. Les contrôleurs pour récupérer le texte saisi par l'utilisateur
  final TextEditingController imel = TextEditingController();
  final TextEditingController pasword = TextEditingController();
  final TextEditingController konf = TextEditingController();
  final TextEditingController nom = TextEditingController();
  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // 3. Fonction pour gérer la logique de connexion
  void _login() {
    String bon_imel = imel.text.trim(); // .trim() enlève les espaces inutiles
    String bon_pasword = pasword.text;
    String konf_pas = konf.text;


    if(konf_pas!= bon_pasword || !isValidEmail(bon_imel) ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('imel oubyen modpas ou mete an pa bon'),
            backgroundColor: Colors.red),
      );

    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kont ou an kreye'),
            backgroundColor: Colors.green),
      );

    }


    // if () {
    // Si trouvé, on affiche un message de succès (ou on change de page)
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Connexion réussie !'), backgroundColor: Colors.green),
    //);
    //}
    //else {
    // Sinon, on affiche une erreur
    //ScaffoldMessenger.of(context).showSnackBar(
    //const SnackBar(content: Text('Email ou mot de passe incorrect'), backgroundColor: Colors.red),
    //);

  }
// --------------------------rive jiskela-------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SingleChildScrollView est ESSENTIEL pour que l'écran défile quand le clavier sort
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80), // Espace en haut

            // --- SECTION LOGO ---
            // On centre l'image horizontalement
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 300, // Taille de ton logo
              ),
            ),

            const SizedBox(height: 50),

            TextField(
              controller: nom, // nou rekipere nom moun lan
              // C'est ici que le clavier s'adapte pour l'email (touche @ visible)
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Non',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(), // Bordure autour du champ


              ),
            ),
            const SizedBox(height: 20),

            // --- CHAMP EMAIL ---
            TextField(
              controller: imel, // nou rekipere email la
              // C'est ici que le clavier s'adapte pour l'email (touche @ visible)
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Imel',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(), // Bordure autour du champ


              ),
            ),

            const SizedBox(height: 20),

            // --- CHAMP MOT DE PASSE ---
            TextField(
              controller: pasword,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Modpas ',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: konf,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'konfime Modpas ',
                prefixIcon: Icon(Icons.check),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // --- BOUTON DE CONNEXION ---
            SizedBox(
              width: double.infinity, // Le bouton prend toute la largeur
              height: 55,
              child: ElevatedButton(
                onPressed: _login, // Appelle la fonction de vérification
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Kreye kont',
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