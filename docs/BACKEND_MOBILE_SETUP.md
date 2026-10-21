# Configuration du backend mobile I24H

Le projet Supabase I24H est actif. L'application Flutter reçoit l'URL et la clé publishable via des paramètres de compilation. La clé publishable est destinée au client mobile ; ne jamais intégrer une clé `service_role` ou un secret de paiement dans l'application.

## Projet Supabase actif

- URL : https://pwujpjjoxxqupckurrad.supabase.co
- Référence : pwujpjjoxxqupckurrad
- Région : Europe (Irlande)
- Bucket privé des rediffusions : `i24h-replays`

Le schéma comprend les profils, programmes, rediffusions, intentions de prière, dons, préférences de notifications, appareils et événements de paiement. Les règles RLS limitent l'accès aux données privées. La table `donation_payment_events` reste réservée au serveur.

Les programmes et les métadonnées des rediffusions publiés sont lisibles par les visiteurs non connectés, uniquement lorsque `is_published = true`. Cela permet de tester la connectivité Supabase avant la connexion. Les intentions, profils et données de dons restent protégés.

## Compiler l'application Android

```bash
flutter pub get
flutter build apk --release \
  --dart-define=I24H_SUPABASE_URL=https://pwujpjjoxxqupckurrad.supabase.co \
  --dart-define=I24H_SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLISHABLE
```

Le workflow GitHub Actions compile un APK Android et le publie comme artefact téléchargeable. Utiliser l'APK issu de la dernière exécution réussie après les changements d'interface.

## Diffusion vidéo en direct

I24H doit diffuser une **vidéo en direct**, avec une option pour basculer vers l'écoute seule afin d'économiser les données. Cette fonction nécessite un fournisseur de streaming vidéo et une URL de lecture confirmés. Masquer la vidéo sans couper le flux vidéo ne permettrait pas d'économiser les données. Le service de diffusion n'est pas encore configuré dans ce dépôt.

Le chat en direct, les réactions, le compteur de spectateurs et les notifications de démarrage doivent être raccordés à la couche temps réel et au service de streaming choisi avant d'annoncer le direct comme opérationnel.

## Comptes et e-mails

La création de compte dépend des paramètres Auth Supabase : confirmation par e-mail, URL de redirection et SMTP. La page d'authentification affiche désormais l'état de la connexion backend et permet de tester une vraie requête vers le Data API. Pour la production, configurer et tester la confirmation d'e-mail sur un appareil réel.

## Rediffusions

Importez les fichiers autorisés dans le bucket privé `i24h-replays`, puis ajoutez les métadonnées dans `public.replay_items`. `media_path` doit être le chemin du fichier dans le bucket, pas une URL signée temporaire.

## Dons

Le fournisseur de paiement et le compte marchand doivent être confirmés par l'équipe I24H. Le paiement réel nécessite une fonction serveur/Edge Function pour créer et vérifier les transactions/webhooks. Tant que ce flux n'est pas configuré, l'application ne doit pas annoncer un don comme payé.

## Avant publication

Tester sur des appareils réels : inscription, confirmation e-mail, connexion, session persistante, requêtes Supabase, diffusion vidéo, mode écoute seule, commentaires, réactions, replays, intentions, notifications et paiements confirmés. Les informations de support et la politique de confidentialité doivent également être fournies.
