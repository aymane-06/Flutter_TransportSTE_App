# Transport Management Mobile App

Une application mobile Flutter développée pour la gestion des opérations de transport. Cette application permet aux chauffeurs  d'une société de transport de suivre les voyages, gérer les frais et maintenir une traçabilité complète des opérations.

## Table des matières

- [Description](#description)
- [Fonctionnalités](#fonctionnalités)
- [Technologies utilisées](#technologies-utilisées)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Architecture](#architecture)
- [Tests](#tests)
- [Déploiement](#déploiement)
- [Contribution](#contribution)
- [Auteurs](#auteurs)
- [Licence](#licence)

## Description

Transport Management Mobile App est une application mobile Flutter conçue pour optimiser la gestion des opérations de transport. Elle s'intègre parfaitement avec un backend Odoo 18 via API REST pour offrir une solution complète de gestion de flotte, suivi des voyages et contrôle financier.

L'application cible principalement deux types d'utilisateurs :
- **Chauffeurs** : pour consulter leurs voyages assignés, mettre à jour les statuts et saisir les frais
- **Gestionnaires** : pour superviser la flotte, valider les frais et accéder aux indicateurs de performance

## Fonctionnalités

### Authentification et sécurité
- Système d'authentification sécurisé 
- Sessions persistantes avec déconnexion automatique
- Validation côté client et serveur

### Interface chauffeur
- Dashboard personnalisé avec liste des voyages assignés
- Consultation détaillée des voyages (itinéraire, horaires, véhicule assigné)
- Mise à jour du statut des voyages (en attente, en cours, terminé, incident)
- Saisie des frais de route avec géolocalisation automatique
- Prise de photos pour justificatifs (carburant, péages, réparations)
- Notifications push pour nouvelles affectations
- Historique des voyages et frais

## Technologies utilisées

### Frontend
- **Framework** : Flutter (Dart)
- **Architecture** : MVVM (Model-View-ViewModel)
- **Gestion d'état** : Flutter BLoC
- **Interface utilisateur** : Material Design

### Backend et intégration
- **Backend** : Odoo 18 (Python)
- **Base de données** : PostgreSQL
- **API** : REST API

### Packages Flutter principaux
```yaml
dependencies:
  flutter_bloc: ^8.1.3        # Gestion d'état
  dio: ^5.3.2                  # Client HTTP
  shared_preferences: ^2.2.2   # Stockage local
  geolocator: ^9.0.2          # Géolocalisation
  image_picker: ^1.0.4        # Prise de photos
  firebase_messaging: ^14.7.9 # Notifications push
  jwt_decoder: ^2.0.1         # Décodage JWT
  cached_network_image: ^3.3.0 # Cache d'images
```

### Outils de développement
- **IDE** : Visual Studio Code, Android Studio
- **Contrôle de version** : Git
- **Tests API** : Postman
- **Debugging** : Flutter DevTools

## Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- Flutter SDK (version 3.0.0 ou supérieure)
- Dart SDK (version 2.17.0 ou supérieure)
- Android Studio ou VS Code avec extensions Flutter
- Un émulateur Android/iOS ou un appareil physique
- Git pour le contrôle de version

## Installation

1. **Cloner le repository**
   ```bash
   git clone https://github.com/aymane-06/Flutter_TransportSTE_App.git
   cd Flutter_TransportSTE_App
   ```

2. **Installer les dépendances Flutter**
   ```bash
   flutter pub get
   ```

3. **Vérifier l'installation**
   ```bash
   flutter doctor
   ```


## Utilisation

### Lancement de l'application

```bash
# En mode debug
flutter run

# En mode release
flutter run --release

# Pour une plateforme spécifique
flutter run -d android
flutter run -d ios
```

### Connexion

1. Lancez l'application
2. Saisissez vos identifiants Odoo
3. Sélectionnez votre rôle (chauffeur ou gestionnaire)
4. Accédez au dashboard correspondant

## Architecture

L'application suit une architecture MVVM (Model-View-ViewModel) avec BLoC pour la gestion d'état :

```
lib/
├── core/
│   ├── constants/          # Constantes de l'application
│   ├── errors/            # Gestion d'erreurs
│   ├── utils/             # Utilitaires
│   └── widgets/           # Widgets réutilisables
├── features/
│   ├── auth/              # Authentification
│   │   ├── data/          # Modèles et repositories
│   │   ├── presentation/  # UI et BLoCs
│   │   └── domain/        # Entités et use cases
│   ├── voyages/           # Gestion des voyages
│   ├── frais/             # Gestion des frais
│   └── dashboard/         # Tableaux de bord
└── main.dart
```


## Déploiement

### Android

```bash
# Génération APK
flutter build apk --release

# Génération App Bundle (recommandé pour Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Génération IPA
flutter build ipa --release
```

## Auteurs

- **Aymane Himame** - Développeur Full stack - [@aymane-06](https://github.com/aymane-06)
- **LeanSoft** - Encadrement technique et support

---

Pour toute question ou support technique, n'hésitez pas à ouvrir une issue ou à contacter l'équipe de développement.
