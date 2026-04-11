## Modèle de menace (TD5)

Actif principal : l’accès administratif aux serveurs des deux sites (bastion SSH, passerelles, services en DMZ).  
Adversaire : attaquant externe sur Internet / WAN ou poste interne compromis qui tente d’abuser de l’accès distant.  
Menaces clés : attaques par dictionnaire / credential stuffing sur SSH, vol ou mauvaise gestion de clés privées, interception MITM sur le segment WAN en l’absence de chiffrement, et mouvements latéraux excessifs après établissement du VPN si le tunnel n’est pas correctement borné.  
Objectifs de sécurité : seuls des admins explicitement autorisés doivent pouvoir ouvrir une session SSH (comptes dédiés + authentification par clé uniquement), tout trafic d’administration entre sites doit être chiffré et intégrité‑protégé via IPsec, le tunnel doit être limité aux sous‑réseaux prévus (LAN ↔ DMZ, pas 0.0.0.0/0), et chaque tentative ou succès d’accès doit rester traçable dans des journaux exploitables pour l’audit et l’investigation.




## Observations packet capture


Observation ID: O1
Time range: ≈ 19:14:54
Flow reference (row ID): F04 (client → srv-web TCP/80)
What I saw (facts): Dans baseline.pcap, on observe un échange TCP entre 10.10.10.10 et 10.10.20.10:80 incluant la séquence SYN/SYN-ACK/ACK, puis une requête HTTP: GET / HTTP/1.1 et les acquittements correspondants.
Why it matters: Cela confirme que le flux HTTP depuis le LAN vers le serveur web en DMZ est fonctionnel, mais le trafic applicatif circule en clair, exposant les requêtes et réponses à tout observateur sur le segment DMZ.
Proposed control: Mettre en place HTTPS (TLS) sur srv-web, rediriger HTTP vers HTTPS et, à terme, limiter ou bloquer le trafic HTTP pur.
Evidence pointer: baseline.pcap, lignes tcpdump -r baseline.pcap -nn 'tcp port 80' montrant HTTP: GET / HTTP/1.1 entre 10.10.10.10.58682 et 10.10.20.10.80.

Observation ID: O2
Time range: ≈ 19:14:38
Flow reference (row ID): (nouvelle ligne à ajouter, ex. F01b : client ↔ sensor-ids TCP/22)
What I saw (facts): La capture montre plusieurs paquets TCP avec 10.10.20.50.22 > 10.10.10.10.56252 et les ACK correspondants, indiquant une session SSH active entre sensor-ids (10.10.20.50, port 22) et client (10.10.10.10).
Why it matters: Ce flux permet d’administrer ou de transférer des fichiers depuis le capteur IDS, ce qui est utile pour l’analyse, mais expose aussi un service SSH supplémentaire en DMZ, pouvant être ciblé si l’authentification ou le filtrage ne sont pas renforcés.
Proposed control: Documenter explicitement ce flux dans la matrice, restreindre SSH à des IP sources précises (client seulement), imposer des clés SSH plutôt que des mots de passe, et journaliser toutes les connexions SSH sur sensor-ids.
Evidence pointer: baseline.pcap, sortie tcpdump -r baseline.pcap -nn 'tcp port 22' | head montrant 10.10.20.50.22 ↔ 10.10.10.10.56252.

Observation ID: O3
Time range: ≈ 19:15:23–19:15:25
Flow reference (row ID): F06 (client → srv-web ICMP)
What I saw (facts): baseline.pcap contient des paquets ICMP echo request de 10.10.10.10 vers 10.10.20.10 suivis de ICMP echo reply en sens inverse, avec le même identifiant et les numéros de séquence (seq 1, 2, 3).
Why it matters: Ceci prouve la reachability IP bout‑en‑bout entre le client et srv-web et sert de test de diagnostic simple; toutefois, un ICMP entièrement ouvert peut aider un attaquant à cartographier le réseau ou à mettre en place des tunnels ICMP.
Proposed control: Autoriser ICMP de manière limitée (par exemple uniquement depuis le client de test, activer du rate‑limiting côté firewall sur gw-fw, et éventuellement filtrer certains types ICMP non nécessaires).
Evidence pointer: baseline.pcap, sortie tcpdump -r baseline.pcap -nn 'icmp' | head montrant les echo request et echo reply entre 10.10.10.10 et 10.10.20.10.

Observation ID: O4
Time range: fenêtre de capture TD1 (≈ 19:14–19:15)
Flow reference (row ID): (nouvelle ligne possible F07 : client → gw-fw UDP/53)
What I saw (facts): La commande dig @10.10.20.1 example.com 2>&1 || true exécutée depuis client échoue (absence de réponse DNS valide), indiquant qu’aucun service DNS fonctionnel n’est disponible à cette adresse/port dans l’état actuel du lab.
Why it matters: Sans DNS interne fonctionnel, certaines applications peuvent échouer silencieusement ou se dégrader; à l’inverse, exposer un DNS mal configuré dans la DMZ peut devenir un vecteur d’attaque. Ce flux doit être soit correctement implémenté, soit explicitement considéré comme absent.
Proposed control: Décider clairement de la stratégie DNS : mettre en place un serveur DNS interne sécurisé et l’ajouter à la matrice de flux, ou documenter que la résolution se fait uniquement via IP et que le flux DNS interne est refusé par défaut.
Evidence pointer: Sortie de dig @10.10.20.1 example.com archivée dans tests/commands.txt ou report.md comme preuve d’échec.

