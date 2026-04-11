
## Zones
Le LAN contient le client utilisé pour les tests et le pilotage.
La DMZ expose les services (HTTP/SSH) et le capteur IDS.
gw-fw est la frontière de confiance entre LAN et DMZ et applique la politique réseau.


## Allow-list
Seuls les flux suivants sont autorisés entre LAN et DMZ :
ALLOW LAN → DMZ, client → srv-web, TCP/80 (HTTP)
Purpose : tests applicatifs web pendant le lab.
Owner : app owner / TD1 baseline.
ALLOW LAN → DMZ, client → srv-web, TCP/22 (SSH)
Purpose : administration distante de srv-web pendant le lab.
Owner : instructor / admin.
Note : à restreindre plus tard (filtrage IP, clés).
ALLOW LAN → DMZ, client → srv-web, TCP/443 (HTTPS)
Purpose : futur accès chiffré (objectif TD4).
Owner : app owner.
Status : REVIEW tant que HTTPS n’est pas encore configuré.
ALLOW LAN → DMZ, client → srv-web, ICMP echo-request/echo-reply
Purpose : diagnostic de connectivité (ping), taux limité.
Owner : équipe réseau.
ALLOW established/related return traffic (stateful)
Purpose : permettre les réponses aux connexions initiées depuis LAN vers DMZ, sans ouvrir de nouveaux flux.
Owner : sécurité / réseau.
(Optionnel, si tu l’utilises) ALLOW LAN → DMZ, client ↔ sensor-ids, TCP/22 (SSH)
Purpose : récupération de captures et administration du capteur IDS.
Owner : sécurité / monitoring.
Status : REVIEW (port d’admin supplémentaire en DMZ).
Tout autre flux non listé doit être refusé (default deny).


## Default stance
La posture par défaut du pare‑feu est la suivante :

- **FORWARD : DROP** — tout trafic entre les zones (LAN ↔ DMZ) est refusé par défaut ; seuls les flux explicitement autorisés dans la allow‑list passent. 
- **INPUT sur gw-fw : DROP** — le firewall lui‑même est protégé ; aucune connexion entrante vers `gw-fw` n’est autorisée à part quelques accès d’administration explicitement définis.
- **OUTPUT depuis gw-fw : ACCEPT** — le firewall peut initier des connexions vers les deux sous‑réseaux (par exemple pour les mises à jour ou les tests), ce qui simplifie l’administration sans exposer directement les services internes.

Cette posture “deny by default” garantit que toute règle non justifiée par le contrat de flux (TD1) est bloquée, et oblige à documenter chaque ouverture comme une exception contrôlée plutôt qu’un comportement implicite.


## Logging strategy
Journaliser le trafic FORWARD refusé (default deny) avec un préfixe clair, ex. NFT_FWD_DENY ou IPT_FWD_DENY, avec un rate limit pour éviter le bruit.
Journaliser les flux sensibles autorisés, en particulier SSH admin (LAN → gw-fw, LAN → srv-web, LAN → sensor-ids si activé).
Utiliser journalctl / /var/log/syslog pour extraire les événements et les copier dans evidence/deny_logs.txt.


## Exception process
Toute nouvelle demande de flux (nouveau port, nouvelle origine/destination) doit :
Être ajoutée à la flow matrix TD1 avec un ID, un purpose, un owner et un status (ALLOW/REVIEW).
Être documentée dans config/policy.md avant modification du firewall.
Les exceptions temporaires (ex. port ouvert pour un TD spécifique) doivent avoir :
Une date de revue ou une condition de fermeture (fin du TD).
Un responsable clairement identifié (owner).
Les règles qui ne sont plus justifiées doivent être retirées de la policy et du ruleset au plus tard au TD suivant
