# Configuration du backend mobile I24H

Le projet Supabase I24H est créé et son schéma initial est appliqué. L'application Flutter lit l'URL et la clé publishable Supabase via des paramètres de compilation. La clé publishable est destinée au client mobile ; ne jamais intégrer une clé service_role ou un secret de paiement dans l'application.

## Projet Supabase actif

- URL : https://pwujpjjoxxqupckurrad.supabase.co
- Référence : pwujpjjoxxqupckurrad
- Région : Europe (Irlande)
- Bucket privé des rediffusions : i24h-replays

Le schéma comprend les profils, programmes, rediffusions, intentions de prière, dons, préférences de notifications, appareils et événements de paiement. Les règles RLS limitent l'accès aux données privées. La table donation_payment_events reste réservée au serveur.

## Compiler l'application Android

    flutter pub get
    flutter build apk --release \
      --dart-define=I24H_SUPABASE_URL=https://pwujpjjoxxqupckurrad.supabase.co \
      --dart-define=I24H_SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLISHABLE

Le workflow GitHub Actions construit automatiquement un APK Android de production lors des exécutions de CI et le publie comme artefact téléchargeable nommé I24H-Android-APK pour 14 jours.

## Éléments nécessitant encore des informations officielles

### Direct audio
L'URL officielle du flux audio n'est pas présente dans le dépôt. Sans cette URL, l'application peut se connecter à Supabase, mais le lecteur live ne pourra pas diffuser le direct réel. Une fois l'URL fournie, reconstruire avec :

    flutter build apk --release \
      --dart-define=I24H_SUPABASE_URL=https://pwujpjjoxxqupckurrad.supabase.co \
      --dart-define=I24H_SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLISHABLE \
      --dart-define=I24H_LIVE_STREAM_URL=https://VOTRE-DOMAINE/flux-radio.mp3

Ne remplacez pas cette URL par une adresse supposée.

### Comptes et e-mails
La création de compte dépend des paramètres Auth Supabase (confirmation par e-mail, URL de redirection, SMTP). Configurez et testez ces paramètres dans le tableau de bord avant la mise en production.

### Rediffusions
Importez les fichiers autorisés dans le bucket privé i24h-replays, puis ajoutez les métadonnées dans public.replay_items. media_path doit être le chemin du fichier dans le bucket, pas une URL signée temporaire.

### Dons
Le fournisseur de paiement et le compte marchand doivent être confirmés par l'équipe I24H. Le paiement réel nécessite une fonction serveur/Edge Function pour créer et vérifier les transactions/webhooks. Tant que ce flux n'est pas configuré, l'application ne doit pas annoncer un don comme payé.

### Avant publication
Tester sur des appareils réels : inscription et connexion, confirmation e-mail, session, lecture du direct, replays, intentions, notifications et paiement confirmé. Les informations de support et la politique de confidentialité doivent également être fournies.
