## Partie A — Tableau des revendications de sécurité

| Claim ID | Revendication  | Emplacement du contrôle | Test (script) | Preuve (artifact) |
|----------|-------------------------|-------------------------|---------------|-------------------|
| C01 | Le pare-feu applique une politique par défaut « deny » : tout trafic non autorisé explicitement est bloqué entre LAN et DMZ. | controls/firewall/ (rules_gw-fw.md, config fw) | tests/regression/R1_firewall.sh | evidence/after/firewall_deny_logs.txt |
| C02 | Seuls les services autorisés (HTTPS, SSH, ICMP) atteignent le serveur DMZ depuis le LAN. | controls/firewall/ | tests/regression/R1_firewall.sh | evidence/after/firewall_counters.txt |
| C03 | Le service web en DMZ n’accepte que TLS 1.2 (et 1.3 si supporté) ; TLS 1.0/1.1 sont désactivés et les suites faibles sont supprimées. | controls/tls_edge/ (nginx.conf, TLS_Profile.md) | tests/regression/R2_tls.sh | evidence/after/tls_scan_after.txt |
| C04 | L’accès SSH d’administration utilise uniquement l’authentification par clé, avec login root désactivé et utilisateur admin dédié. | controls/remote_access/ (ssh_hardening.md, sshd_config_excerpt.txt) | tests/regression/R3_remote_access.sh | evidence/after/ssh_tests.txt, evidence/after/authlog_excerpt.txt |
| C05 | Le tunnel IPsec chiffre uniquement le trafic entre le LAN 10.10.10.0/24 et la DMZ 10.10.20.0/24, pas tout Internet. | controls/remote_access/ (ipsec_siteA.conf, ipsec_siteB.conf) | tests/regression/R3_remote_access.sh | evidence/after/ipsec_status.txt, evidence/after/esp_capture.pcap |
| C06 | Les contrôles edge TLS appliquent un rate limiting qui bloque une rafale de requêtes sur /api après un certain seuil. | controls/tls_edge/ (nginx rate_limit.conf) | tests/regression/R2_tls.sh ou R4_detection.sh | evidence/after/rate_limit_test.txt, evidence/after/nginx_access_log_rate.txt |
| C07 | L’IDS sur la frontière DMZ détecte un flux de test connu (ex. requête HTTP vers /admin) via une règle personnalisée. | controls/ids/ (rules_custom.conf) | tests/regression/R4_detection.sh | evidence/after/ids_alerts_admin.txt |
| C08 | L’ensemble des tests de régression peut être relancé en une commande et produit un rapport clair PASS/FAIL. | tests/regression/ (run_all.sh) | tests/regression/run_all.sh | tests/regression/results/<timestamp>/R*_*.txt |
