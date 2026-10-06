I24H — AUDIT DU CAHIER DES CHARGES

VERDICT
Le dépôt est une base Flutter native exploitable, mais le cahier des charges n'est pas encore respecté intégralement.

PRESENT
- Flutter pour l'application mobile.
- Onboarding et connexion.
- Espace utilisateur avec accueil, programme, replay, intentions et profil.
- Ecrans dédiés administrateur et animateur.
- Planning administrateur avec ajout/suppression locale.
- Contrôle local du micro et démarrage/arrêt d'un faux direct.
- Workflow GitHub Actions Android.

ECARTS BLOQUANTS
- Backend Laravel absent.
- Base MySQL absente.
- API réelle absente.
- Streaming MediaMTX/FFmpeg absent.
- Enregistrement automatique et stockage Cloudflare R2 absents.
- Firebase Cloud Messaging absent.
- Fedapay, Stripe et PayPal absents.
- Chat live réel absent.
- Lecteur vidéo/audio réel absent.
- Compteur de fidèles connecté réel absent.
- Intentions et dons non persistés.
- Authentification réelle et 2FA absentes.
- RBAC réel absent.
- Gestion réelle des utilisateurs/animateurs absente.
- Contrôle distant des participants invités absent.
- Modération, logs, rate limiting, sauvegardes et protections serveur absents.
- Publication iOS non configurée.
- Données de démonstration encore locales.

CORRECTIONS APPLIQUEES
1. Les routes Flutter exposent désormais les espaces utilisateur, administrateur et animateur.
2. Le workflow CI prépare Android et Web.
3. Le workflow analyse et teste le code avant génération.
4. Le workflow Android utilise un build-number croissant basé sur le numéro du workflow. Cela permet une mise à jour par-dessus une installation existante si l'applicationId et la signature restent identiques.
5. Le workflow produit également une build Web pour préparer les interfaces web.

ETAPE SUIVANTE OBLIGATOIRE
La conformité complète exige encore Laravel/MySQL, MediaMTX/FFmpeg, Cloudflare R2, FCM, Fedapay, Stripe et PayPal, ainsi que le remplacement des données locales par une API sécurisée.