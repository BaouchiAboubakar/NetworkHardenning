# TD4 — TLS Change Log

Ce fichier décrit, ligne par ligne, les modifications apportées à la configuration TLS de `srv-web`,
avec la raison de chaque changement et le lien avec les objectifs du TD4.



## C1 — Désactivation de TLS 1.0 et 1.1

- Fichier :
  - Avant : `/etc/nginx/conf.d/default.conf`
- Ligne modifiée :
  - Avant  : `ssl_protocols TLSv1 TLSv1.1 TLSv1.2;`
  - Après  : `ssl_protocols TLSv1.2;`  (ou `ssl_protocols TLSv1.2 TLSv1.3;` si supporté)
- Raison :
  - TLS 1.0 et TLS 1.1 sont considérés comme obsolètes et vulnérables.
  - Conformité avec les recommandations de durcissement (NIST / bonnes pratiques actuelles).
- Effet attendu :
  - Un client qui tente de négocier TLS 1.0 ou 1.1 obtient un échec de handshake.
  - La surface d’attaque liée aux anciens protocoles est réduite.


## C2 — Restriction des suites de chiffrement à AEAD + PFS

- Fichier :
  - `/etc/nginx/conf.d/default.conf`
- Ligne modifiée :
  - Avant  : `ssl_ciphers 'HIGH:MEDIUM:!aNULL:!MD5';`
  - Après  : `ssl_ciphers 'ECDHE+AESGCM:ECDHE+CHACHA20:!aNULL:!MD5:!RC4';`
- Raison :
  - Les profils `MEDIUM` incluent encore des suites CBC plus faibles.
  - Les suites AEAD (AES-GCM, CHACHA20) avec ECDHE fournissent confidentialité, intégrité
    et Perfect Forward Secrecy.
- Effet attendu :
  - Les scanners TLS ne voient plus de suites CBC ni de suites sans PFS dans la liste proposée.
  - Le chiffrement négocié est systématiquement AEAD + ECDHE.


## C3 — Maintien de `ssl_prefer_server_ciphers on`

- Fichier :
  - `/etc/nginx/conf.d/default.conf`
- Ligne :
  - Avant  : `ssl_prefer_server_ciphers on;`
  - Après  : `ssl_prefer_server_ciphers on;` (inchangé, mais documenté)
- Raison :
  - Forcer le serveur à choisir la suite de chiffrement la plus forte qu’il supporte,
    au lieu de laisser le client imposer une option plus faible.
- Effet attendu :
  - Les clients compatibles négocient systématiquement les suites les plus robustes.



## C4 — Activation de HSTS

- Fichier :
  - `/etc/nginx/conf.d/default.conf`
- Ligne ajoutée dans le bloc `server` HTTPS (8443) :
  - `add_header Strict-Transport-Security "max-age=300" always;`
- Raison :
  - Indiquer aux navigateurs de ne plus utiliser HTTP clair vers ce service pendant 300 s
    et de forcer systématiquement HTTPS.
  - Valeur courte pour le labo afin d’éviter les effets durables en cas d’erreur.
- Effet attendu :
  - Les réponses HTTPS contiennent l’en-tête HSTS.
  - Les navigateurs respectant HSTS refuseront de repasser en HTTP pendant la durée configurée.



## C5 — Définition d’un profil TLS documenté

- Fichiers :
  - `report.md` (ou `config/TLS_Profile.md`)
- Contenu ajouté :
  - Profil cible décrivant :
    - Version minimale TLS 1.2 (et TLS 1.3 si disponible).
    - Suites de chiffrement limitées à AEAD avec PFS.
    - PFS requis pour toutes les suites.
    - Certificat auto-signé accepté uniquement dans le contexte du lab.
    - HSTS activé avec `max-age=300`.
    - Clé serveur RSA 2048 bits minimum.
- Raison :
  - Rendre la politique TLS explicite et vérifiable, pas juste « on a bricolé la conf ».
- Effet attendu :
  - Chaque changement dans nginx peut être justifié par rapport à ce profil cible.



## C6 — Nettoyage de la configuration par défaut nginx

- Fichiers :
  - `/etc/nginx/sites-enabled/default` (désactivé / supprimé)
- Modification :
  - Suppression / renommage de la config par défaut qui écoutait sur `listen 80 default_server;`.
- Raison :
  - Éviter les conflits de vhosts (`duplicate default server`) et garder un chemin de trafic clair
    pour le service TLS du lab.
- Effet attendu :
  - `nginx -t` passe sans erreur.
  - Seule la configuration spécifique au lab est utilisée pour le port 80/8443.