Observation ID: O5
Time range: ≈ 19:00 (scan Nmap)
Flow reference (row ID): F01 (SSH 22), F04 (HTTP 80), F05 (HTTPS 443, REVIEW), F10 (default deny)
What I saw (facts): Le scan nmap -sS -sV -p 1-1000 10.10.20.10 montre uniquement deux ports ouverts : 22/tcp (OpenSSH 9.6p1) et 80/tcp (nginx 1.24.0). Tous les autres ports 1–1000 sont fermés (reset), et aucun service HTTPS (443/tcp) n’est exposé.
Why it matters: La surface d’attaque réseau de srv-web est réduite (seuls SSH et HTTP sont exposés), ce qui est positif; en revanche, SSH reste ouvert en DMZ et le service applicatif ne bénéficie pas encore de chiffrement TLS, ce qui va à l’encontre de l’objectif de F05.
Proposed control: Restreindre l’accès SSH (F01) aux seules IP d’admin nécessaires, implémenter HTTPS sur srv-web puis ajuster la politique firewall TD2 pour autoriser exclusivement 80/443 (avec préférence pour 443) et bloquer les autres ports conformément à F10.
Evidence pointer: evidence/nmap_srvweb.txt (ou sortie correspondante) montrant 22/tcp et 80/tcp ouverts, le reste fermé.




## Risks (top examples)
R1 – Trafic HTTP en clair vers srv-web (port 80)
Impact : Moyen à élevé (exposition du contenu applicatif, URLs, cookies non sécurisés).
Evidence : Observation O1, capture HTTP GET / en clair sur 10.10.20.10:80, Nmap montre 80/tcp ouvert.
Commentaire : Le flux F04 est nécessaire pour les tests, mais sans TLS il permet une interception ou manipulation de trafic dans la DMZ.
R2 – SSH ouvert en DMZ (port 22 sur srv-web)
Impact : Élevé (accès direct à un serveur applicatif en DMZ).
Evidence : Nmap détecte 22/tcp open (OpenSSH 9.6p1), Observation O5.
Commentaire : F01 autorise ce flux, mais sans restriction d’IP ni renforcement d’authentification, c’est une cible prioritaire pour brute‑force ou exploitation de vulnérabilités SSH.
R3 – SSH supplémentaire sur sensor-ids
Impact : Élevé (second point d’entrée en DMZ).
Evidence : Observation O2, trafic SSH entre 10.10.10.10 et 10.10.20.50:22 dans baseline.pcap.
Commentaire : La multiplication de services SSH augmente la surface d’attaque; ce flux n’est pas forcément documenté dans la matrice initiale.
R4 – ICMP largement autorisé entre LAN et DMZ
Impact : Faible à moyen (reconnaissance, mesure de latence, usage potentiel pour des tunnels).
Evidence : Observation O3, séquences d’ICMP echo request/reply entre 10.10.10.10 et 10.10.20.10.
Commentaire : Utile pour le diagnostic (F06), mais sans limite ni filtrage il facilite la cartographie du réseau.
R5 – DNS interne non défini / non fonctionnel
Impact : Moyen (problèmes de résolution, comportements inattendus d’applicatifs).
Evidence : Observation O4, dig @10.10.20.1 example.com échoue.
Commentaire : L’absence de stratégie claire (DNS interne ou pas) complique le durcissement : soit il faut un DNS correctement sécurisé, soit assumer une politique “IP only”.
R6 – Politique par défaut implicite plutôt qu’explicite
Impact : Moyen (risque de laisser passer des flux non prévus lorsque le firewall sera mis en place).
Evidence : Flow F10 = “any → any (default DENY)” existe conceptuellement, mais n’est pas encore appliqué au niveau firewall.
Commentaire : Tant que la politique default deny n’est pas effectivement implémentée sur gw-fw, des services futurs pourraient être exposés par erreur.

Quick wins
QW1 – Mettre en place HTTPS sur srv-web et réduire HTTP
Lien risques : R1, R6.
Action : Installer un certificat (self‑signed pour le lab), activer TLS sur nginx, rediriger HTTP vers HTTPS et documenter F05 comme ALLOW (et F04 comme transitoire).
Bénéfice : Chiffre le trafic applicatif, réduit la fuite d’information.
QW2 – Restreindre SSH (22/tcp) par IP source et par clés
Lien risques : R2, R3.
Action : Limiter l’accès SSH à client uniquement (règles firewall sur gw-fw), désactiver l’authentification par mot de passe, utiliser des clés, et documenter précisément les flux SSH (srv-web et sensor-ids) dans la matrice.
Bénéfice : Réduction du risque de brute‑force et de compromission par SSH.
QW3 – Encadrer ICMP entre LAN et DMZ
Lien risques : R4.
Action : Autoriser ICMP seulement depuis client vers les hôtes de la DMZ, avec du rate‑limiting (TD2 sur gw-fw), et bloquer l’ICMP non nécessaire.
Bénéfice : Maintient les capacités de diagnostic tout en réduisant les opportunités de reconnaissance.
QW4 – Clarifier et documenter la politique DNS
Lien risques : R5.
Action : Décider si gw-fw ou srv-web doit jouer un rôle DNS (et le configurer correctement), ou au contraire interdire explicitement le DNS interne et travailler uniquement en IP; dans les deux cas, ajouter/mettre à jour les lignes correspondantes dans la flow matrix.
Bénéfice : Évite les comportements “magiques” liés à la résolution des noms et prépare les règles firewall/IDS.
QW5 – Implémenter la règle “default deny” sur gw-fw
Lien risques : R6.
Action : Lors de TD2, configurer gw-fw pour appliquer une politique “deny all” en fin de chaîne, puis n’ouvrir que les flux explicitement listés dans la flow matrix (22, 80, futur 443, ICMP limité, etc.).
Bénéfice : Assure l’alignement strict entre la matrice et le comportement réel du réseau, limite l’exposition si de nouveaux services sont installés.
