# DelivreRapid

## Nom de l'application
**DelivreRapid** - Application de gestion de livraison

## Objectif de l'application
DelivreRapid est une application mobile qui permet de gérer facilement les livraisons de colis. Elle offre une plateforme complète pour les clients, les livreurs et les administrateurs. Les utilisateurs peuvent créer des livraisons, suivre leurs colis en temps réel, tandis que les livreurs peuvent gérer leurs tournées et les administrateurs superviser toutes les opérations.


## Problèmes résolus
- **Manque d'organisation** : Centralise toutes les livraisons en un seul endroit
- **Suivi difficile** : Permet de suivre les colis en temps réel
- **Communication** : Facilite le contact entre clients et livreurs
- **Gestion administrative** : Donne une vue d'ensemble aux administrateurs
- **Mode hors ligne** : Accès aux données même sans connexion internet

## Auteurs et rôles

| Membre | Rôle | Responsabilités |
|--------|------|-----------------|
| **[Nom Membre 1]** | UI/UX Designer & Navigation | - Création de tous les écrans<br>- Gestion de la navigation<br>- Design de l'interface utilisateur |
| **Richardson Cliford Cimy** | Développeur Data Layer | - Création des modèles (User, Delivery)<br>- Intégration API<br>- Parsing JSON |
| **[Jean Marie Rooslyn]** | Développeur Storage | - Mise en place SharedPreferences<br>- Fonctionnalités CRUD<br>- Gestion des images |

## Technologies utilisées
- **Flutter** : Framework de développement mobile
- **Dart** : Langage de programmation
- **SharedPreferences** : Stockage local
- **HTTP** : Communication avec l'API
- **DummyJSON** : API pour les données de démonstration
- **flutter_secure_storage** : Stockage sécurisé (mots de passe)

## Fonctionnalités principales

### Pour les clients
- Créer un compte et se connecter
- Créer une nouvelle livraison
- Suivre ses colis
- Contacter le livreur

### Fonctionalite a venir
- Recevoir des notifications
- Voir l'historique des livraisons

### Pour les livreurs
- Voir les livraisons assignées
- Mettre à jour le statut des livraisons
- Suivre sa tournée
- Contacter les clients
- Voir ses statistiques personnelles

### Pour les administrateurs
- Gérer tous les utilisateurs
- Assigner les livraisons aux livreurs
- Voir toutes les statistiques
- Gérer les paramètres de l'application

## Ce qu'on stocke localement

1. **currentUser** - Informations de l'utilisateur connecté
2. **deliveries** - Liste de toutes les livraisons
3. **drivers** - Liste des livreurs (pour admin)
4. **statistics** - Statistiques et résumés
5. **settings** - Préférences de l'application
6. **lastSync** - Dernière synchronisation avec l'API
7. **pendingSync** - Livraisons en attente de synchronisation
8. **lastLocation** - Dernière position de l'utilisateur
9. **activeDelivery** - Livraison en cours (pour livreur)

## Architecture de l'application

lib/
├── main.dart # Point d'entrée
├── models/
│ ├── user.dart # Modèle utilisateur
│ └── delivery.dart # Modèle livraison
├── services/
│ ├── api_service.dart # Requêtes API
│ └── storage_service.dart # SharedPreferences
├── screens/
│ ├── splash_screen.dart # Écran de chargement
│ ├── login_screen.dart # Écran de connexion
│ ├── register_screen.dart # Écran d'inscription
│ ├── home_screen.dart # Écran d'accueil
│ ├── delivery_detail.dart # Détail livraison
│ ├── create_delivery.dart # Créer livraison
│ ├── history_screen.dart # Historique
│ └── profile_screen.dart # Profil
└── widgets/
├── delivery_card.dart # Carte livraison
└── status_badge.dart # Badge statut

### Liens importants
1. **API utilisée**
    1. https://dummyjson.com/docs
2. **Vidéo démo** : Lien YouTube/Google Drive
