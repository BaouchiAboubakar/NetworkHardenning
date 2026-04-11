# SSH hardening (siteB-srv)

Changements appliqués à `/etc/ssh/sshd_config` sur `siteB-srv` pour en faire un bastion admin.

- Création d’un compte admin dédié : `adminX` (home séparé, login par clé).
- Authentification par mot de passe désactivée :
  - `PasswordAuthentication no`
  - `PubkeyAuthentication yes`
- Connexion directe de root interdite :
  - `PermitRootLogin no`
- Accès SSH limité à l’admin :
  - `AllowUsers adminX`
- Fenêtre d’authentification réduite :
  - `MaxAuthTries 3`
  - `LoginGraceTime 30`


