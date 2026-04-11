ARTISI Paul: Leader et technicien
BEGU killian: chercheur et documentation
BAOUCHI Aboubakar: Technicien 


## Lab topology summary

- **kali-client** — 10.10.10.10 — zone LAN (poste utilisateur / test).  
- **gw-fw** — 10.10.10.1 (LAN) / 10.10.20.1 (DMZ) — passerelle + pare‑feu.  
- **srv-web** — 10.10.20.10 — zone DMZ (service HTTP/HTTPS).  
- **sensor-ids** — 10.10.20.50 — zone DMZ (capteur IDS).

La passerelle `gw-fw` route le trafic entre LAN et DMZ et applique la politique de filtrage définie dans le TD1.

## What we tested and how

- **Connectivité de base** : ping entre les VMs (LAN ↔ gw‑fw ↔ DMZ) pour vérifier le routage.  
- **Reachability contract** : tests `curl` et `nc` depuis `kali-client` vers `srv-web` afin de vérifier que seuls les ports prévus dans la matrice de flux (HTTP/HTTPS, éventuellement SSH) sont accessibles.  
- **Politique par défaut** : tentatives vers des ports non autorisés (ex. 12345, 3306) pour confirmer que le “deny by default” bloque bien le trafic.  
- **Administration** : accès SSH depuis le LAN vers `gw-fw` pour conserver un chemin d’admin même après durcissement.

Les commandes utilisées (ping, curl, nc, ssh…) sont listées dans `tests/commands.txt` avec leurs sorties stockées dans `evidence/`.

## Known limitations

- Pas de contrôle de trafic sortant (egress) fin pour l’instant : le focus du TD1 est sur les flux entrants LAN → DMZ.  
- Pas de règles spécifiques pour les flux DMZ → LAN (mouvements latéraux) au‑delà de quelques tests ponctuels.  
- Logging et supervision encore basiques : les journaux sont collectés localement sur `gw-fw`, sans agrégation ni corrélation centralisée.  
- La configuration actuelle n’intègre pas encore les aspects TLS, SSH hardening avancé ou VPN site‑à‑site, qui seront traités dans les TD suivants.