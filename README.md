# I24H — Application mobile native

I24H est désormais une application Flutter native, séparée en interfaces et composants Dart indépendants.

## Stack

- Flutter stable 3.47+
- Dart 3.13+
- Material 3 personnalisé
- `flutter_svg` pour les icônes SVG de la plateforme
- Assets I24H conservés dans `assets/`

## Organisation

```text
lib/
  main.dart
  app.dart
  core/
    theme/
    widgets/
  screens/
    auth/
    mobile/
    admin/
    animateur/
```

Chaque interface importante est isolée dans son propre fichier. Les composants partagés, le thème et les navigations sont séparés du contenu métier.

## Lancer l'application

Après avoir installé Flutter :

```bash
flutter pub get
flutter analyze
flutter run
```

Le projet est préparé pour Android et iOS. Les dossiers de plateforme (`android/` et `ios/`) sont générés par Flutter avec `flutter create .` dans l'environnement de développement, conformément à la structure standard Flutter.

## Interfaces incluses

### Mobile
- Onboarding
- Connexion / inscription
- Accueil
- Programme
- Replay
- Dons
- Profil

### Administration
- Vue d'ensemble
- Planning
- Animateurs
- Utilisateurs
- Émissions & replays
- Dons
- Notifications
- Paramètres

### Animateur
- Dashboard studio
- Direct / contrôle du studio
- Planning
- Replays
- Profil

## Direction artistique

Palette I24H : bleu nuit, bleu plateforme, accent doré, surfaces blanches et gris très légers. Les icônes de plateforme sont recolorées avec la palette I24H afin d'éviter les couleurs arbitraires.
