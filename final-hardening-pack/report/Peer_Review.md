## Part C — Evidence review clinic (peer review results)

Dans le cadre de la revue croisée, notre équipe a évalué le rapport de l’équipe partenaire en suivant la checklist fournie (Clarity, Reproducibility, Evidence quality, Maintainability). Cette section synthétise nos constats et ce que nous aurions besoin d’améliorer ou de conserver dans notre propre pratique.

### Clarity

Globalement, la politique de sécurité et les contrôles sont décrits de manière suffisamment claire pour être compris sans avoir à deviner les intentions sous‑jacentes. Les objectifs (filtrage réseau, durcissement SSH, profil TLS, détection IDS) sont présentés en langage simple, avec un lien explicite vers les menaces ciblées. Quelques formulations pourraient toutefois être encore resserrées (par exemple, préciser plus systématiquement le périmètre exact des sous‑réseaux ou des flux concernés) afin d’éviter toute interprétation ambiguë lors de futures évolutions.

### Reproducibility

La suite de tests de régression est globalement reproductible : les scripts sont regroupés, numérotés (R1, R2, R3, R4, etc.) et peuvent être relancés facilement pour vérifier l’état du système. Pour chaque test, l’intention et le résultat attendu sont décrits, ce qui permet à une autre équipe de rejouer les scénarios et de comparer les sorties console (PASS/FAIL) avec celles du rapport. Néanmoins, certains prérequis implicites (chemins de clés SSH, comptes utilisés, variables d’environnement) gagneraient à être documentés de façon plus explicite pour garantir la même reproductibilité sur une machine “neuve”.

### Evidence quality

Les revendications de sécurité référencent des fichiers de preuve concrets (extraits de logs, captures de commandes, morceaux de configuration), ce qui permet de remonter facilement du claim vers l’artefact associé. Les extraits de journaux IDS et les sorties de tests sont généralement bien reliés aux scripts correspondants (par exemple, un SID spécifique pour un test R4, ou un code HTTP attendu pour un test R2). Dans quelques cas, il serait utile de renforcer la traçabilité en ajoutant des timestamps ou en rappelant le nom exact du script dans les commentaires du log, afin de rendre la corrélation encore plus évidente pour un lecteur externe.

### Maintainability

Les configurations examinées restent globalement lisibles et raisonnablement minimales : les règles redondantes ou manifestement obsolètes sont limitées, et la structure des fichiers de configuration est suffisamment claire pour être reprise par une autre équipe. La présence de quelques commentaires “TODO” ou de règles explicitement marquées comme temporaires est un bon point, car elle rend visible la dette technique résiduelle. Pour améliorer encore la maintenabilité, nous recommandons de regrouper ces éléments temporaires dans une section dédiée, avec un plan d’action ou une échéance, afin d’éviter qu’ils ne restent en place indéfiniment.
