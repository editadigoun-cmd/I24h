# Configuration du backend mobile I24H

Le dépôt prépare l'application Flutter et le schéma de départ, mais aucun projet Supabase ni aucun fournisseur de paiement n'est encore configuré. Les identifiants de production ne doivent jamais être inventés ou committés.

## 1. Créer le projet Supabase

1. Ouvrir https://supabase.com/dashboard et se connecter.
2. Créer un nouveau projet nommé par exemple `i24h-production` dans une région adaptée aux utilisateurs.
3. Conserver le mot de passe de base de données dans un gestionnaire sûr. Il n'est pas nécessaire dans l'application mobile.
4. Dans le projet, ouvrir **SQL Editor**.
5. Copier le contenu de `supabase/migrations/202610190001_initial_mobile_backend.sql` et l'exécuter.
6. Dans **Project Settings / API** ou **Connect**, relever l'URL du projet et la clé **Publishable**. Ne jamais utiliser la clé `service_role` dans Flutter.

La migration crée les tables des profils, programmes, replays, intentions de prière et dons, active la sécurité RLS et crée le bucket privé `i24h-replays`. Les politiques actuelles permettent aux fidèles authentifiés de lire les programmes/replays publiés, de déposer et relire leurs propres intentions, et de lire leurs propres dons. La gestion des contenus par les administrateurs devra passer par un outil serveur sécurisé.

## 2. Lancer l'application avec le backend

À la racine du dépôt, après installation de Flutter :

```bash
flutter pub get
flutter run \
  --dart-define=I24H_SUPABASE_URL=https://VOTRE-PROJET.supabase.co \
  --dart-define=I24H_SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLISHABLE
```

Remplacer les deux valeurs par celles de votre projet Supabase. Ce sont des exemples de paramètres, pas des identifiants I24H existants. Pour un build, transmettre les mêmes `--dart-define` à la commande de compilation ou utiliser un fichier de paramètres non versionné.

L'inscription utilise l'e-mail et un mot de passe d'au moins 8 caractères. Selon le réglage Supabase, la confirmation par e-mail peut être requise. Configurez les URL de redirection autorisées si vous activez des liens de confirmation ou de réinitialisation.

## 3. Flux live

Le dépôt ne contient pas l'adresse du flux I24H. Il faut demander au responsable technique de la radio :
- l'URL HTTPS officielle du flux audio (MP3/AAC, ou la technologie effectivement utilisée) ;
- si nécessaire, les exigences d'accès, les règles CORS/HTTPS et les limites de connexions ;
- une URL de test stable autorisée à être utilisée dans l'application.

Puis lancer avec :

```bash
flutter run \
  --dart-define=I24H_SUPABASE_URL=https://VOTRE-PROJET.supabase.co \
  --dart-define=I24H_SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLISHABLE \
  --dart-define=I24H_LIVE_STREAM_URL=https://VOTRE-DOMAINE/flux-radio.mp3
```

Ne remplacez pas l'URL par une adresse supposée. Testez le flux sur les réseaux mobiles et Wi-Fi, et validez les droits de diffusion avec l'exploitant.

## 4. Replays et stockage

Les replays doivent être importés dans le bucket privé `i24h-replays`, avec leurs métadonnées dans `public.replay_items`. Le champ `media_path` doit contenir le chemin du fichier dans ce bucket, pas une URL temporaire. La future couche de données mobile devra charger uniquement les éléments publiés et demander une URL signée de courte durée pour la lecture.

Aucune émission fictive n'est insérée par la migration. Il faut fournir les fichiers audio/vidéo autorisés, leurs titres, dates, durées et informations de publication.

## 5. Dons : sécurité et fournisseur

Le choix du fournisseur de paiement reste à confirmer par le responsable I24H (par exemple KKiaPay, FedaPay ou CinetPay, selon le compte marchand et les moyens de paiement souhaités).

Le parcours de production doit être :
1. L'application demande au serveur de créer une transaction.
2. Le serveur appelle le fournisseur avec les secrets conservés côté serveur.
3. L'application ouvre le parcours de paiement officiel.
4. Le serveur vérifie la transaction ou un webhook signé.
5. Seul le serveur marque le don comme réussi dans `public.donations`.

Ne mettez jamais une clé secrète de paiement ou une clé Supabase `service_role` dans l'application mobile. La migration n'active volontairement aucune insertion de dons par le client.

## 6. Vérifications avant publication

```bash
dart format lib
flutter analyze
flutter test
flutter build apk --release
```

Il faudra aussi tester sur de vrais appareils Android et iPhone : inscription, confirmation d'e-mail, connexion, mot de passe oublié, session persistante, erreurs réseau, direct, replays, envoi d'intention, paiement confirmé et comportement en arrière-plan.

## Éléments qui nécessitent encore le responsable I24H

- URL officielle du flux live et formats supportés.
- Fichiers de replay, métadonnées et autorisation de diffusion.
- Projet Supabase créé et ses valeurs publiques de connexion.
- Fournisseur de paiement choisi, compte marchand et URL de webhook.
- Adresse de support, politique de confidentialité et coordonnées officielles à publier.
- Comptes développeur Apple et Google pour la publication.

Cette configuration constitue le socle sécurisé, pas une certification de production. Les écrans programme, replay, intentions et dons doivent encore être reliés aux tables et aux services avant de considérer le produit terminé.
