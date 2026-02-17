# Apendiks pou Diskloz Itilizasyon AI

**Non Etidyan an** _Harrigan Samuel_ 
**Tit Pwojè a:** DelivreRapide  
**Dat:** 10/02/26
---

## Enstriksyon
**Konplete apendiks sa si w itilize zouti Entèlijans Ayifisyèl nan pwojè ou a. Li te mèt te kòd, rechèch ki gen asistans AI, chatbot, oubyen nenpòt lòt zouti AI, ou dwe soumèt pwojè ou a ak dokiman sa.**

**Si w pat itilize zouti AI, Tcheke sa** 

☐ *Pa gen zouti AI ki te itilize pou travay sa*

---

## Istorik Itilizasyon Zouti AI

**Konplete yon seksyon pou chak zouti AI/Sesyon ou itilize:**

### Zouti AI #1

**Non/Platfòm Zouti a:** Genimini  
*(ekz., ChatGPT, Grammarly, GitHub Copilot, Rechèch Google, elatriyeee.)*

**Dat & Lè Itilizasyon an:** li pa fiks, diran tout deroulman travay la 

**Objektif Itilizasyon an:** assistans rechech  
*(Ekz., Deboge kòd, Asistans rechèch, elatriyee.)*

**_Prompt_ oubyen Rekèt ki te fèt la**
```
[Kopye/Kole ekzakteman tèks ou te tape nan zouti AI a]
1-si j'ai besoin de mettre deux couleur dans mon apbar sur flutter quel code je dois passer
2-commente ce code avec des explication le long
3-comment uttiliser opacity dans flutter sur une photo assets
4-ou placer card exactement
5je veux que mon card ne prend pas toute l'espaceverticale de mon ecran qu'est-ce que je dois modifier
6-comment je peut permettre a l'uttilisateur de choisir une date dans un calendrier

```

**Tout repons/output zouti AI a te bay la:**
```
[Kopye/Kole ekzakteman repons (san modifikasyon) ou jwenn nan men zouti AI a]
1 et 2-AppBar(
  // Le titre classique de votre application
  title: const Text('Mon AppBar Bicolore'),
  
  // 'flexibleSpace' est une zone qui occupe tout l'arrière-plan de l'AppBar.
  // C'est l'endroit idéal pour injecter des widgets de design comme des images ou des dégradés.
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      // On utilise un LinearGradient pour gérer la transition entre les couleurs
      gradient: LinearGradient(
        // 'begin' définit le point de départ de la première couleur
        begin: Alignment.topLeft, 
        
        // 'end' définit où la transition se termine
        end: Alignment.bottomRight, 
        
        // La liste des couleurs à appliquer (vous pouvez en mettre plus que deux !)
        colors: <Color>[
          Color(0xFF2196F3), // Un bleu vif
          Color(0xFF9C27B0), // Un violet profond
        ],
        
        // Optionnel : 'stops' permet de définir la répartition (ex: 0.3 pour 30% de bleu)
        // stops: [0.3, 0.7], 
      ),
    ),
  ),
  
  // On peut ajouter une ombre ou la supprimer (0.0) pour un look plus moderne
  elevation: 4.0, 
)
3-Image.asset(
  'assets/ma_photo.jpg',
  // On applique une couleur blanche avec opacité
  // 0.5 = 50% de visibilité
  color: Colors.white.withValues(alpha: 0.5), 
  // Ce mode permet de fusionner la couleur et l'image
  colorBlendMode: BlendMode.modulate, 
)
4- Dans le body de votre Scaffold (Une liste de fiches)
C'est l'endroit standard. Si vous avez plusieurs livraisons, vous devez placer vos Card à l'intérieur d'une ListView. Cela permet à l'utilisateur de faire défiler les fiches si elles dépassent de l'écran.
5-Si votre Card prend toute la hauteur de l'écran, c'est généralement parce qu'elle est placée dans un composant qui la "force" à s'étirer (comme un SizedBox.expand ou certains types de Column mal configurés) ou que vous n'avez pas utilisé de ListView.

Voici comment corriger cela selon votre situation :

1. La solution la plus courante : Utiliser ListView
Si vous mettez une Card directement dans le body d'un Scaffold, Flutter essaie parfois de lui donner tout l'espace disponible. En l'enveloppant dans une ListView, la carte ne prendra que la hauteur nécessaire pour afficher son contenu.

Dart
body: ListView(
  children: [
    _buildDeliveryCard(), // La carte s'adaptera à la taille de son texte
  ],
),
5-Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(), // La date affichée par défaut (aujourd'hui)
    firstDate: DateTime(2000),    // La date la plus ancienne possible
    lastDate: DateTime(2100),     // La date la plus lointaine possible
  );

  if (picked != null) {
    // On fait quelque chose avec la date choisie (ex: l'afficher ou l'enregistrer)
    print("Date choisie : ${picked.day}/${picked.month}/${picked.year}");
  }
}



```

**Kòman w te itilize repons ou te jwenn nan:**  
*tout kod Ai banm mw mandel mete explication nan tout poum pa oblije al mandel anko lem bezwen, mw chache konprann kod yo avan epi mwen adaptel ak prpje an*
```
[Ekzanp: "Mwen itilize kòd AI a ban mwen depi nan kòmansman, aprè mwen modifye non varyab yo pou li ka koresponn ak pwojè mwen an epi mwen teste li."]




```

**Kisa w aprann sou repons ou jwenn nan?**  
*(Kisa w aprann sou pwosès la? Kòman zouti AI sa ede w nan aprantisaj ak konpreyansyon w?)*
```
anpil bgy tankou: -pouw mete 2 koule nan app bar mp bzwn flexible place epi yon container avec yon gradient
-nou paka uttiliser opacity directement nan yon image assets 
-element body an paka pran plusieur element paran
-ajouter notification nan applicationm lan



```

## Kontribisyon Sou Travay Final La

**Pousantaj kontribisyon pa w antanke imen, sou travay final la:** 80%

------

### Zouti AI #2
_Rekopye menm seksyon anlè a, si gen lòt zouti_

---



---
<img width="203" height="104" alt="image" src="https://gist.github.com/user-attachments/assets/a979028b-66f8-4661-83fc-b22b41e0eb3b" />

## Rekonesans Entegrite Akadamik ESIH

Soumèt apendiks sa vle di ke mwen afime ke:
- V Mwen bay verite epi diskloz tout zouti AI mwen itilize pou pwojè sa
- V _Prompt_ ak rekèt mwen bay yo konplè epi ekzat
- V Mwen konprann si mwen pa diskloz tout zouti AI yo, sa ka kontribiye ak dezonè plis echèk mwen nan matyè sa

**Siyati Etidyan** Harrigan Samuel 
**Dat:** 16/02/26

---