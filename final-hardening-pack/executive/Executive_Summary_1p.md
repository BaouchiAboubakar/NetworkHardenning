# Executive Summary — Network Hardening Project

## Top 3 risks (business view)

1. **Interruption de service en cas de compromission d’un composant exposé (DMZ / edge)**  
   Un défaut de durcissement ou une erreur de configuration sur les services exposés (firewall, reverse proxy, serveur web) pourrait permettre à un attaquant d’interrompre le service ou de le dégrader, entraînant une indisponibilité métier visible et potentiellement une perte de chiffre d’affaires.

2. **Accès non autorisé aux systèmes internes via des identifiants volés ou mal protégés**  
   Si un compte d’administration ou une clé SSH est compromise, un attaquant pourrait obtenir un accès privilégié aux serveurs internes, contourner les contrôles de surface et provoquer des fuites de données, de la fraude ou des manipulations de configuration à fort impact.

3. **Détection tardive d’une intrusion faute de visibilité et de monitoring suffisants**  
   En l’absence de journaux correctement collectés, corrélés et revus, un incident (scan, exploitation, mouvement latéral) peut passer inaperçu pendant une longue période, laissant l’attaquant libre de persister, d’exfiltrer des données et de préparer d’autres attaques.

## 5 principaux contrôles mis en place

1. **Filtrage réseau durci entre Internet, DMZ et LAN**, avec une politique de type “deny by default” et une ouverture minimale des ports nécessaires aux services métiers. 
2. **Durcissement TLS sur le service web exposé**, avec versions obsolètes désactivées, suites cryptographiques faibles retirées et en-têtes de sécurité HTTP (HSTS, etc.) activés.
3. **Accès SSH d’administration restreint et basé sur des clés**, avec désactivation du login root par mot de passe et restriction des flux d’admin à travers un VPN/site‑to‑site IPsec.
4. **Déploiement d’un IDS sur les points de passage critiques**, avec des règles personnalisées pour détecter des flux applicatifs sensibles (comme l’accès à `/admin`) et journalisation centralisée des alertes. 
5. **Suite de tests de régression automatisée**, permettant de rejouer rapidement des scénarios clés (firewall, TLS, SSH, IDS) après chaque changement d’architecture ou de configuration.

## Residual risk (non résolu à ce stade)

Malgré ces contrôles, plusieurs risques résiduels demeurent : la couverture de détection reste limitée à un périmètre restreint et ne couvre pas encore l’ensemble des applications et environnements (pré‑prod, postes utilisateurs). La gestion des identités et des privilèges (IAM, MFA généralisée, revues régulières des droits) n’est pas complètement traitée dans ce projet et repose encore en grande partie sur des procédures manuelles. Enfin, la résilience globale (PRA, tests de restauration, scénarios de crise) n’a été abordée qu’au travers de mécanismes techniques de base (sauvegardes, durcissement) et nécessitera un travail complémentaire au niveau organisationnel.

## Next actions (30 / 60 / 90 jours)

- **D’ici 30 jours — Quick wins opérationnels**  
  Renforcer la supervision (tableaux de bord sur les logs firewall/IDS/TLS), mettre à jour systématiquement les correctifs de sécurité sur les composants exposés, vérifier et documenter les sauvegardes critiques, et mettre en place une rotation régulière des clés SSH et certificats utilisés en production.

- **D’ici 60 jours — Améliorations d’architecture**  
  Affiner la segmentation réseau (zones supplémentaires pour limiter les mouvements latéraux), lancer des pilotes de principes Zero Trust sur des cas d’usage ciblés (par exemple, accès admin), et ajuster les politiques de WAF/edge pour mieux filtrer les requêtes applicatives et limiter la surface d’attaque.

- **D’ici 90 jours — Gouvernance et automatisation**  
  Formaliser l’infrastructure sous forme de code (IaC) pour les principaux contrôles (firewall, TLS, IDS, VPN), intégrer des contrôles de sécurité dans la CI (linting de configuration, tests de régression automatiques), et définir une cadence de revue de politique (trimestrielle) incluant l’analyse des incidents, des écarts et des besoins métiers.
