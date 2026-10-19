# Configuration audio mobile I24H

Cette version utilise `just_audio` pour lire une URL audio réelle. Le dépôt ne contient actuellement ni URL de flux radio confirmée ni catalogue Replay connecté à une API ; les sources doivent donc être fournies par l’équipe qui exploite la radio.

## 1. Configurer le direct

Lancer l’application avec l’URL réelle du flux (MP3/AAC ou autre format pris en charge par l’hébergement) :

```bash
flutter pub get
flutter run --dart-define=I24H_LIVE_STREAM_URL=https://VOTRE-DOMAINE/flux-radio.mp3
```

Ne remplacez pas cette valeur par une URL d’exemple en production. Vérifiez que le flux est accessible depuis un téléphone et qu’il utilise HTTPS.

## 2. Configurer les replays

Fournir un tableau JSON avec un titre, un sous-titre et l’URL audio de chaque émission. Exemple de structure :

```json
[
  {
    "title": "Nom de l’émission",
    "subtitle": "Date · durée",
    "url": "https://VOTRE-DOMAINE/replays/emission.mp3"
  }
]
```

Le JSON peut être injecté pour une validation technique :

```bash
flutter run \
  --dart-define=I24H_LIVE_STREAM_URL=https://VOTRE-DOMAINE/flux-radio.mp3 \
  --dart-define='I24H_REPLAY_CATALOG_JSON=[{"title":"Nom de l’émission","subtitle":"Date · durée","url":"https://VOTRE-DOMAINE/replays/emission.mp3"}]'
```

Les valeurs `dart-define` sont intégrées à l’application : elles ne doivent contenir aucun mot de passe, jeton privé ou clé secrète. Pour la production, privilégier une API sécurisée qui renvoie le catalogue Replay, plutôt que de reconstruire l’application à chaque ajout d’émission.

## 3. Vérifications avant publication

Depuis le dossier du projet :

```bash
flutter pub get
dart format lib
flutter analyze
flutter test
```

Tester ensuite sur Android et iOS : démarrage/arrêt du direct, réseau lent ou absent, URL invalide, lecture Replay, interruptions par appel et comportement quand l’application passe en arrière-plan.

## Limites restantes

- Le direct nécessite encore l’URL réelle du flux.
- Le catalogue Replay est configurable pour la validation, mais aucune API de gestion des émissions n’est encore présente dans le dépôt.
- La lecture en arrière-plan, les commandes sur écran verrouillé, les notifications média et l’intégration du flux de métadonnées radio ne sont pas encore implémentées.
