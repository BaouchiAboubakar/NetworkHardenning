
Asset. Le service web HTTP(S) exposé sur srv-web (API ou contenu) est la ressource principale à protéger.
Adversaire. Un attaquant sur le chemin (LAN/DMZ) ou un scanner distant capable d’initier des connexions TLS vers srv-web.
Menaces clés. Tentatives de négociation de versions TLS obsolètes (TLS 1.0/1.1), sélection de suites cryptographiques faibles sans perfect forward secrecy, acceptation d’une chaîne de certificats expirée ou auto‑signée que l’utilisateur contourne, et fuites d’informations via des en‑têtes ou pages d’erreur mal configurés.
Objectifs de sécurité. Limiter les versions supportées à des versions TLS modernes uniquement, imposer des suites avec forward secrecy, garantir une chaîne de certificats cohérente avec le modèle de confiance du lab, et utiliser le reverse‑proxy/edge pour fournir un minimum de disponibilité et de filtrage applicatif.




TLS PROFILE

Version minimale TLS 1.2, idéalement TLS 1.2 + 1.3.
Uniquement des suites AEAD avec PFS (ECDHE+AESGCM / CHACHA20), pas de CBC.
PFS obligatoire pour toutes les suites.
Certificat auto‑signé acceptable pour le lab (modèle de confiance documenté).
HSTS activé avec max-age=300 (valeur courte pour le lab).
Clé serveur RSA 2048 bits minimum (ou ECC équivalent), renouvelée régulièrement.




##  Log triage

### What happened?

En consultant le fichier `access.log` après les tests de rate limiting et de filtrage, on observe une rafale de requêtes HTTPs vers `/api` depuis la même adresse IP cliente, suivie de plusieurs réponses en erreur (4xx/5xx). Cette séquence correspond clairement à un test de charge ou à un script automatisé qui enchaîne des appels rapides sur l’API, ce qui déclenche les mécanismes de protection configurés (limitation de débit et blocage de certains User-Agent).

### What was the signal?

Le signal principal vient de la combinaison des champs de log suivants :  
- **Adresse IP source** : `10.10.10.10` (client du labo)  
- **Chemin d’accès** : `/api`  
- **Codes de statut** : d’abord `200`, puis `429` / `503` lors du dépassement de la limite, et `403` pour les requêtes avec User-Agent bloqué  
- **User-Agent** : par exemple `sqlmap/1.0` pour les requêtes explicitement filtrées  

Extrait de log (ligne réelle à citer) :


