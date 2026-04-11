## Threat model — Remote administrative access

Asset: l’actif principal est l’accès **administratif** aux serveurs des deux sites, utilisé pour opérer et maintenir l’infrastructure de production.
Adversary: nous considérons à la fois un attaquant externe sur Internet cherchant à forcer l’accès distant, et un poste interne compromis qui essaie d’abuser de ses droits ou de son accès au VPN.
Key threats: attaques de password guessing / credential stuffing sur SSH, vol de clés privées ou mauvaise hygiène de gestion des clés, attaques de type Man‑in‑the‑Middle sur le segment WAN en l’absence de VPN solide, et mouvement latéral une fois le VPN établi si le tunnel donne accès à trop de sous‑réseaux. 
Security goals: seuls des admins explicitement autorisés doivent pouvoir ouvrir une session SSH (utilisateurs scoping + authentification par clé uniquement), tout le trafic d’administration entre sites doit rester confidentiel et protégé en intégrité en transit via IPsec, les tunnels VPN doivent être limités aux sous‑réseaux nécessaires (et non un accès 0.0.0.0/0 généralisé), et l’ensemble des actions d’administration doit être journalisé de façon traçable pour permettre audit et investigation a posteriori.




Explication PSK
### Méthode d’authentification (lab vs production)

Pour le tunnel IPsec de ce lab, nous utilisons une clé pré‑partagée (PSK) pour l’authentification IKE. Il s’agit d’une **simplification volontaire spécifique à l’environnement de TD5** : la PSK est simple à configurer, facile à réinitialiser entre deux snapshots, et suffisante pour illustrer la différence entre « tunnel up » et « tunnel down » dans un lab contrôlé.

En environnement de production, nous **ne conserverions pas** une PSK pour des VPN site‑à‑site. À la place, nous utiliserions des **certificats X.509** émis par une PKI interne (ou une AC de confiance), avec :

- des certificats uniques par passerelle (forte identité, aucun secret partagé entre sites),
- une gestion d’expiration et de révocation (CRL/OCSP) pour traiter les compromissions de clés,
- des procédures de gestion de clés documentées (génération, stockage, rotation).

Le lab montre donc la mécanique d’IKEv2 et l’établissement du tunnel avec PSK, mais la **cible de conception visée** pour un déploiement réel est une authentification « basée sur certificats uniquement ».




Task C5


Dans ce lab, le tunnel IPsec est volontairement restreint au trafic entre le LAN du site A et la DMZ du site B, et ne transporte pas tout le trafic Internet.
Côté siteA-gw (/etc/ipsec.conf)
text
conn site-to-site
    authby=secret
    left=10.10.99.1
    leftsubnet=10.10.10.0/24
    right=10.10.99.2
    rightsubnet=10.10.20.0/24
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256-modp2048!
    keyexchange=ikev2
    auto=start

leftsubnet=10.10.10.0/24 : seul le réseau LAN du site A est considéré comme « local » pour le tunnel.


rightsubnet=10.10.20.0/24 : seul le réseau DMZ du site B est considéré comme « distant ».


Aucun 0.0.0.0/0 n’est utilisé : le tunnel ne sert pas de sortie par défaut vers tout Internet.​​


Côté siteB-gw (/etc/ipsec.conf)
text
conn site-to-site
    authby=secret
    left=10.10.99.2
    leftsubnet=10.10.20.0/24
    right=10.10.99.1
    rightsubnet=10.10.10.0/24
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256-modp2048!
    keyexchange=ikev2
    auto=start

Ici, on inverse les rôles : la DMZ (10.10.20.0/24) est le sous‑réseau local, et le LAN (10.10.10.0/24) est le sous‑réseau distant.​​


Grâce à ces paires leftsubnet / rightsubnet, la politique IPsec impose que seul le trafic entre 10.10.10.0/24 et 10.10.20.0/24 est chiffré et passe dans le tunnel.
 Tout autre trafic (par exemple vers Internet) suit les routes normales et n’est pas capturé par ce tunnel IPsec.

